package com.houseService.backend.controllers

import com.houseService.backend.models.Usuario
import com.houseService.backend.services.UsuarioService
import com.houseService.backend.repositories.UsuarioRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/usuarios")
class UsuarioController(
    private val usuarioService: UsuarioService,
    private val usuarioRepository: UsuarioRepository
) {

    // devuelve todos los usuarios
    @GetMapping
    fun listar(): List<Usuario> = usuarioService.listarUsuarios()

    // devuelve un usuario por su id
    @GetMapping("/{id}")
    fun obtenerPorId(@PathVariable id: Int): ResponseEntity<Usuario> {
        val usuario = usuarioService.obtenerPorId(id)
        return if (usuario != null) ResponseEntity.ok(usuario)
        else ResponseEntity.notFound().build()
    }

    // crea un nuevo usuario si el dni y telefono no estan repetidos
    @PostMapping
    fun crear(@RequestBody usuario: Usuario): ResponseEntity<Any> {
        if (usuario.dni != null && usuarioService.existeDni(usuario.dni!!)) {
            return ResponseEntity.badRequest().body("El DNI ya está registrado")
        }

        if (usuario.telefono != null && usuarioService.existeTelefono(usuario.telefono!!)) {
            return ResponseEntity.badRequest().body("El teléfono ya está registrado")
        }

        return ResponseEntity.ok(usuarioService.save(usuario))
    }

    // actualiza los datos de un usuario y valida que no repita dni ni telefono
    @PutMapping("/{id}")
    fun actualizar(@PathVariable id: Int, @RequestBody usuarioActualizado: Usuario): ResponseEntity<Any> {
        val existente = usuarioService.obtenerPorId(id)
        return if (existente != null) {
            if (usuarioActualizado.dni != null &&
                usuarioActualizado.dni != existente.dni &&
                usuarioService.existeDni(usuarioActualizado.dni!!)) {
                return ResponseEntity.badRequest().body("El DNI ya está registrado")
            }

            if (usuarioActualizado.telefono != null &&
                usuarioActualizado.telefono != existente.telefono &&
                usuarioService.existeTelefono(usuarioActualizado.telefono!!)) {
                return ResponseEntity.badRequest().body("El teléfono ya está registrado")
            }

            val usuarioConId = usuarioActualizado.copy(id = id)
            ResponseEntity.ok(usuarioService.save(usuarioConId))
        } else {
            ResponseEntity.notFound().build()
        }
    }

    // verifica si un telefono esta ya registrado por otro usuario
    @GetMapping("/existe-telefono/{telefono}")
    fun existeTelefono(
        @PathVariable telefono: String,
        @RequestParam(required = false) usuarioIdActual: Int?
    ): ResponseEntity<Boolean> {
        val usuario = usuarioRepository.findByTelefono(telefono)

        if (usuario == null) {
            return ResponseEntity.ok(false)
        }

        if (usuarioIdActual != null && usuario.id == usuarioIdActual) {
            return ResponseEntity.ok(false)
        }

        return ResponseEntity.ok(true)
    }

    // elimina un usuario si existe
    @DeleteMapping("/{id}")
    fun eliminar(@PathVariable id: Int): ResponseEntity<Map<String, Any>> {
        return if (usuarioService.existePorId(id)) {
            val resultado = usuarioService.eliminar(id)
            if (resultado) {
                ResponseEntity.ok(mapOf(
                    "success" to true,
                    "message" to "Usuario eliminado correctamente"
                ))
            } else {
                ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    mapOf(
                        "success" to false,
                        "message" to "Error al eliminar el usuario"
                    )
                )
            }
        } else {
            ResponseEntity.notFound().build()
        }
    }

    // verifica si un dni ya existe, permite excluir el actual
    @GetMapping("/existe-dni/{dni}")
    fun existeDni(
        @PathVariable dni: String,
        @RequestParam(required = false) firebaseUidActual: String?
    ): ResponseEntity<Boolean> {
        val usuario = usuarioRepository.findByDni(dni)

        if (usuario == null) {
            return ResponseEntity.ok(false)
        }

        if (firebaseUidActual != null && usuario.firebaseUid == firebaseUidActual) {
            return ResponseEntity.ok(false)
        }

        return ResponseEntity.ok(true)
    }

    // actualiza el campo primerInicio segun el valor enviado
    @PutMapping("/{id}/actualizar-primer-inicio")
    fun actualizarPrimerInicio(@PathVariable id: Int, @RequestBody request: Map<String, Int>): ResponseEntity<Map<String, Any>> {
        val usuario = usuarioService.obtenerPorId(id)

        if (usuario != null) {
            usuario.primerInicio = request["primerInicio"] ?: 1
            usuarioService.save(usuario)

            return ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Primer inicio actualizado correctamente"
            ))
        }

        return ResponseEntity.notFound().build()
    }
}
