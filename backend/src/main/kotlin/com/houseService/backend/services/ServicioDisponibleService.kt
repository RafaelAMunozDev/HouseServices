// ServicioDisponibleService.kt

package com.houseService.backend.services

import com.google.firebase.cloud.StorageClient
import com.houseService.backend.dto.response.ServicioOfrecidoResponse
import com.houseService.backend.models.ServicioDisponible
import com.houseService.backend.repositories.ServicioDisponibleRepository
import com.houseService.backend.repositories.ServicioRepository
import com.houseService.backend.repositories.UsuarioImagenPerfilRepository
import com.houseService.backend.repositories.UsuarioRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.net.URLEncoder

@Service
class ServicioDisponibleService(
    private val servicioDisponibleRepository: ServicioDisponibleRepository,
    private val servicioRepository: ServicioRepository,
    private val usuarioRepository: UsuarioRepository,
    private val usuarioImagenPerfilRepository: UsuarioImagenPerfilRepository,
    private val valoracionesService: ValoracionesService
) {

    // saca todos los servicios ofrecidos que no sean del user eliminado
    @Transactional(readOnly = true)
    fun obtenerTodosLosServiciosOfrecidos(): List<ServicioOfrecidoResponse> {
        val serviciosDisponibles = servicioDisponibleRepository.findAll()
            .filter { it.trabajadorId != -1 }
        return serviciosDisponibles.map { construirDTO(it) }
    }

    // saca un servicio especifico por id
    @Transactional(readOnly = true)
    fun obtenerServicioOfrecidoPorId(id: Int): ServicioOfrecidoResponse? {
        val servicioDisponible = servicioDisponibleRepository.findById(id).orElse(null) ?: return null
        return construirDTO(servicioDisponible)
    }

    // saca todos los servicios de un trabajador
    @Transactional(readOnly = true)
    fun obtenerServiciosOfrecidosPorTrabajador(trabajadorId: Int): List<ServicioOfrecidoResponse> {
        val serviciosDisponibles = servicioDisponibleRepository.findByTrabajadorId(trabajadorId)
        return serviciosDisponibles.map { construirDTO(it) }
    }

    // guarda un nuevo servicio
    @Transactional
    fun crearServicioDisponible(servicioDisponible: ServicioDisponible): ServicioDisponible {
        if (!usuarioRepository.existsById(servicioDisponible.trabajadorId)) {
            throw IllegalArgumentException("El trabajador con ID ${servicioDisponible.trabajadorId} no existe")
        }

        if (!servicioRepository.existsById(servicioDisponible.servicioId)) {
            throw IllegalArgumentException("El servicio con ID ${servicioDisponible.servicioId} no existe")
        }

        return servicioDisponibleRepository.save(servicioDisponible)
    }

    // actualiza un servicio ya creado
    @Transactional
    fun actualizarServicioDisponible(id: Int, servicioDisponible: ServicioDisponible): ServicioDisponible {
        if (!servicioDisponibleRepository.existsById(id)) {
            throw IllegalArgumentException("El servicio disponible con ID $id no existe")
        }

        if (!usuarioRepository.existsById(servicioDisponible.trabajadorId)) {
            throw IllegalArgumentException("El trabajador con ID ${servicioDisponible.trabajadorId} no existe")
        }

        if (!servicioRepository.existsById(servicioDisponible.servicioId)) {
            throw IllegalArgumentException("El servicio con ID ${servicioDisponible.servicioId} no existe")
        }

        val servicioActualizado = servicioDisponible.copy(id = id)

        return servicioDisponibleRepository.save(servicioActualizado)
    }

    // borra un servicio por su id
    @Transactional
    fun eliminarServicioDisponible(id: Int) {
        if (!servicioDisponibleRepository.existsById(id)) {
            throw IllegalArgumentException("El servicio disponible con ID $id no existe")
        }

        servicioDisponibleRepository.deleteById(id)
    }

    // construye un dto de respuesta con todos los datos
    private fun construirDTO(servicioDisponible: ServicioDisponible): ServicioOfrecidoResponse {
        val servicio = servicioRepository.findById(servicioDisponible.servicioId).orElse(null)
        val trabajador = usuarioRepository.findById(servicioDisponible.trabajadorId).orElse(null)

        val nombreTrabajador = if (trabajador != null) {
            buildString {
                append(trabajador.nombre)
                append(" ")
                append(trabajador.apellido1)
                trabajador.apellido2?.let { append(" $it") }
            }.trim()
        } else {
            ""
        }

        var urlImagenPerfil: String? = null
        if (trabajador != null) {
            val imagenPerfil = usuarioImagenPerfilRepository.findByUsuarioId(trabajador.id)
            if (imagenPerfil.isPresent) {
                urlImagenPerfil = convertirURLFirebase(imagenPerfil.get().urlImagen)
            }
        }

        var valoracionPromedio = 0.0
        var totalValoraciones = 0

        try {
            val valoraciones = valoracionesService.obtenerValoracionesTrabajador(servicioDisponible.trabajadorId)

            if (valoraciones.isNotEmpty()) {
                val puntuaciones = valoraciones.mapNotNull { valoracionMap ->
                    val valoracion = valoracionMap["valoracion"] as? Map<String, Any>
                    valoracion?.get("puntuacion") as? Int
                }

                if (puntuaciones.isNotEmpty()) {
                    valoracionPromedio = puntuaciones.average()
                    totalValoraciones = puntuaciones.size
                    valoracionPromedio = kotlin.math.round(valoracionPromedio * 10.0) / 10.0
                }
            }
        } catch (_: Exception) {
            valoracionPromedio = 0.0
            totalValoraciones = 0
        }

        return ServicioOfrecidoResponse(
            id = servicioDisponible.id,
            trabajadorId = servicioDisponible.trabajadorId,
            nombreTrabajador = nombreTrabajador,
            servicioId = servicioDisponible.servicioId,
            nombreServicio = servicio?.nombre ?: "",
            descripcionServicio = servicio?.descripcion,
            descripcion = servicioDisponible.descripcion,
            observaciones = servicioDisponible.observaciones,
            precioHora = servicioDisponible.precioHora,
            color = servicio?.color ?: "#AAAAFF",
            icono= servicio?.icono ?: "work",
            valoracionPromedio = valoracionPromedio,
            totalValoraciones = totalValoraciones,
            urlImagenPerfilTrabajador = urlImagenPerfil,
            fechaCreacion = servicioDisponible.fechaCreacion,
            fechaActualizacion = servicioDisponible.fechaActualizacion
        )
    }

    // convierte urls viejas al nuevo formato de firebase
    private fun convertirURLFirebase(url: String): String {
        if (url.contains("firebasestorage.googleapis.com")) {
            return url
        }

        if (url.contains("storage.googleapis.com")) {
            try {
                val bucket = StorageClient.getInstance().bucket().name
                val path = url.substringAfter("$bucket/")
                val encodedPath = path.split("/")
                    .joinToString("%2F") { it.encodeURLComponent() }

                return "https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media"
            } catch (_: Exception) {
                return url
            }
        }

        return url
    }

    // codifica componente de url para firebase
    private fun String.encodeURLComponent(): String {
        return try {
            URLEncoder.encode(this, "UTF-8")
        } catch (_: Exception) {
            this
        }
    }

    // saca los ultimos 5 servicios no eliminados
    @Transactional(readOnly = true)
    fun obtenerServiciosMasPopulares(excluirTrabajadorId: Int? = null): List<ServicioOfrecidoResponse> {
        val servicios = servicioDisponibleRepository.findAll()

        return servicios
            .filter {
                (excluirTrabajadorId == null || it.trabajadorId != excluirTrabajadorId) &&
                        it.trabajadorId != -1
            }
            .sortedByDescending { it.fechaCreacion }
            .take(5)
            .map { construirDTO(it) }
    }

    // busca servicios que coincidan con texto
    @Transactional(readOnly = true)
    fun buscarServicios(textoBusqueda: String, excluirTrabajadorId: Int? = null): List<ServicioOfrecidoResponse> {
        val servicios = servicioDisponibleRepository.findAll()
        val textoBuscar = textoBusqueda.lowercase()

        return servicios
            .filter { servicio ->
                if (servicio.trabajadorId == -1 ||
                    (excluirTrabajadorId != null && servicio.trabajadorId == excluirTrabajadorId)) {
                    return@filter false
                }

                val descripcion = servicio.descripcion?.lowercase() ?: ""
                if (descripcion.contains(textoBuscar)) return@filter true

                val trabajador = usuarioRepository.findById(servicio.trabajadorId).orElse(null)
                if (trabajador != null) {
                    val nombreCompleto = "${trabajador.nombre} ${trabajador.apellido1}".lowercase()
                    if (nombreCompleto.contains(textoBuscar)) return@filter true
                }

                val tipoServicio = servicioRepository.findById(servicio.servicioId).orElse(null)
                if (tipoServicio != null) {
                    val nombreServicio = tipoServicio.nombre.lowercase()
                    if (nombreServicio.contains(textoBuscar)) return@filter true
                }

                false
            }
            .take(20)
            .map { construirDTO(it) }
    }

    // saca los servicios por una lista de ids
    fun obtenerServiciosPorIds(idsServicios: List<Int>): List<ServicioOfrecidoResponse> {
        return try {
            if (idsServicios.isEmpty()) {
                return emptyList()
            }

            val serviciosEncontrados = servicioDisponibleRepository.findAllById(idsServicios)

            val serviciosDTO = serviciosEncontrados.map { servicio ->
                construirDTO(servicio)
            }.sortedBy { dto ->
                idsServicios.indexOf(dto.id)
            }

            serviciosDTO

        } catch (e: Exception) {
            throw Exception("Error al obtener servicios por IDs: ${e.message}")
        }
    }
}
