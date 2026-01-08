// guarda la info de un servicio que ha sido contratado por un cliente
// incluye fechas, estado y horario elegido

package com.houseService.backend.models

import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "servicios_contratados")
data class ServiciosContratados(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "cliente_id", nullable = false)
    @JsonProperty("cliente_id")
    val clienteId: Int = 0,

    @Column(name = "servicio_disponible_id", nullable = false)
    @JsonProperty("servicio_disponible_id")
    val servicioDisponibleId: Int = 0,

    @Column(name = "fecha_confirmada")
    @JsonProperty("fecha_confirmada")
    val fechaConfirmada: LocalDateTime? = null,

    @Column(name = "fecha_realizada")
    @JsonProperty("fecha_realizada")
    val fechaRealizada: LocalDateTime? = null,

    @Column(name = "estado_id", nullable = false)
    @JsonProperty("estado_id")
    val estadoId: Int = 0,

    @Column(name = "horario_seleccionado", nullable = false, columnDefinition = "JSON")
    @JsonProperty("horario_seleccionado")
    val horarioSeleccionado: String = "",

    @Column(name = "observaciones")
    val observaciones: String? = null
)
