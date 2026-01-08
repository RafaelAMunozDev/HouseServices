// repositorio pa tipos de servicio ke se ofrecen

package com.houseService.backend.repositories

import com.houseService.backend.models.Servicio
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface ServicioRepository : JpaRepository<Servicio, Int> {

    // buscar un servicio por su nombre exacto
    fun findByNombre(nombre: String): Servicio?

    // buscar servicios ke contengan texto en el nombre
    fun findByNombreContainingIgnoreCase(texto: String): List<Servicio>

    // buscar servicios por color (pa temas visuales)
    fun findByColor(color: String): List<Servicio>
}
