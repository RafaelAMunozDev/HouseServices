// valoracion de un servicio, hecha por un cliente hacia un trabajador

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "valoraciones")
data class Valoraciones(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "servicio_contratado_id", nullable = false, unique = true)
    @JsonProperty("servicio_contratado_id")
    val servicioContratadoId: Int = 0,

    @Column(name = "cliente_id", nullable = false)
    @JsonProperty("cliente_id")
    val clienteId: Int = 0,

    @Column(name = "puntuacion", nullable = false)
    val puntuacion: Int = 0,

    @Column(name = "comentario")
    val comentario: String? = null,

    @Column(name = "trabajador_id", nullable = true)
    @JsonProperty("trabajador_id")
    val trabajadorId: Int? = null,

    @Column(name = "fecha_valoracion")
    @JsonProperty("fecha_valoracion")
    val fechaValoracion: LocalDateTime = LocalDateTime.now()
)
