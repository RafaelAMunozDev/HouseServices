package com.houseService.backend.services

import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.databind.ObjectMapper
import com.houseService.backend.repositories.ServicioDisponibleHorarioRepository
import com.houseService.backend.repositories.ServicioDisponibleRepository
import org.springframework.stereotype.Service

@Service
class HorarioValidacionService(
    private val horarioRepository: ServicioDisponibleHorarioRepository,
    private val servicioRepository: ServicioDisponibleRepository,
    private val objectMapper: ObjectMapper
) {

    // valida si un nuevo horario entra en conflicto con otros ya registrados
    fun validarSolapamientoHorarios(
        trabajadorId: Int,
        nuevoHorarioJson: String,
        servicioIdExcluir: Int? = null
    ): ValidationResult {
        try {
            val serviciosDelTrabajador = servicioRepository.findByTrabajadorId(trabajadorId)
            val nuevoHorario = objectMapper.readValue(nuevoHorarioJson, HorarioData::class.java)

            for (servicio in serviciosDelTrabajador) {
                if (servicioIdExcluir != null && servicio.id == servicioIdExcluir) continue

                val horarioExistente = horarioRepository.findByServicioDisponibleId(servicio.id)
                if (horarioExistente != null) {
                    val horarioExistenteData = objectMapper.readValue(
                        horarioExistente.horarioJson,
                        HorarioData::class.java
                    )

                    val conflicto = verificarConflictoHorarios(nuevoHorario, horarioExistenteData)
                    if (conflicto != null) {
                        return ValidationResult(
                            valido = false,
                            mensaje = "conflicto en ${getDiaNombre(conflicto.dia)}: ${conflicto.detalle}. servicio: ${servicio.descripcion ?: "sin nombre"}"
                        )
                    }
                }
            }

            return ValidationResult(valido = true, mensaje = "")
        } catch (e: Exception) {
            return ValidationResult(
                valido = false,
                mensaje = "error al validar horarios: ${e.message}"
            )
        }
    }

    // comprueba si hay cruze entre 2 horarios
    private fun verificarConflictoHorarios(
        horario1: HorarioData,
        horario2: HorarioData
    ): ConflictoHorario? {
        val dias = listOf("lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo")

        for (dia in dias) {
            val rangos1 = horario1.horarioRegular[dia] ?: emptyList()
            val rangos2 = horario2.horarioRegular[dia] ?: emptyList()

            for (r1 in rangos1) {
                for (r2 in rangos2) {
                    if (rangosSeSuperponen(r1, r2)) {
                        return ConflictoHorario(
                            dia = dia,
                            detalle = "${r1.inicio}-${r1.fin} solapa con ${r2.inicio}-${r2.fin}"
                        )
                    }
                }
            }
        }

        return null
    }

    // comprueba si dos rangos de hora se cruzan
    private fun rangosSeSuperponen(r1: RangoHorario, r2: RangoHorario): Boolean {
        val i1 = convertirHoraAMinutos(r1.inicio)
        val f1 = convertirHoraAMinutos(r1.fin)
        val i2 = convertirHoraAMinutos(r2.inicio)
        val f2 = convertirHoraAMinutos(r2.fin)
        return (i1 < f2) && (f1 > i2)
    }

    // pasa "hh:mm" a minutos
    private fun convertirHoraAMinutos(hora: String): Int {
        val partes = hora.split(":")
        return partes[0].toInt() * 60 + partes[1].toInt()
    }

    // saca nombre bonito del dia
    private fun getDiaNombre(dia: String): String {
        return when (dia) {
            "lunes" -> "Lunes"
            "martes" -> "Martes"
            "miercoles" -> "Miércoles"
            "jueves" -> "Jueves"
            "viernes" -> "Viernes"
            "sabado" -> "Sábado"
            "domingo" -> "Domingo"
            else -> dia
        }
    }
}

// modelo pa representar un horario completo
data class HorarioData(
    @JsonProperty("horario_regular")
    val horarioRegular: Map<String, List<RangoHorario>> = emptyMap(),
    val excepciones: List<ExcepcionHorario> = emptyList()
)

// modelo pa definir un rango de hora
data class RangoHorario(
    val inicio: String = "",
    val fin: String = ""
)

// excepciones tipo festivos o ajustes
data class ExcepcionHorario(
    val fecha: String = "",
    val disponible: Boolean = false,
    val inicio: String? = null,
    val fin: String? = null
)

// resultado de la validacion
data class ValidationResult(
    val valido: Boolean,
    val mensaje: String
)

// info del conflicto de horario
data class ConflictoHorario(
    val dia: String,
    val detalle: String
)
