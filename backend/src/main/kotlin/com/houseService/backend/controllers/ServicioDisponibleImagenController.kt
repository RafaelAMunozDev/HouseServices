package com.houseService.backend.controllers

import com.houseService.backend.models.ServicioDisponibleImagen
import com.houseService.backend.services.ServicioDisponibleImagenService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/api/servicios-disponibles/imagenes")
class ServicioDisponibleImagenController(
    private val servicioDisponibleImagenService: ServicioDisponibleImagenService
) {

    // devuelve las imagenes asociadas a un servicio disponible
    @GetMapping("/{servicioDisponibleId}")
    fun obtenerImagenesServicio(@PathVariable servicioDisponibleId: Int): ResponseEntity<List<ServicioDisponibleImagen>> {
        val imagenes = servicioDisponibleImagenService.obtenerImagenesServicio(servicioDisponibleId)
        return ResponseEntity.ok(imagenes)
    }

    // guarda una imagen subida para un servicio disponible
    @PostMapping("/{servicioDisponibleId}")
    fun subirImagenServicio(
        @PathVariable servicioDisponibleId: Int,
        @RequestParam("imagen") file: MultipartFile
    ): ResponseEntity<ServicioDisponibleImagen> {
        if (file.isEmpty) {
            return ResponseEntity.badRequest().build()
        }

        try {
            val imagen = servicioDisponibleImagenService.guardarImagenServicio(file, servicioDisponibleId)
            return ResponseEntity.ok(imagen)
        } catch (e: Exception) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build()
        }
    }

    // elimina una imagen por su id
    @DeleteMapping("/{id}")
    fun eliminarImagen(@PathVariable id: Int): ResponseEntity<Map<String, Any>> {
        val resultado = servicioDisponibleImagenService.eliminarImagen(id)

        return if (resultado) {
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Imagen eliminada correctamente"
            ))
        } else {
            ResponseEntity.notFound().build()
        }
    }

    // elimina todas las imagenes de un servicio
    @DeleteMapping("/servicio/{servicioDisponibleId}")
    fun eliminarTodasLasImagenesDeServicio(@PathVariable servicioDisponibleId: Int): ResponseEntity<Map<String, Any>> {
        val resultado = servicioDisponibleImagenService.eliminarTodasLasImagenesDeServicio(servicioDisponibleId)

        return ResponseEntity.ok(mapOf(
            "success" to true,
            "message" to if (resultado) "Imágenes eliminadas correctamente" else "No había imágenes para eliminar"
        ))
    }
}
