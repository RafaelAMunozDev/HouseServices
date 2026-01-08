package com.houseService.backend.repositories

import com.houseService.backend.models.Valoraciones
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface ValoracionesRepository : JpaRepository<Valoraciones, Int> {

    // Valoraciones de un cliente
    fun findByClienteId(clienteId: Int): List<Valoraciones>

    // Valoración específica de un servicio
    fun findByServicioContratadoId(servicioContratadoId: Int): Valoraciones?

    // Verificar si ya existe valoración
    fun existsByServicioContratadoId(servicioContratadoId: Int): Boolean
}