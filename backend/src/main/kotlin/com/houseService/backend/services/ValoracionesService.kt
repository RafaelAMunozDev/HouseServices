package com.houseService.backend.services

import com.houseService.backend.dto.request.CrearValoracionRequest
import com.houseService.backend.models.Valoraciones
import com.houseService.backend.repositories.*
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class ValoracionesService(
    private val valoracionesRepository: ValoracionesRepository,
    private val serviciosContratadosRepository: ServiciosContratadosRepository,
    private val servicioDisponibleRepository: ServicioDisponibleRepository,
    private val serviciosEstadosRepository: ServiciosEstadosRepository,
    private val usuariosRepository: UsuarioRepository,
    private val serviciosRepository: ServicioRepository
) {

    // crea una valoracion si el servicio fue completado y no hay una previa
    @Transactional
    fun crearValoracion(clienteId: Int, request: CrearValoracionRequest): Map<String, Any> {
        val servicioContratado = serviciosContratadosRepository.findById(request.servicioContratadoId)
            .orElseThrow { IllegalArgumentException("Servicio contratado con ID ${request.servicioContratadoId} no encontrado") }

        if (servicioContratado.clienteId != clienteId) {
            throw IllegalArgumentException("No tienes permisos para valorar este servicio")
        }

        val estadoCompletado = serviciosEstadosRepository.findByEstado("completado")
            ?: throw IllegalStateException("Estado 'completado' no encontrado")

        if (servicioContratado.estadoId != estadoCompletado.id) {
            throw IllegalArgumentException("Solo puedes valorar servicios completados")
        }

        if (valoracionesRepository.existsByServicioContratadoId(request.servicioContratadoId)) {
            throw IllegalArgumentException("Este servicio ya ha sido valorado")
        }

        if (request.puntuacion !in 1..5) {
            throw IllegalArgumentException("La puntuación debe estar entre 1 y 5")
        }

        val servicioDisponible = servicioDisponibleRepository.findById(servicioContratado.servicioDisponibleId)
            .orElseThrow { IllegalArgumentException("Servicio disponible no encontrado") }

        val valoracion = Valoraciones(
            servicioContratadoId = request.servicioContratadoId,
            clienteId = clienteId,
            trabajadorId = servicioDisponible.trabajadorId,
            puntuacion = request.puntuacion,
            comentario = request.comentario
        )

        val valoracionGuardada = valoracionesRepository.save(valoracion)

        return mapOf(
            "id" to valoracionGuardada.id,
            "servicio_contratado_id" to valoracionGuardada.servicioContratadoId,
            "cliente_id" to valoracionGuardada.clienteId,
            "trabajador_id" to valoracionGuardada.trabajadorId,
            "puntuacion" to valoracionGuardada.puntuacion,
            "comentario" to (valoracionGuardada.comentario ?: ""),
            "fecha_valoracion" to valoracionGuardada.fechaValoracion
        ) as Map<String, Any>
    }

    // trae valoraciones hechas por un cliente
    fun obtenerValoracionesCliente(clienteId: Int): List<Valoraciones> {
        return valoracionesRepository.findByClienteId(clienteId)
    }

    // trae una valoracion especifica por id de servicio
    fun obtenerValoracionPorServicio(servicioContratadoId: Int): Valoraciones? {
        return valoracionesRepository.findByServicioContratadoId(servicioContratadoId)
    }

    // trae valoraciones de un trabajador con info del cliente y del servicio
    fun obtenerValoracionesTrabajador(trabajadorId: Int): List<Map<String, Any>> {
        val serviciosContratados = serviciosContratadosRepository.findByTrabajadorId(trabajadorId)

        return serviciosContratados.mapNotNull { servicio ->
            val valoracion = valoracionesRepository.findByServicioContratadoId(servicio.id)

            valoracion?.let {
                val cliente = usuariosRepository.findById(servicio.clienteId).orElse(null)
                val servicioDisponible = servicioDisponibleRepository.findById(servicio.servicioDisponibleId).orElse(null)
                val tipoServicio = servicioDisponible?.let { sd ->
                    serviciosRepository.findById(sd.servicioId).orElse(null)
                }

                mapOf(
                    "valoracion" to mapOf(
                        "id" to it.id,
                        "servicio_contratado_id" to it.servicioContratadoId,
                        "cliente_id" to it.clienteId,
                        "trabajador_id" to it.trabajadorId,
                        "puntuacion" to it.puntuacion,
                        "comentario" to (it.comentario ?: ""),
                        "fecha_valoracion" to it.fechaValoracion
                    ),
                    "servicio_contratado" to mapOf(
                        "id" to servicio.id,
                        "cliente_id" to servicio.clienteId,
                        "servicio_disponible_id" to servicio.servicioDisponibleId,
                        "fecha_confirmada" to servicio.fechaConfirmada,
                        "fecha_realizada" to servicio.fechaRealizada,
                        "estado_id" to servicio.estadoId,
                        "horario_seleccionado" to servicio.horarioSeleccionado,
                        "observaciones" to servicio.observaciones,
                        "cliente_nombre" to (cliente?.nombre ?: ""),
                        "cliente_apellido" to "${cliente?.apellido1 ?: ""}${if (!cliente?.apellido2.isNullOrEmpty()) " ${cliente.apellido2}" else ""}".trim(),
                        "nombre_servicio" to (tipoServicio?.nombre ?: "")
                    )
                )
            }
        }
    }

    // verifica si ya hay valoracion pa ese servicio
    fun existeValoracion(servicioContratadoId: Int): Boolean {
        return valoracionesRepository.existsByServicioContratadoId(servicioContratadoId)
    }
}
