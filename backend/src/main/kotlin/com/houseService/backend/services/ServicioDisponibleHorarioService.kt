// ServicioDisponibleHorarioService.kt
package com.houseService.backend.services

import com.houseService.backend.models.ServicioDisponibleHorario
import com.houseService.backend.repositories.ServicioDisponibleHorarioRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class ServicioDisponibleHorarioService(
    private val horarioRepository: ServicioDisponibleHorarioRepository
) {

    // saca el horario de un servicio
    fun obtenerHorarioPorServicio(servicioDisponibleId: Int): ServicioDisponibleHorario? {
        return horarioRepository.findByServicioDisponibleId(servicioDisponibleId)
    }

    // guarda el horario (si ya hay uno lo reemplaza)
    @Transactional
    fun guardarHorario(servicioDisponibleId: Int, horarioJson: String): ServicioDisponibleHorario {
        horarioRepository.deleteByServicioDisponibleId(servicioDisponibleId)

        val nuevoHorario = ServicioDisponibleHorario(
            servicioDisponibleId = servicioDisponibleId,
            horarioJson = horarioJson
        )

        return horarioRepository.save(nuevoHorario)
    }

    // borra el horario de un servicio
    @Transactional
    fun eliminarHorario(servicioDisponibleId: Int): Boolean {
        return try {
            horarioRepository.deleteByServicioDisponibleId(servicioDisponibleId)
            true
        } catch (e: Exception) {
            false
        }
    }
}
