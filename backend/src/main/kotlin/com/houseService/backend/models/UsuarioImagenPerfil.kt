// imagen de perfil del usuario, solo guarda la url

package com.houseService.backend.models

import jakarta.persistence.*

@Entity
@Table(name = "usuarios_imagenes_perfil")
data class UsuarioImagenPerfil(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "usuario_id", nullable = false)
    val usuarioId: Int,

    @Column(name = "url_imagen", nullable = false)
    var urlImagen: String
)
