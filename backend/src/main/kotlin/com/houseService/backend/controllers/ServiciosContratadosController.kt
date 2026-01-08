package com.houseService.backend.controllers

import com.houseService.backend.dto.request.ContratarServicioRequest
import com.houseService.backend.services.ServiciosContratadosService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/servicios-contratados")
class ServiciosContratadosController(
    private val serviciosContratadosService: ServiciosContratadosService
) {

    // crea una nueva reserva sin validaciones complejas
    @PostMapping
    fun contratarServicio(
        @RequestParam clienteId: Int,
        @RequestBody request: ContratarServicioRequest
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.contratarServicio(clienteId, request)

            ResponseEntity.status(HttpStatus.CREATED).body(mapOf(
                "success" to true,
                "message" to "Reserva creada exitosamente",
                "id" to servicio.id,
                "servicio" to servicio
            ))

        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf(
                "success" to false,
                "message" to e.message
            ))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(mapOf(
                "success" to false,
                "message" to "Error interno del servidor: ${e.message}"
            ))
        }
    }

    // devuelve los servicios contratados por un cliente
    @GetMapping("/cliente/{clienteId}")
    fun obtenerServiciosCliente(@PathVariable clienteId: Int): ResponseEntity<*> {
        return try {
            val servicios = serviciosContratadosService.obtenerServiciosCliente(clienteId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener servicios: ${e.message}"))
        }
    }

    @GetMapping("/disponibilidad/{servicioDisponibleId}")
    fun obtenerHorasOcupadas(
        @PathVariable servicioDisponibleId: Int,
        @RequestParam fecha: String
    ): ResponseEntity<*> {
        return try {
            val horas = serviciosContratadosService.obtenerHorasOcupadas(
                servicioDisponibleId,
                fecha
            )

            ResponseEntity.ok(
                mapOf("horas_ocupadas" to horas)
            )

        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                mapOf("message" to "Error al obtener disponibilidad")
            )
        }
    }

    // devuelve los servicios pendientes del trabajador con todos los detalles
    @GetMapping("/trabajador/{trabajadorId}/pendientes")
    fun obtenerServiciosPendientes(@PathVariable trabajadorId: Int): ResponseEntity<*> {
        return try {
            val servicios = serviciosContratadosService.obtenerServiciosPendientesConDetalles(trabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener servicios pendientes: ${e.message}"))
        }
    }

    // devuelve los servicios pendientes en modo simple
    @GetMapping("/trabajador/{trabajadorId}/pendientes-simple")
    fun obtenerServiciosPendientesSimple(@PathVariable trabajadorId: Int): ResponseEntity<*> {
        return try {
            val servicios = serviciosContratadosService.obtenerServiciosPendientesSimple(trabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener servicios pendientes: ${e.message}"))
        }
    }

    // devuelve todos los servicios asociados a un trabajador
    @GetMapping("/trabajador/{trabajadorId}")
    fun obtenerServiciosTrabajador(@PathVariable trabajadorId: Int): ResponseEntity<*> {
        return try {
            val servicios = serviciosContratadosService.obtenerServiciosTrabajador(trabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener servicios: ${e.message}"))
        }
    }

    // confirma un servicio, el trabajador lo acepta
    @PutMapping("/{servicioId}/confirmar")
    fun confirmarServicio(
        @PathVariable servicioId: Int,
        @RequestParam trabajadorId: Int
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.confirmarServicio(servicioId, trabajadorId)
            ResponseEntity.ok(servicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al confirmar servicio: ${e.message}"))
        }
    }

    // rechaza un servicio asignado
    @PutMapping("/{servicioId}/rechazar")
    fun rechazarServicio(
        @PathVariable servicioId: Int,
        @RequestParam trabajadorId: Int
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.rechazarServicio(servicioId, trabajadorId)
            ResponseEntity.ok(servicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al rechazar servicio: ${e.message}"))
        }
    }

    // marca un servicio como iniciado
    @PutMapping("/{servicioId}/iniciar")
    fun iniciarServicio(
        @PathVariable servicioId: Int,
        @RequestParam trabajadorId: Int
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.iniciarServicio(servicioId, trabajadorId)
            ResponseEntity.ok(servicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al iniciar servicio: ${e.message}"))
        }
    }

    // marca un servicio como completado
    @PutMapping("/{servicioId}/completar")
    fun completarServicio(
        @PathVariable servicioId: Int,
        @RequestParam trabajadorId: Int
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.completarServicio(servicioId, trabajadorId)
            ResponseEntity.ok(servicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al completar servicio: ${e.message}"))
        }
    }

    // cancela un servicio desde el lado del cliente
    @PutMapping("/{servicioId}/cancelar")
    fun cancelarServicio(
        @PathVariable servicioId: Int,
        @RequestParam clienteId: Int
    ): ResponseEntity<*> {
        return try {
            val servicio = serviciosContratadosService.cancelarServicio(servicioId, clienteId)
            ResponseEntity.ok(servicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al cancelar servicio: ${e.message}"))
        }
    }

    // obtiene todos los servicios del trabajador que estan en gestion
    @GetMapping("/trabajador/{trabajadorId}/gestion")
    fun obtenerServiciosEnGestion(@PathVariable trabajadorId: Int): ResponseEntity<*> {
        return try {
            val servicios = serviciosContratadosService.obtenerServiciosEnGestion(trabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener servicios en gestión: ${e.message}"))
        }
    }

    // obtiene el historial de servicios contratados por un cliente
    @GetMapping("/cliente/{clienteId}/historial")
    fun obtenerHistorialCliente(@PathVariable clienteId: Int): ResponseEntity<*> {
        return try {
            val historial = serviciosContratadosService.obtenerHistorialServiciosCliente(clienteId)
            ResponseEntity.ok(historial)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener historial: ${e.message}"))
        }
    }
}
