// datos necesarios para crear una valoracion a un trabajador
// se envia el id del servicio, puntuacion y comentario

package com.houseService.backend.dto.request

import com.fasterxml.jackson.annotation.JsonProperty

data class CrearValoracionRequest(
    @JsonProperty("servicio_contratado_id")
    val servicioContratadoId: Int,

    @JsonProperty("trabajador_id")
    val trabajadorId: Int,

    val puntuacion: Int,

    val comentario: String
)
