package com.houseService.backend.controllers

import com.houseService.backend.models.UsuarioImagenPerfil
import com.houseService.backend.services.UsuarioImagenPerfilService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/api/usuarios/imagenes/perfil")
class UsuarioImagenPerfilController(
    private val usuarioImagenPerfilService: UsuarioImagenPerfilService
) {

    // devuelve la imagen de perfil de un usuario si existe
    @GetMapping("/{usuarioId}")
    fun obtenerImagenPerfil(@PathVariable usuarioId: Int): ResponseEntity<UsuarioImagenPerfil> {
        val imagen = usuarioImagenPerfilService.obtenerImagenPerfil(usuarioId)
        return if (imagen.isPresent) ResponseEntity.ok(imagen.get())
        else ResponseEntity.notFound().build()
    }

    // sube una nueva imagen de perfil para el usuario
    @PostMapping("/{usuarioId}")
    fun subirImagenPerfil(
        @PathVariable usuarioId: Int,
        @RequestParam("imagen") file: MultipartFile
    ): ResponseEntity<UsuarioImagenPerfil> {
        if (file.isEmpty) {
            return ResponseEntity.badRequest().build()
        }

        try {
            val imagen = usuarioImagenPerfilService.guardarImagenPerfil(file, usuarioId)
            return ResponseEntity.ok(imagen)
        } catch (e: Exception) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()
        }
    }

    // elimina la imagen de perfil de un usuario si existe
    @DeleteMapping("/{usuarioId}")
    fun eliminarImagenPerfil(@PathVariable usuarioId: Int): ResponseEntity<Map<String, Any>> {
        val resultado = usuarioImagenPerfilService.eliminarImagenPerfil(usuarioId)

        return if (resultado) {
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Imagen de perfil eliminada correctamente"
            ))
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
