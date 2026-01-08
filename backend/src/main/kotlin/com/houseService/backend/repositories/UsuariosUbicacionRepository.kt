package com.houseService.backend.repositories

import com.houseService.backend.models.UsuariosUbicacion
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface UsuariosUbicacionRepository : JpaRepository<UsuariosUbicacion, Int> {

    fun findByUsuarioId(usuarioId: Int): List<UsuariosUbicacion>
}