// consulta y guarda los servicios q ofrece un trabajador

package com.houseService.backend.repositories

import com.houseService.backend.models.ServicioDisponible
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface ServicioDisponibleRepository : JpaRepository<ServicioDisponible, Int> {

    fun findByTrabajadorId(trabajadorId: Int): List<ServicioDisponible>

    // permite ejecutar una consulta sql cruda
    @Query(value = "?1", nativeQuery = true)
    fun findByCustomQuery(@Param("query") query: String): List<ServicioDisponible>
}
