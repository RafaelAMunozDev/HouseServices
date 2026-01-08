// repo pa manejar los datos principales del usuario

package com.houseService.backend.repositories

import com.houseService.backend.models.Usuario
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface UsuarioRepository : JpaRepository<Usuario, Int> {

    fun findByFirebaseUid(firebaseUid: String): Optional<Usuario>

    fun findByDni(dni: String): Usuario?

    fun existsByDni(dni: String): Boolean

    fun existsByCorreo(correo: String): Boolean

    // comprueba si ya existe un telefono en bd
    fun existsByTelefono(telefono: String): Boolean

    fun findByCorreo(correo: String): Optional<Usuario>

    fun findByTelefono(telefono: String): Usuario?
}
