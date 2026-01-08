// maneja las imagenes asociadas a cada servicio disponible

package com.houseService.backend.repositories

import com.houseService.backend.models.ServicioDisponibleImagen
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.List

@Repository
interface ServicioDisponibleImagenRepository : JpaRepository<ServicioDisponibleImagen, Int> {

    fun findByServicioDisponibleId(servicioDisponibleId: Int): MutableList<ServicioDisponibleImagen>

    fun existsByServicioDisponibleId(servicioDisponibleId: Int): Boolean

    fun deleteByServicioDisponibleId(servicioDisponibleId: Int)
}
