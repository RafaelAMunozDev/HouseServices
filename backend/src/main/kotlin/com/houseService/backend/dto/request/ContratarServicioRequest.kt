// contiene los datos para contratar un servicio
// se envia el id del servicio y el horario elegido

package com.houseService.backend.dto.request

import com.fasterxml.jackson.annotation.JsonProperty

data class ContratarServicioRequest(
    @JsonProperty("servicio_disponible_id")
    val servicioDisponibleId: Int,

    @JsonProperty("horario_seleccionado")
    val horarioSeleccionado: HorarioSeleccionado,

    val observaciones: String? = null
)

// representa el horario que el cliente selecciona para el servicio
// incluye fecha, hora de inicio y fin, dia de la semana y duracion

data class HorarioSeleccionado(
    val fecha: String, // "2025-05-24"
    @JsonProperty("dia_semana")
    val diaSemana: String, // "viernes"
    @JsonProperty("hora_inicio")
    val horaInicio: String, // "10:00"
    @JsonProperty("hora_fin")
    val horaFin: String, // "11:00"
    @JsonProperty("duracion_estimada_minutos")
    val duracionEstimadaMinutos: Int = 60
)

