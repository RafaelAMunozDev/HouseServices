// se usa para registrar o actualizar el token fcm de un usuario
// incluye el token y la plataforma desde la que se envia

package com.houseService.backend.dto.request

import com.fasterxml.jackson.annotation.JsonProperty
import com.houseService.backend.models.Plataforma

data class FCMTokenRequest(
    @JsonProperty("fcm_token")
    val fcmToken: String,

    val plataforma: Plataforma
)
