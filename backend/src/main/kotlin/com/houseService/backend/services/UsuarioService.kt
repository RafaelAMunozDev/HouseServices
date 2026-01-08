package com.houseService.backend.services

import com.houseService.backend.models.Usuario
import com.houseService.backend.models.UsuarioRol
import com.houseService.backend.repositories.UsuarioRepository
import com.houseService.backend.repositories.UsuarioRolRepository
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import java.util.Optional

@Service
class UsuarioService(
    private val usuarioRepository: UsuarioRepository,
    private val eliminarUsuarioService: EliminarUsuarioService,
    private val usuarioRolRepository: UsuarioRolRepository
) {

    // trae todos los usuarios de la bd
    fun listarUsuarios(): List<Usuario> = usuarioRepository.findAll()

    // busca un usuario por su id
    fun obtenerPorId(id: Int): Usuario? = usuarioRepository.findById(id).orElse(null)

    // elimina un usuario usando el servicio de logica personalizada
    fun eliminar(id: Int): Boolean {
        return eliminarUsuarioService.eliminarUsuarioYReasignar(id)
    }

    // verifica si existe un usuario por id
    fun existePorId(id: Int): Boolean {
        return usuarioRepository.existsById(id)
    }

    // busca un usuario por su uid de firebase
    fun findByFirebaseUid(firebaseUid: String): Optional<Usuario> {
        return usuarioRepository.findByFirebaseUid(firebaseUid)
    }

    // verifica si ya existe un dni en la bd
    fun existeDni(dni: String): Boolean {
        return usuarioRepository.existsByDni(dni)
    }

    // guarda o actualiza un usuario
    fun save(usuario: Usuario): Usuario {
        return usuarioRepository.save(usuario)
    }

    // busca un usuario por su correo
    fun findByCorreo(correo: String): Optional<Usuario> =
        usuarioRepository.findByCorreo(correo)

    // busca el correo para comprobar si existe
    fun existeCorreo(correo: String): Boolean {
        val correoLimpio = correo.trim().lowercase()

        return usuarioRepository.existsByCorreo(correoLimpio)
    }

    // busca el telefono para comprobar si existe
    fun existeTelefono(telefono: String): Boolean {
        val telefonoLimpio = telefono.trim()

        return usuarioRepository.existsByTelefono(telefonoLimpio)
    }
    // asigna el rol de usuario normal (id 2)
    @Transactional
    fun asignarRolUsuario(usuario: Usuario) {
        if (usuarioRolRepository.existsByUsuarioIdAndRolId(usuario.id, 2L)) {
            return
        }

        val usuarioRol = UsuarioRol(
            usuarioId = usuario.id,
            rolId = 2L
        )

        usuarioRolRepository.save(usuarioRol)
    }

    // verifica si tiene rol de trabajador (id 3)
    fun tieneRolTrabajador(usuario: Usuario): Boolean {
        return usuarioRolRepository.existsByUsuarioIdAndRolId(usuario.id, 3L)
    }

    // asigna el rol de trabajador (id 3)
    @Transactional
    fun asignarRolTrabajador(usuario: Usuario) {
        if (tieneRolTrabajador(usuario)) {
            return
        }

        val usuarioRol = UsuarioRol(
            usuarioId = usuario.id,
            rolId = 3L
        )

        usuarioRolRepository.save(usuarioRol)
    }

    // quita el rol de trabajador si lo tiene
    @Transactional
    fun quitarRolTrabajador(usuario: Usuario): Boolean {
        val usuarioRol = usuarioRolRepository.findByUsuarioIdAndRolId(usuario.id, 3L)

        if (usuarioRol != null) {
            usuarioRolRepository.delete(usuarioRol)
            return true
        }

        return false
    }

}
