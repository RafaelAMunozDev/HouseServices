// repo ke maneja los roles de cada usuario (cliente o trabajador)

package com.houseService.backend.repositories

import com.houseService.backend.models.UsuarioRol
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface UsuarioRolRepository : JpaRepository<UsuarioRol, Int> {

    fun findByUsuarioId(usuarioId: Int): List<UsuarioRol>

    fun findByUsuarioIdAndRolId(usuarioId: Int, rolId: Long): UsuarioRol?

    fun existsByUsuarioIdAndRolId(usuarioId: Int, rolId: Long): Boolean
}
