// repo pa guardar y desactivar tokens de notificaciones push (FCM)

package com.houseService.backend.repositories

import com.houseService.backend.models.UsuariosFcmTokens
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface UsuariosFcmTokensRepository : JpaRepository<UsuariosFcmTokens, Int> {

    // trae los tokens activos de un usuario
    fun findByUsuarioIdAndActivo(usuarioId: Int, activo: Int): List<UsuariosFcmTokens>

    // busca token especifico
    fun findByFcmToken(fcmToken: String): UsuariosFcmTokens?

    // marca un token como inactivo (logout)
    @Query("UPDATE UsuariosFcmTokens u SET u.activo = 0 WHERE u.fcmToken = :token")
    fun desactivarToken(token: String)
}
