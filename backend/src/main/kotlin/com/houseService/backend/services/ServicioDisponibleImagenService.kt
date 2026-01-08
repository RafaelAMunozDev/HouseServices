// ServicioDisponibleImagenService.kt
package com.houseService.backend.services

import com.houseService.backend.models.ServicioDisponibleImagen
import com.houseService.backend.repositories.ServicioDisponibleImagenRepository
import com.houseService.backend.repositories.ServicioDisponibleRepository
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile

@Service
class ServicioDisponibleImagenService(
    private val servicioDisponibleImagenRepository: ServicioDisponibleImagenRepository,
    private val servicioDisponibleRepository: ServicioDisponibleRepository,
    private val firebaseStorageService: FirebaseStorageService
) {

    // saca todas las imagenes de un servicio
    fun obtenerImagenesServicio(servicioDisponibleId: Int): MutableList<ServicioDisponibleImagen> {
        return servicioDisponibleImagenRepository.findByServicioDisponibleId(servicioDisponibleId)
    }

    // guarda una imagen y la sube al firebase storage
    @Transactional
    fun guardarImagenServicio(file: MultipartFile, servicioDisponibleId: Int): ServicioDisponibleImagen {
        val servicioDisponible = servicioDisponibleRepository.findById(servicioDisponibleId)
            .orElseThrow { RuntimeException("El servicio disponible con ID $servicioDisponibleId no existe") }

        val usuarioId = servicioDisponible.trabajadorId

        val urlImagen = firebaseStorageService.subirImagenServicioDisponible(
            file,
            usuarioId,
            servicioDisponibleId
        )

        val imagen = ServicioDisponibleImagen(
            servicioDisponibleId = servicioDisponibleId,
            urlImagen = urlImagen
        )

        return servicioDisponibleImagenRepository.save(imagen)
    }

    // elimina una imagen por id
    @Transactional
    fun eliminarImagen(id: Int): Boolean {
        val imagen = servicioDisponibleImagenRepository.findById(id)

        if (imagen.isPresent) {
            firebaseStorageService.eliminarArchivo(imagen.get().urlImagen)
            servicioDisponibleImagenRepository.deleteById(id)
            return true
        }

        return false
    }

    // borra todas las imagenes de un servicio
    @Transactional
    fun eliminarTodasLasImagenesDeServicio(servicioDisponibleId: Int): Boolean {
        val imagenes = servicioDisponibleImagenRepository.findByServicioDisponibleId(servicioDisponibleId)

        if (imagenes.isNotEmpty()) {
            imagenes.forEach { firebaseStorageService.eliminarArchivo(it.urlImagen) }
            servicioDisponibleImagenRepository.deleteByServicioDisponibleId(servicioDisponibleId)
            return true
        }

        return false
    }
}
