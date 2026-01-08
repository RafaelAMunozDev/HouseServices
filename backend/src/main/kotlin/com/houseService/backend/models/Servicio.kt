// representa un tipo de servicio disponible en la plataforma (ej: fontaneria, limpieza, etc)

package com.houseService.backend.models

import jakarta.persistence.*

@Entity
@Table(name = "servicios")
data class Servicio(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(nullable = false)
    val nombre: String = "",

    @Column
    val descripcion: String? = null,

    @Column(length = 50)
    val icono: String? = null,

    @Column(length = 7)
    val color: String = "#AAAAFF" // Valor por defecto
)
