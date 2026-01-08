// guarda los tokens fcm para enviar notis push, uno por dispositivo/plataforma

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*

@Entity
@Table(name = "usuarios_fcm_tokens")
data class UsuariosFcmTokens(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "usuario_id", nullable = false)
    @JsonProperty("usuario_id")
    val usuarioId: Int = 0,

    @Column(name = "fcm_token", nullable = false, length = 500)
    @JsonProperty("fcm_token")
    val fcmToken: String = "",

    @Enumerated(EnumType.STRING)
    @Column(name = "plataforma", nullable = false)
    val plataforma: Plataforma = Plataforma.android,

    @Column(name = "activo", nullable = false)
    val activo: Int = 1 // 0 = inactivo, 1 = activo
)

enum class Plataforma {
    @JsonProperty("android") android,
    @JsonProperty("ios") ios,
    @JsonProperty("web") web
}
