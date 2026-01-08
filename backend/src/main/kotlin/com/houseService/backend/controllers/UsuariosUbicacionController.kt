package com.houseService.backend.controllers

import com.houseService.backend.models.UsuariosUbicacion
import com.houseService.backend.services.UsuarioService
import com.houseService.backend.services.UsuariosUbicacionService
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// controlador pa manejar ubicaciones de los usuarios
private val logger = LoggerFactory.getLogger(AuthController::class.java)

@RestController
@RequestMapping("/api/ubicaciones")
class UsuariosUbicacionController(
    private val UsuariosUbicacionService: UsuariosUbicacionService,
    private val usuarioService: UsuarioService
) {

    // devuelve todas las ubicaciones de un usuario
    @GetMapping("/usuario/{usuarioId}")
    fun obtenerPorUsuario(@PathVariable usuarioId: Int): List<UsuariosUbicacion> {
        return UsuariosUbicacionService.obtenerUbicacionesPorUsuario(usuarioId)
    }

    // devuelve una ubicacion por id si existe
    @GetMapping("/{id}")
    fun obtenerPorId(@PathVariable id: Int): ResponseEntity<UsuariosUbicacion> {
        val ubicacion = UsuariosUbicacionService.obtenerPorId(id)
        return if (ubicacion != null) ResponseEntity.ok(ubicacion)
        else ResponseEntity.notFound().build()
    }

    // guarda una nueva ubicacion
    @PostMapping
    fun crear(@RequestBody ubicacion: UsuariosUbicacion): ResponseEntity<Map<String, Any>> {
        try {
            val ubicacionGuardada = UsuariosUbicacionService.guardarUbicacion(ubicacion)

            return ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Ubicación guardada correctamente",
                "ubicacion" to ubicacionGuardada
            ))
        } catch (e: Exception) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(mapOf(
                "success" to false,
                "message" to "Error al guardar la ubicación: ${e.message}"
            ))
        }
    }

    // actualiza una ubicacion si existe y el usuario tambien
    @PutMapping("/{id}")
    fun actualizar(@PathVariable id: Int, @RequestBody ubicacionActualizada: UsuariosUbicacion): ResponseEntity<Map<String, Any>> {
        val existente = UsuariosUbicacionService.obtenerPorId(id)

        if (existente == null) {
            return ResponseEntity.notFound().build()
        }

        // verifica si el nuevo usuario existe antes de actualizar
        val usuarioExiste = usuarioService.obtenerPorId(ubicacionActualizada.usuarioId) != null

        if (!usuarioExiste) {
            return ResponseEntity.badRequest().body(mapOf(
                "success" to false,
                "message" to "El usuario con ID ${ubicacionActualizada.usuarioId} no existe"
            ))
        }

        val ubicacionConId = ubicacionActualizada.copy(id = id)
        val resultado = UsuariosUbicacionService.guardarUbicacion(ubicacionConId)

        return ResponseEntity.ok(mapOf(
            "success" to true,
            "message" to "Ubicación actualizada correctamente",
            "ubicacion" to resultado
        ))
    }

    // elimina una ubicacion si existe
    @DeleteMapping("/{id}")
    fun eliminar(@PathVariable id: Int): ResponseEntity<Void> {
        return if (UsuariosUbicacionService.obtenerPorId(id) != null) {
            UsuariosUbicacionService.eliminarUbicacion(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
