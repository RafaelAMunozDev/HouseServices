// repositorio pa los estados ke puede tener un servicio (pendiente, completado, etc)

package com.houseService.backend.repositories

import com.houseService.backend.models.ServiciosEstados
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface ServiciosEstadosRepository : JpaRepository<ServiciosEstados, Int> {

    // busca un estado por su nombre exacto
    fun findByEstado(estado: String): ServiciosEstados?
}
