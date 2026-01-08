// ubicacion geografica de un usuario, se guarda por separado

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*

@Entity
@Table(name = "usuarios_ubicacion")
data class UsuariosUbicacion(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "usuario_id", nullable = false)
    @JsonProperty("usuario_id")
    val usuarioId: Int,

    @Column(nullable = true)
    val latitud: Double? = null,

    @Column(nullable = true)
    val longitud: Double? = null
)
