package com.houseService.backend.controllers

import com.houseService.backend.services.UsuarioService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/usuarios")
class RolController(private val usuarioService: UsuarioService) {

    // devuelve si el usuario tiene rol de trabajador
    @GetMapping("/{id}/es-trabajador")
    fun esTrabajador(@PathVariable id: Int): ResponseEntity<Map<String, Any>> {
        val usuario = usuarioService.obtenerPorId(id)

        if (usuario == null) {
            return ResponseEntity.notFound().build()
        }

        val esTrabajador = usuarioService.tieneRolTrabajador(usuario)

        return ResponseEntity.ok(mapOf(
            "esTrabajador" to esTrabajador
        ))
    }

    // asigna el rol de trabajador si el usuario aun no lo tiene
    @PostMapping("/{id}/asignar-trabajador")
    fun asignarRolTrabajador(@PathVariable id: Int): ResponseEntity<Map<String, Any>> {
        val usuario = usuarioService.obtenerPorId(id)

        if (usuario == null) {
            return ResponseEntity.notFound().build()
        }

        // si ya tiene el rol, no se vuelve a asignar
        if (usuarioService.tieneRolTrabajador(usuario)) {
            return ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "El usuario ya tiene el rol de trabajador"
            ))
        }

        usuarioService.asignarRolTrabajador(usuario)

        return ResponseEntity.ok(mapOf(
            "success" to true,
            "message" to "Rol de trabajador asignado correctamente"
        ))
    }

    // quita el rol de trabajador si lo tiene
    @DeleteMapping("/{id}/quitar-trabajador")
    fun quitarRolTrabajador(@PathVariable id: Int): ResponseEntity<Map<String, Any>> {
        val usuario = usuarioService.obtenerPorId(id)

        if (usuario == null) {
            return ResponseEntity.notFound().build()
        }

        val resultado = usuarioService.quitarRolTrabajador(usuario)

        return if (resultado) {
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Rol de trabajador eliminado correctamente"
            ))
        } else {
            ResponseEntity.ok(mapOf(
                "success" to false,
                "message" to "El usuario no tenía el rol de trabajador"
            ))
        }
    }
}
