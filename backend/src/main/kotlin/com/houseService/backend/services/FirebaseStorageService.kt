package com.houseService.backend.services

import com.google.firebase.cloud.StorageClient
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile
import java.util.UUID

@Service
class FirebaseStorageService {

    private val logger = LoggerFactory.getLogger(FirebaseStorageService::class.java)
    private val bucketName = "houseservices-7f45b.firebasestorage.app"

    // sube imagen de perfil al storage y devuelve la url
    fun subirImagenPerfil(file: MultipartFile, usuarioId: Int): String {
        val extension = obtenerExtension(file.originalFilename)
        val nombreArchivo = "usuario_${usuarioId}_${UUID.randomUUID()}.$extension"
        val path = "usuarios/$usuarioId/perfil/$nombreArchivo"
        return subirArchivo(file, path)
    }

    // sube imagen de un servicio disponible y devuelve la url
    fun subirImagenServicioDisponible(file: MultipartFile, usuarioId: Int, servicioDisponibleId: Int): String {
        val extension = obtenerExtension(file.originalFilename)
        val nombreArchivo = "usuario_${usuarioId}_servicio_${servicioDisponibleId}_${UUID.randomUUID()}.$extension"
        val path = "servicios_disponibles/$servicioDisponibleId/galeria/$nombreArchivo"
        return subirArchivo(file, path)
    }

    // sube el archivo al bucket y devuelve su url publica
    private fun subirArchivo(file: MultipartFile, path: String): String {
        return try {
            val storage = StorageClient.getInstance().bucket(bucketName)
            val blob = storage.create(path, file.bytes, file.contentType)

            val encodedPath = path.split("/").joinToString("%2F") { it.encodeURLComponent() }
            "https://firebasestorage.googleapis.com/v0/b/$bucketName/o/$encodedPath?alt=media"
        } catch (e: Exception) {
            logger.error("error al subir archivo a firebase", e)
            throw RuntimeException("no se pudo subir archivo: ${e.message}")
        }
    }

    // elimina archivo de storage segun su url
    fun eliminarArchivo(url: String) {
        try {
            val path = url.substringAfter("$bucketName/")
            val storage = StorageClient.getInstance().bucket(bucketName)
            storage.get(path)?.delete()
        } catch (e: Exception) {
            logger.error("error al eliminar archivo del storage", e)
        }
    }

    // saca la extension del archivo, por defecto "jpg"
    private fun obtenerExtension(fileName: String?): String {
        return fileName?.substringAfterLast('.', "jpg") ?: "jpg"
    }
}

// funcion auxiliar pa codificar ruta en url
private fun String.encodeURLComponent(): String {
    return java.net.URLEncoder.encode(this, "UTF-8")
}
