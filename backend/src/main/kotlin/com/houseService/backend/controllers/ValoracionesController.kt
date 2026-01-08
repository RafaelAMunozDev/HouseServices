package com.houseService.backend.controllers

import com.houseService.backend.dto.request.CrearValoracionRequest
import com.houseService.backend.services.ValoracionesService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/valoraciones")
class ValoracionesController(
    private val valoracionesService: ValoracionesService
) {

    // guarda una nueva valoracion para un servicio
    @PostMapping
    fun crearValoracion(
        @RequestParam clienteId: Int,
        @RequestBody request: CrearValoracionRequest
    ): ResponseEntity<*> {
        return try {
            val valoracion = valoracionesService.crearValoracion(clienteId, request)
            ResponseEntity.status(HttpStatus.CREATED).body(valoracion)
        } catch (e: IllegalArgumentException) {
            ResponseEntity.badRequest().body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al crear valoración: ${e.message}"))
        }
    }

    // devuelve todas las valoraciones hechas por un cliente
    @GetMapping("/cliente/{clienteId}")
    fun obtenerValoracionesCliente(@PathVariable clienteId: Int): ResponseEntity<*> {
        return try {
            val valoraciones = valoracionesService.obtenerValoracionesCliente(clienteId)
            ResponseEntity.ok(valoraciones)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener valoraciones: ${e.message}"))
        }
    }

    // devuelve la valoracion de un servicio si existe
    @GetMapping("/servicio/{servicioContratadoId}")
    fun obtenerValoracionServicio(@PathVariable servicioContratadoId: Int): ResponseEntity<*> {
        return try {
            val valoracion = valoracionesService.obtenerValoracionPorServicio(servicioContratadoId)
            if (valoracion != null) {
                ResponseEntity.ok(valoracion)
            } else {
                ResponseEntity.notFound().build<Any>()
            }
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener valoración: ${e.message}"))
        }
    }

    // devuelve las valoraciones recibidas por un trabajador
    @GetMapping("/trabajador/{trabajadorId}")
    fun obtenerValoracionesTrabajador(@PathVariable trabajadorId: Int): ResponseEntity<*> {
        return try {
            val valoraciones = valoracionesService.obtenerValoracionesTrabajador(trabajadorId)
            ResponseEntity.ok(valoraciones)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener valoraciones: ${e.message}"))
        }
    }

    // verifica si ya existe valoracion para ese servicio
    @GetMapping("/servicio/{servicioContratadoId}/existe")
    fun verificarValoracionExiste(@PathVariable servicioContratadoId: Int): ResponseEntity<*> {
        return try {
            val existe = valoracionesService.existeValoracion(servicioContratadoId)
            ResponseEntity.ok(mapOf("existe" to existe))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al verificar valoración: ${e.message}"))
        }
    }
}
