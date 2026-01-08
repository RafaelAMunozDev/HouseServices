package com.houseService.backend.services

import com.houseService.backend.dto.request.FCMTokenRequest
import com.houseService.backend.models.UsuariosFcmTokens
import com.houseService.backend.repositories.UsuariosFcmTokensRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class FCMTokensService(
    private val fcmTokensRepository: UsuariosFcmTokensRepository,
    private val fcmService: FCMService
) {

    // guarda o actualiza un token fcm segun si ya existe o no
    @Transactional
    fun registrarToken(usuarioId: Int, request: FCMTokenRequest): UsuariosFcmTokens {
        val tokenExistente = fcmTokensRepository.findByFcmToken(request.fcmToken)

        return if (tokenExistente != null) {
            val tokenActualizado = tokenExistente.copy(
                usuarioId = usuarioId,
                plataforma = request.plataforma,
                activo = 1
            )
            fcmTokensRepository.save(tokenActualizado)
        } else {
            val nuevoToken = UsuariosFcmTokens(
                usuarioId = usuarioId,
                fcmToken = request.fcmToken,
                plataforma = request.plataforma,
                activo = 1
            )
            fcmTokensRepository.save(nuevoToken)
        }
    }

    // pone un token como inactivo si existe
    @Transactional
    fun desactivarToken(fcmToken: String) {
        val token = fcmTokensRepository.findByFcmToken(fcmToken)
        if (token != null) {
            val tokenDesactivado = token.copy(activo = 0)
            fcmTokensRepository.save(tokenDesactivado)
        }
    }

    // devuelve lista de tokens activos de un usuario
    fun obtenerTokensActivos(usuarioId: Int): List<UsuariosFcmTokens> {
        return fcmTokensRepository.findByUsuarioIdAndActivo(usuarioId, 1)
    }

    // prueba para enviar noti directa a un usuario
    fun enviarNotificacionPrueba(usuarioId: Int, titulo: String, mensaje: String) {
        fcmService.enviarNotificacionAUsuario(usuarioId, titulo, mensaje)
    }
}
