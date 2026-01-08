// tabla para guardar los posibles estados de un servicio contratado

package com.houseService.backend.models

import jakarta.persistence.*

@Entity
@Table(name = "servicios_estados")
data class ServiciosEstados(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "estado", nullable = false, length = 50)
    val estado: String = ""
)
