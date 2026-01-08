package com.houseService.backend.services

import com.fasterxml.jackson.databind.ObjectMapper
import com.houseService.backend.dto.request.ContratarServicioRequest
import com.houseService.backend.models.ServiciosContratados
import com.houseService.backend.repositories.*
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter

@Service
class ServiciosContratadosService(
    private val serviciosContratadosRepository: ServiciosContratadosRepository,
    private val servicioDisponibleRepository: ServicioDisponibleRepository,
    private val serviciosEstadosRepository: ServiciosEstadosRepository,
    private val usuariosRepository: UsuarioRepository,
    private val fcmService: FCMService,
    private val servicioRepository: ServicioRepository,
    private val objectMapper: ObjectMapper
) {

    // crear nueva reserva de servicio con notificacion al trabajador
    @Transactional
    fun contratarServicio(
        clienteId: Int,
        request: ContratarServicioRequest
    ): ServiciosContratados {

        // comprobar que existe el servicio disponible
        servicioDisponibleRepository.findById(request.servicioDisponibleId)
            .orElseThrow { IllegalArgumentException("Servicio disponible no encontrado") }

        // comprobar que existe el cliente
        usuariosRepository.findById(clienteId)
            .orElseThrow { IllegalArgumentException("Cliente no encontrado") }

        // validar disponibilidad del horario (SIEMPRE)
        val disponibilidad = verificarDisponibilidadHorario(
            servicioDisponibleId = request.servicioDisponibleId,
            fecha = request.horarioSeleccionado.fecha,
            horaInicio = request.horarioSeleccionado.horaInicio,
            horaFin = request.horarioSeleccionado.horaFin
        )

        if (!disponibilidad.disponible) {
            throw IllegalArgumentException(disponibilidad.mensaje)
        }

        // obtener estado inicial
        val estadoSolicitado = serviciosEstadosRepository.findByEstado("solicitado")
            ?: throw IllegalStateException("Estado 'solicitado' no encontrado")

        // convertir horario a json
        val horarioJson = objectMapper.writeValueAsString(request.horarioSeleccionado)

        // crear reserva
        val servicioContratado = ServiciosContratados(
            clienteId = clienteId,
            servicioDisponibleId = request.servicioDisponibleId,
            estadoId = estadoSolicitado.id,
            horarioSeleccionado = horarioJson,
            observaciones = request.observaciones
        )

        val savedServicio = serviciosContratadosRepository.save(servicioContratado)

        // notificacion (no bloqueante)
        try {
            val servicioDisponible = servicioDisponibleRepository.findById(request.servicioDisponibleId).orElse(null)
            val cliente = usuariosRepository.findById(clienteId).orElse(null)
            val tipoServicio = servicioRepository.findById(servicioDisponible?.servicioId ?: 0).orElse(null)

            val clienteNombre = cliente?.let { "${it.nombre} ${it.apellido1}".trim() } ?: "Cliente"
            val servicioNombre = tipoServicio?.nombre ?: "Servicio"

            if (servicioDisponible != null) {
                fcmService.notificarServicioSolicitado(
                    servicioDisponible.trabajadorId,
                    clienteNombre,
                    servicioNombre
                )
            }
        } catch (_: Exception) {
            // no rompe flujo
        }

        return savedServicio
    }


    // trabajador acepta la solicitud de servicio
    @Transactional
    fun confirmarServicio(servicioId: Int, trabajadorId: Int): ServiciosContratados {
        val servicio = obtenerServicioConValidacion(servicioId, trabajadorId)

        val estadoConfirmado = serviciosEstadosRepository.findByEstado("confirmado")
            ?: throw IllegalStateException("Estado 'confirmado' no encontrado")

        val servicioActualizado = servicio.copy(
            estadoId = estadoConfirmado.id,
            fechaConfirmada = LocalDateTime.now()
        )

        val savedServicio = serviciosContratadosRepository.save(servicioActualizado)
        notificarCambioEstado(savedServicio, "confirmado")

        return savedServicio
    }

    // trabajador rechaza la solicitud de servicio
    @Transactional
    fun rechazarServicio(servicioId: Int, trabajadorId: Int): ServiciosContratados {
        val servicio = obtenerServicioConValidacion(servicioId, trabajadorId)

        val estadoRechazado = serviciosEstadosRepository.findByEstado("rechazado")
            ?: throw IllegalStateException("Estado 'rechazado' no encontrado")

        val servicioActualizado = servicio.copy(estadoId = estadoRechazado.id)
        val savedServicio = serviciosContratadosRepository.save(servicioActualizado)

        notificarCambioEstado(savedServicio, "rechazado")
        return savedServicio
    }

    // cambiar estado a en progreso cuando inicia el trabajo
    @Transactional
    fun iniciarServicio(servicioId: Int, trabajadorId: Int): ServiciosContratados {
        val servicio = obtenerServicioConValidacion(servicioId, trabajadorId)

        val estadoEnProgreso = serviciosEstadosRepository.findByEstado("en_progreso")
            ?: throw IllegalStateException("Estado 'en_progreso' no encontrado")

        val servicioActualizado = servicio.copy(estadoId = estadoEnProgreso.id)
        return serviciosContratadosRepository.save(servicioActualizado)
    }

    // marcar servicio como terminado con fecha de realizacion
    @Transactional
    fun completarServicio(servicioId: Int, trabajadorId: Int): ServiciosContratados {
        val servicio = obtenerServicioConValidacion(servicioId, trabajadorId)

        val estadoCompletado = serviciosEstadosRepository.findByEstado("completado")
            ?: throw IllegalStateException("Estado 'completado' no encontrado")

        val servicioActualizado = servicio.copy(
            estadoId = estadoCompletado.id,
            fechaRealizada = LocalDateTime.now()
        )

        val savedServicio = serviciosContratadosRepository.save(servicioActualizado)
        notificarCambioEstado(savedServicio, "completado")

        return savedServicio
    }

    // cliente cancela su solicitud de servicio
    @Transactional
    fun cancelarServicio(servicioId: Int, clienteId: Int): ServiciosContratados {

        val servicio = serviciosContratadosRepository.findById(servicioId)
            .orElseThrow { IllegalArgumentException("Servicio no encontrado") }

        if (servicio.clienteId != clienteId) {
            throw IllegalArgumentException("No tienes permisos para cancelar este servicio")
        }

        when (servicio.estadoId) {
            1 -> { /* ok */ }

            2 -> {
                val horarioMap = try {
                    objectMapper.readValue(servicio.horarioSeleccionado, Map::class.java) as Map<String, Any>
                } catch (e: Exception) {
                    throw IllegalArgumentException("No se pudo leer el horario del servicio")
                }

                val fechaStr = horarioMap["fecha"] as? String
                    ?: throw IllegalArgumentException("El horario no tiene 'fecha'")

                val horaInicioStr = horarioMap["hora_inicio"] as? String
                    ?: throw IllegalArgumentException("El horario no tiene 'hora_inicio'")

                val fechaServicio = try {
                    LocalDate.parse(fechaStr, DateTimeFormatter.ISO_LOCAL_DATE)
                } catch (e: Exception) {
                    throw IllegalArgumentException("Formato de fecha invalido en el horario")
                }

                val horaInicioServicio = try {
                    LocalTime.parse(horaInicioStr, DateTimeFormatter.ofPattern("HH:mm"))
                } catch (e: Exception) {
                    throw IllegalArgumentException("Formato de hora invalido en el horario")
                }

                val fechaHoraServicio = LocalDateTime.of(fechaServicio, horaInicioServicio)
                val ahora = LocalDateTime.now()

                if (!fechaHoraServicio.isAfter(ahora)) {
                    throw IllegalArgumentException("No puedes cancelar un servicio confirmado con menos de 48 horas de antelacion")
                }

                val minutosHastaServicio = Duration.between(ahora, fechaHoraServicio).toMinutes()
                if (minutosHastaServicio < 48L * 60L) {
                    throw IllegalArgumentException("No puedes cancelar un servicio confirmado con menos de 48 horas de antelacion")
                }
            }

            else -> {
                val estadoNombre = serviciosEstadosRepository.findById(servicio.estadoId).orElse(null)?.estado ?: "desconocido"
                throw IllegalArgumentException("No se puede cancelar un servicio en estado '$estadoNombre'")
            }
        }

        val estadoCancelado = serviciosEstadosRepository.findByEstado("cancelado")
            ?: throw IllegalStateException("Estado 'cancelado' no encontrado")

        val servicioActualizado = servicio.copy(estadoId = estadoCancelado.id)
        val savedServicio = serviciosContratadosRepository.save(servicioActualizado)

        // noti al trabajador
        try {
            val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
            if (servicioDisponible != null) {
                val cliente = usuariosRepository.findById(clienteId).orElse(null)
                val tipoServicio = servicioRepository.findById(servicioDisponible.servicioId).orElse(null)

                val clienteNombre = cliente?.let { "${it.nombre} ${it.apellido1}".trim() } ?: "Cliente"
                val servicioNombre = tipoServicio?.nombre ?: "Servicio"

                fcmService.notificarServicioCanceladoPorCliente(
                    servicioDisponible.trabajadorId,
                    clienteNombre,
                    servicioNombre
                )
            }
        } catch (e: Exception) {
            // no rompe el flujo
        }

        return savedServicio
    }

    fun obtenerHorasOcupadas(
        servicioDisponibleId: Int,
        fecha: String
    ): List<String> {

        // buscamos reservas de ese servicio y fecha
        val reservas = serviciosContratadosRepository
            .findReservationsByServiceAndDate(servicioDisponibleId, fecha)

        val horasOcupadas = mutableSetOf<String>()

        reservas.forEach { reserva ->
            // solo bloquean estas
            if (reserva.estadoId !in listOf(3, 6)) {

                val horarioMap = try {
                    objectMapper.readValue(reserva.horarioSeleccionado, Map::class.java)
                } catch (e: Exception) {
                    return@forEach
                }

                val horaInicio = horarioMap["hora_inicio"] as? String ?: return@forEach
                horasOcupadas.add(horaInicio)
            }
        }

        return horasOcupadas.toList().sorted()
    }

    // obtener todos los servicios contratados por un cliente
    fun obtenerServiciosCliente(clienteId: Int): List<ServiciosContratados> {
        return serviciosContratadosRepository.findByClienteId(clienteId)
    }

    // obtener servicios pendientes de confirmacion para trabajador
    fun obtenerServiciosPendientesSimple(trabajadorId: Int): List<ServiciosContratados> {
        val estadoSolicitado = serviciosEstadosRepository.findByEstado("solicitado")
            ?: return emptyList()

        return serviciosContratadosRepository.findByTrabajadorIdAndEstadoId(trabajadorId, estadoSolicitado.id)
    }

    // obtener todos los servicios de un trabajador independientemente del estado
    fun obtenerServiciosTrabajador(trabajadorId: Int): List<ServiciosContratados> {
        return serviciosContratadosRepository.findByTrabajadorId(trabajadorId)
    }

    // obtener servicios pendientes con toda la informacion necesaria para mostrar
    fun obtenerServiciosPendientesConDetalles(trabajadorId: Int): List<Map<String, Any?>> {
        val estadoSolicitado = serviciosEstadosRepository.findByEstado("solicitado")
            ?: return emptyList()

        // filtrar servicios en estado solicitado para este trabajador
        val serviciosContratados = serviciosContratadosRepository.findAll()
            .filter { servicio ->
                val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
                servicioDisponible?.trabajadorId == trabajadorId && servicio.estadoId == estadoSolicitado.id
            }

        return serviciosContratados.map { servicio -> mapearServicioContratadoConDetalles(servicio) }
    }

    // obtener servicios en gestion con informacion completa ordenados por fecha
    fun obtenerServiciosEnGestion(trabajadorId: Int): List<Map<String, Any?>> {
        val estadosGestion = listOf("confirmado", "rechazado", "completado", "en_progreso", "cancelado_cliente", "cancelado")
        val estadosIds = estadosGestion.mapNotNull { estadoNombre ->
            serviciosEstadosRepository.findByEstado(estadoNombre)?.id
        }

        if (estadosIds.isEmpty()) return emptyList()

        // filtrar servicios en estados de gestion para este trabajador
        val serviciosContratados = serviciosContratadosRepository.findAll()
            .filter { servicio ->
                val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
                servicioDisponible?.trabajadorId == trabajadorId && servicio.estadoId in estadosIds
            }
            .sortedByDescending { it.fechaConfirmada ?: LocalDateTime.now() }

        return serviciosContratados.map { servicio -> mapearServicioContratadoConDetalles(servicio) }
    }

    // verificar si un horario especifico esta libre para reservar
    fun verificarDisponibilidadHorario(
        servicioDisponibleId: Int,
        fecha: String,
        horaInicio: String,
        horaFin: String
    ): DisponibilidadResult {
        try {
            // validar formatos de fecha y hora
            val fechaLocal = try {
                LocalDate.parse(fecha, DateTimeFormatter.ISO_LOCAL_DATE)
            } catch (e: Exception) {
                return DisponibilidadResult(false, "Formato de fecha invalido")
            }

            val horaInicioLocal = try {
                LocalTime.parse(horaInicio, DateTimeFormatter.ofPattern("HH:mm"))
            } catch (e: Exception) {
                return DisponibilidadResult(false, "Formato de hora invalido")
            }

            // verificar que no sea una fecha pasada
            val fechaHoraReserva = LocalDateTime.of(fechaLocal, horaInicioLocal)
            if (fechaHoraReserva.isBefore(LocalDateTime.now().plusMinutes(30))) {
                return DisponibilidadResult(
                    false,
                    "No se pueden hacer reservas en horarios pasados o muy proximos"
                )
            }

            // buscar reservas existentes para esa fecha y servicio
            val reservasExistentes = serviciosContratadosRepository.findReservationsByServiceAndDate(
                servicioDisponibleId,
                fecha
            )

            // verificar solapamientos con reservas activas
            for (reservaExistente in reservasExistentes) {
                if (reservaExistente.estadoId in listOf(1, 3, 5)) {
                    val conflicto = verificarSolapamiento(reservaExistente, horaInicio, horaFin)
                    if (conflicto) {
                        return DisponibilidadResult(
                            false,
                            "Ya existe una reserva confirmada para este horario"
                        )
                    }
                }
            }

            return DisponibilidadResult(true, "Horario disponible")

        } catch (e: Exception) {
            return DisponibilidadResult(
                false,
                "Error al verificar disponibilidad: ${e.message}"
            )
        }
    }

    // obtener historial completo de servicios del cliente con detalles
    fun obtenerHistorialServiciosCliente(clienteId: Int): List<Map<String, Any?>> {
        return try {
            val serviciosContratados = serviciosContratadosRepository.findByClienteId(clienteId)
                .sortedByDescending { it.id }

            serviciosContratados.map { servicio ->
                mapearServicioContratadoParaCliente(servicio)
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    // validar permisos del trabajador sobre un servicio
    private fun obtenerServicioConValidacion(servicioId: Int, trabajadorId: Int): ServiciosContratados {
        val servicio = serviciosContratadosRepository.findById(servicioId)
            .orElseThrow { IllegalArgumentException("Servicio no encontrado") }

        val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId)
            .orElseThrow { IllegalStateException("Servicio disponible no encontrado") }

        if (servicioDisponible.trabajadorId != trabajadorId) {
            throw IllegalArgumentException("No tienes permisos para modificar este servicio")
        }

        return servicio
    }

    // enviar notificaciones al cliente cuando cambia el estado del servicio
    private fun notificarCambioEstado(servicio: ServiciosContratados, nuevoEstado: String) {
        try {
            val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId)
                .orElse(null) ?: return

            val trabajador = usuariosRepository.findById(servicioDisponible.trabajadorId).orElse(null)
            val trabajadorNombre = trabajador?.let { "${it.nombre} ${it.apellido1}".trim() } ?: "Trabajador"

            val servicioInfo = servicioRepository.findById(servicioDisponible.servicioId).orElse(null)
            val servicioNombre = servicioInfo?.nombre ?: "Servicio"

            // enviar notificacion segun el nuevo estado
            when (nuevoEstado) {
                "confirmado" -> fcmService.notificarServicioConfirmado(
                    servicio.clienteId, trabajadorNombre, servicioNombre
                )
                "rechazado" -> fcmService.notificarServicioRechazado(
                    servicio.clienteId, trabajadorNombre, servicioNombre
                )
                "completado" -> fcmService.notificarServicioCompletado(
                    servicio.clienteId, trabajadorNombre, servicioNombre
                )
            }
        } catch (e: Exception) {
            // error en notificacion no debe interrumpir el flujo
        }
    }

    // crear mapa con todos los detalles del servicio para el frontend
    private fun mapearServicioContratadoConDetalles(servicio: ServiciosContratados): Map<String, Any?> {
        // obtener datos relacionados del servicio
        val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
        val cliente = usuariosRepository.findById(servicio.clienteId).orElse(null)
        val estado = serviciosEstadosRepository.findById(servicio.estadoId).orElse(null)
        val tipoServicio = servicioDisponible?.let {
            servicioRepository.findById(it.servicioId).orElse(null)
        }

        return mapOf(
            // informacion basica del servicio contratado
            "id" to servicio.id,
            "cliente_id" to servicio.clienteId,
            "servicio_disponible_id" to servicio.servicioDisponibleId,
            "estado_id" to servicio.estadoId,
            "horario_seleccionado" to servicio.horarioSeleccionado,
            "observaciones" to servicio.observaciones,
            "fecha_confirmada" to servicio.fechaConfirmada?.toString(),
            "fecha_realizada" to servicio.fechaRealizada?.toString(),

            // datos del cliente que contrato
            "cliente_nombre" to cliente?.nombre,
            "cliente_apellido" to cliente?.apellido1,
            "cliente_correo" to cliente?.correo,
            "cliente_telefono" to cliente?.telefono,

            // informacion del tipo de servicio
            "servicio_nombre" to tipoServicio?.nombre,
            "nombre_servicio" to tipoServicio?.nombre,
            "nombre_trabajador" to cliente?.let { "${it.nombre} ${it.apellido1}".trim() },
            "precio_hora" to servicioDisponible?.precioHora,

            // estado actual
            "estado_nombre" to estado?.estado
        )
    }

    // verificar si dos intervalos de tiempo se solapan
    private fun verificarSolapamiento(
        reservaExistente: ServiciosContratados,
        nuevaHoraInicio: String,
        nuevaHoraFin: String
    ): Boolean {
        return try {
            // extraer horarios de la reserva existente desde json
            val horarioExistente = objectMapper.readValue(reservaExistente.horarioSeleccionado, Map::class.java)
            val horaInicioExistente = horarioExistente["hora_inicio"] as? String ?: return false
            val horaFinExistente = horarioExistente["hora_fin"] as? String ?: return false

            // convertir a minutos para comparacion facil
            val nuevaInicioMin = convertirHoraAMinutos(nuevaHoraInicio)
            val nuevaFinMin = convertirHoraAMinutos(nuevaHoraFin)
            val existenteInicioMin = convertirHoraAMinutos(horaInicioExistente)
            val existenteFinMin = convertirHoraAMinutos(horaFinExistente)

            // algoritmo de deteccion de solapamiento
            (nuevaInicioMin < existenteFinMin) && (nuevaFinMin > existenteInicioMin)

        } catch (e: Exception) {
            false
        }
    }

    // convertir formato hora a minutos desde medianoche para calculos
    private fun convertirHoraAMinutos(hora: String): Int {
        val partes = hora.split(":")
        return partes[0].toInt() * 60 + partes[1].toInt()
    }

    // crear mapa con detalles del servicio para mostrar al cliente
    private fun mapearServicioContratadoParaCliente(servicio: ServiciosContratados): Map<String, Any?> {
        // obtener informacion relacionada
        val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
        val estado = serviciosEstadosRepository.findById(servicio.estadoId).orElse(null)
        val tipoServicio = servicioDisponible?.let {
            servicioRepository.findById(it.servicioId).orElse(null)
        }
        val trabajador = servicioDisponible?.let {
            usuariosRepository.findById(it.trabajadorId).orElse(null)
        }

        // parsear horario desde json
        val horarioMap = try {
            objectMapper.readValue(servicio.horarioSeleccionado, Map::class.java) as Map<String, Any>
        } catch (e: Exception) {
            emptyMap<String, Any>()
        }

        return mapOf(
            // datos principales del servicio
            "id" to servicio.id,
            "estado_id" to servicio.estadoId,
            "estado_nombre" to estado?.estado,
            "observaciones" to servicio.observaciones,
            "fecha_confirmada" to servicio.fechaConfirmada?.toString(),
            "fecha_realizada" to servicio.fechaRealizada?.toString(),

            // detalles del servicio contratado
            "servicio_id" to servicioDisponible?.servicioId,
            "servicio_nombre" to tipoServicio?.nombre,
            "servicio_icono" to tipoServicio?.icono,
            "servicio_color" to tipoServicio?.color,
            "precio_hora" to servicioDisponible?.precioHora,

            // informacion del trabajador asignado
            "trabajador_id" to servicioDisponible?.trabajadorId,
            "trabajador_nombre" to trabajador?.let { "${it.nombre} ${it.apellido1}".trim() },

            // detalles del horario seleccionado
            "fecha" to horarioMap["fecha"],
            "dia_semana" to horarioMap["dia_semana"],
            "hora_inicio" to horarioMap["hora_inicio"],
            "hora_fin" to horarioMap["hora_fin"],
            "duracion_minutos" to horarioMap["duracion_estimada_minutos"]
        )
    }

    // clase para resultado de verificacion de disponibilidad
    data class DisponibilidadResult(
        val disponible: Boolean,
        val mensaje: String
    )
}