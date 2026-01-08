// repositorio pa los horarios de servicios disponibles

package com.houseService.backend.repositories

import com.houseService.backend.models.ServicioDisponibleHorario
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional

@Repository
interface ServicioDisponibleHorarioRepository : JpaRepository<ServicioDisponibleHorario, Int> {
    fun findByServicioDisponibleId(servicioDisponibleId: Int): ServicioDisponibleHorario?

    @Modifying
    @Transactional
    @Query("DELETE FROM ServicioDisponibleHorario h WHERE h.servicioDisponibleId = :servicioDisponibleId")
    fun deleteByServicioDisponibleId(servicioDisponibleId: Int)
}
