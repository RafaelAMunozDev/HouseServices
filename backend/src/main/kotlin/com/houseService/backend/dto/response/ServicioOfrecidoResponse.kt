package com.houseService.backend.dto.response

import com.fasterxml.jackson.annotation.JsonProperty
import java.math.BigDecimal
import java.time.LocalDateTime

data class ServicioOfrecidoResponse(
    val id: Int = 0,

    @JsonProperty("trabajador_id")
    val trabajadorId: Int = 0,

    @JsonProperty("nombre_trabajador")
    val nombreTrabajador: String = "",

    @JsonProperty("servicio_id")
    val servicioId: Int = 0,

    @JsonProperty("nombre_servicio")
    val nombreServicio: String = "",

    @JsonProperty("descripcion_servicio")
    val descripcionServicio: String? = null,

    val descripcion: String? = null,

    val observaciones: String? = null,

    @JsonProperty("precio_hora")
    val precioHora: BigDecimal? = null,

    val color: String = "#AAAAFF",

    @JsonProperty("valoracion_promedio")
    val valoracionPromedio: Double = 0.0,

    @JsonProperty("total_valoraciones")
    val totalValoraciones: Int = 0,

    @JsonProperty("icono_servicio")
    val icono: String = "work",

    @JsonProperty("url_imagen_perfil_trabajador")
    val urlImagenPerfilTrabajador: String? = null,

    @JsonProperty("fecha_creacion")  // 👈 AÑADIDO como pediste
    val fechaCreacion: LocalDateTime? = null,

    @JsonProperty("fecha_actualizacion")  // 👈 AÑADIDO del modelo
    val fechaActualizacion: LocalDateTime? = null
)