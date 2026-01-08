// repo pa manejar las imagenes de perfil de los usuarios

package com.houseService.backend.repositories

import com.houseService.backend.models.UsuarioImagenPerfil
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface UsuarioImagenPerfilRepository : JpaRepository<UsuarioImagenPerfil, Int> {

    fun findByUsuarioId(usuarioId: Int): Optional<UsuarioImagenPerfil>

    fun existsByUsuarioId(usuarioId: Int): Boolean

    fun deleteByUsuarioId(usuarioId: Int)
}
