package com.houseService.backend.controllers

import com.houseService.backend.dto.request.FCMTokenRequest
import com.houseService.backend.services.FCMTokensService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/usuarios/fcm-tokens")
class FCMTokensController(
    private val fcmTokensService: FCMTokensService
) {

    // guarda o actualiza el token fcm para un usuario
    @PostMapping
    fun registrarToken(
        @RequestParam usuarioId: Int,
        @RequestBody request: FCMTokenRequest
    ): ResponseEntity<*> {
        return try {
            val token = fcmTokensService.registrarToken(usuarioId, request)
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Token registrado correctamente",
                "token" to token
            ))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al registrar token: ${e.message}"))
        }
    }

    // desactiva el token fcm (se usa al cerrar sesion)
    @DeleteMapping("/{fcmToken}")
    fun desactivarToken(@PathVariable fcmToken: String): ResponseEntity<*> {
        return try {
            fcmTokensService.desactivarToken(fcmToken)
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Token desactivado correctamente"
            ))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al desactivar token: ${e.message}"))
        }
    }

    // devuelve los tokens activos de un usuario
    @GetMapping("/usuario/{usuarioId}")
    fun obtenerTokensUsuario(@PathVariable usuarioId: Int): ResponseEntity<*> {
        return try {
            val tokens = fcmTokensService.obtenerTokensActivos(usuarioId)
            ResponseEntity.ok(tokens)
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener tokens: ${e.message}"))
        }
    }

    // envia una notificacion de prueba, sirve pa testing
    @PostMapping("/test-notification")
    fun enviarNotificacionPrueba(
        @RequestParam usuarioId: Int,
        @RequestParam titulo: String,
        @RequestParam mensaje: String
    ): ResponseEntity<*> {
        return try {
            fcmTokensService.enviarNotificacionPrueba(usuarioId, titulo, mensaje)
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Notificación de prueba enviada"
            ))
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al enviar notificación: ${e.message}"))
        }
    }
}
