// enlaza a un usuario con su rol (trabajador o cliente)

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*

@Entity
@Table(name = "usuarios_roles")
data class UsuarioRol(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int? = null,

    @Column(name = "usuario_id", nullable = false)
    @JsonProperty("usuario_id")
    val usuarioId: Int,

    @Column(name = "rol_id", nullable = false)
    @JsonProperty("rol_id")
    val rolId: Long
)
