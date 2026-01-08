// repositorio pa los servicios ke se han contratadoo

package com.houseService.backend.repositories

import com.houseService.backend.models.ServiciosContratados
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface ServiciosContratadosRepository : JpaRepository<ServiciosContratados, Int> {

    // trae todos los servicios de un cliente
    fun findByClienteId(clienteId: Int): List<ServiciosContratados>

    // servicios segun su estado (pendiente, confirmado...)
    fun findByEstadoId(estadoId: Int): List<ServiciosContratados>

    // servicios ke han sido ofertados por un trabajador
    @Query("""
        SELECT sc FROM ServiciosContratados sc 
        JOIN ServicioDisponible sd ON sc.servicioDisponibleId = sd.id 
        WHERE sd.trabajadorId = :trabajadorId
    """)
    fun findByTrabajadorId(trabajadorId: Int): List<ServiciosContratados>

    // trae servicios en cierto estado para un trabajador
    @Query("""
        SELECT sc FROM ServiciosContratados sc 
        JOIN ServicioDisponible sd ON sc.servicioDisponibleId = sd.id 
        WHERE sd.trabajadorId = :trabajadorId AND sc.estadoId = :estadoId
    """)
    fun findByTrabajadorIdAndEstadoId(trabajadorId: Int, estadoId: Int): List<ServiciosContratados>

    // busca reservas activas por fecha pa evitar solapes
    @Query(
        value = """
        SELECT *
        FROM servicios_contratados
        WHERE servicio_disponible_id = :servicioDisponibleId
        AND estado_id NOT IN (3, 6)
        AND JSON_UNQUOTE(JSON_EXTRACT(horario_seleccionado, '$.fecha')) = :fecha
    """,
        nativeQuery = true
    )
    fun findReservationsByServiceAndDate(
        @Param("servicioDisponibleId") servicioDisponibleId: Int,
        @Param("fecha") fecha: String
    ): List<ServiciosContratados>
}
