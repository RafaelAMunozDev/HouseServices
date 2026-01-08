// representa un servicio que un trabajador ofrece, con su precio y detalles
// se relaciona con un tipo de servicio y un trabajador

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "servicios_disponibles")
data class ServicioDisponible(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "trabajador_id", nullable = false)
    @JsonProperty("trabajador_id")
    val trabajadorId: Int = 0,

    @Column(name = "servicio_id", nullable = false)
    @JsonProperty("servicio_id")
    val servicioId: Int = 0,

    @Column(name = "descripcion")
    val descripcion: String? = null,

    @Column(name = "observaciones")
    val observaciones: String? = null,

    @Column(name = "precio_hora")
    @JsonProperty("precio_hora")
    val precioHora: BigDecimal? = null,

    @Column(name = "fecha_creacion", nullable = false, updatable = false)
    @JsonProperty("fecha_creacion")
    val fechaCreacion: LocalDateTime = LocalDateTime.now(),

    @Column(name = "fecha_actualizacion", nullable = false)
    @JsonProperty("fecha_actualizacion")
    val fechaActualizacion: LocalDateTime = LocalDateTime.now()
)
