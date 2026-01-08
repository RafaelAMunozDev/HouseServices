package com.houseService.backend.services

import com.houseService.backend.models.UsuarioImagenPerfil
import com.houseService.backend.repositories.UsuarioImagenPerfilRepository
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import java.util.Optional

@Service
class UsuarioImagenPerfilService(
    private val usuarioImagenPerfilRepository: UsuarioImagenPerfilRepository,
    private val firebaseStorageService: FirebaseStorageService,
    private val usuarioService: UsuarioService
) {

    // trae la imagen de perfil si existe
    fun obtenerImagenPerfil(usuarioId: Int): Optional<UsuarioImagenPerfil> {
        return usuarioImagenPerfilRepository.findByUsuarioId(usuarioId)
    }

    // guarda o actualiza la imagen de perfil
    @Transactional
    fun guardarImagenPerfil(file: MultipartFile, usuarioId: Int): UsuarioImagenPerfil {
        // verificar que el usuario exista
        val usuario = usuarioService.obtenerPorId(usuarioId)
            ?: throw RuntimeException("el usuario con ID $usuarioId no existe")

        // subir la nueva imagen a firebase
        val urlImagen = firebaseStorageService.subirImagenPerfil(file, usuarioId)

        // si ya habia una imagen se reemplaza
        val imagenExistente = usuarioImagenPerfilRepository.findByUsuarioId(usuarioId)
        if (imagenExistente.isPresent) {
            firebaseStorageService.eliminarArchivo(imagenExistente.get().urlImagen)
            val imagen = imagenExistente.get()
            imagen.urlImagen = urlImagen
            return usuarioImagenPerfilRepository.save(imagen)
        }

        // si no habia imagen, se crea una nueva
        val nuevaImagen = UsuarioImagenPerfil(
            usuarioId = usuarioId,
            urlImagen = urlImagen
        )
        return usuarioImagenPerfilRepository.save(nuevaImagen)
    }

    // elimina la imagen de perfil
    @Transactional
    fun eliminarImagenPerfil(usuarioId: Int): Boolean {
        val imagen = usuarioImagenPerfilRepository.findByUsuarioId(usuarioId)

        if (imagen.isPresent) {
            firebaseStorageService.eliminarArchivo(imagen.get().urlImagen)
            usuarioImagenPerfilRepository.deleteByUsuarioId(usuarioId)
            return true
        }

        return false
    }
}
