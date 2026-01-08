// guarda el horario disponible de un servicio en formato json
// se enlaza con un servicio ofrecido por un trabajador

package com.houseService.backend.models

import jakarta.persistence.*

@Entity
@Table(name = "servicios_disponibles_horarios")
data class ServicioDisponibleHorario(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "servicio_disponible_id", nullable = false)
    val servicioDisponibleId: Int = 0,

    @Column(name = "horario_json", nullable = false, columnDefinition = "JSON")
    val horarioJson: String = ""
)
