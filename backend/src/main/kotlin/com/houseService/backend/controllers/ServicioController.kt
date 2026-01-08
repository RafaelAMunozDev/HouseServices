// ServicioController.kt
package com.houseService.backend.controllers

import com.houseService.backend.services.ServicioService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/tipos-servicios")
class ServicioController(
    private val servicioService: ServicioService
) {

    // devuelve todos los servicios disponibles del sistema
    @GetMapping
    fun obtenerTodosLosServicios(): ResponseEntity<*> {
        return try {
            val servicios = servicioService.obtenerTodosLosServicios()
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener los servicios: ${e.message}"))
        }
    }

    // devuelve un servicio segun su id si existe
    @GetMapping("/{id}")
    fun obtenerServicioPorId(@PathVariable id: Int): ResponseEntity<*> {
        return try {
            val servicio = servicioService.obtenerServicioPorId(id)
                ?: return ResponseEntity.notFound().build<Any>()
            ResponseEntity.ok(servicio)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener el servicio: ${e.message}"))
        }
    }
}
