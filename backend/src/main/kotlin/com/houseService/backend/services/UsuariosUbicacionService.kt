package com.houseService.backend.services

import com.houseService.backend.models.UsuariosUbicacion
import com.houseService.backend.repositories.UsuariosUbicacionRepository
import org.springframework.stereotype.Service

@Service
class UsuariosUbicacionService(
    private val usuarioUbicacionRepository: UsuariosUbicacionRepository
) {

    // guarda una ubicacion del usuario
    fun guardarUbicacion(ubicacion: UsuariosUbicacion): UsuariosUbicacion {
        return usuarioUbicacionRepository.save(ubicacion)
    }

    // trae todas las ubicaciones de un usuario
    fun obtenerUbicacionesPorUsuario(usuarioId: Int): List<UsuariosUbicacion> {
        return usuarioUbicacionRepository.findByUsuarioId(usuarioId)
    }

    // busca una ubicacion por su id
    fun obtenerPorId(id: Int): UsuariosUbicacion? {
        return usuarioUbicacionRepository.findById(id).orElse(null)
    }

    // elimina una ubicacion segun el id
    fun eliminarUbicacion(id: Int) {
        usuarioUbicacionRepository.deleteById(id)
    }
}
