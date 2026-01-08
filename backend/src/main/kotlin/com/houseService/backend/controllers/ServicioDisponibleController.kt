package com.houseService.backend.controllers

import com.fasterxml.jackson.databind.ObjectMapper
import com.houseService.backend.dto.response.ServicioOfrecidoResponse
import com.houseService.backend.models.ServicioDisponible
import com.houseService.backend.services.HorarioValidacionService
import com.houseService.backend.services.ServicioDisponibleHorarioService
import com.houseService.backend.services.ServicioDisponibleService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/servicios")
class ServicioDisponibleController(
    private val servicioDisponibleService: ServicioDisponibleService,
    private val objectMapper: ObjectMapper,
    private val horarioValidacionService: HorarioValidacionService,
) {

    @Autowired
    private lateinit var horarioService: ServicioDisponibleHorarioService

    // devuelve todos los servicios disponibles
    @GetMapping("/disponibles")
    fun obtenerTodosLosServiciosOfrecidos(): ResponseEntity<List<ServicioOfrecidoResponse>> {
        val servicios = servicioDisponibleService.obtenerTodosLosServiciosOfrecidos()
        return ResponseEntity.ok(servicios)
    }

    // devuelve un servicio por su id si existe
    @GetMapping("/disponibles/{id}")
    fun obtenerServicioOfrecidoPorId(@PathVariable id: Int): ResponseEntity<*> {
        return try {
            val servicio = servicioDisponibleService.obtenerServicioOfrecidoPorId(id)
                ?: return ResponseEntity.notFound().build<Any>()
            ResponseEntity.ok(servicio)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener el servicio disponible: ${e.message}"))
        }
    }

    // obtiene todos los servicios disponibles de un trabajador
    @GetMapping("/disponibles/trabajador/{trabajadorId}")
    fun obtenerServiciosOfrecidosPorTrabajador(
        @PathVariable trabajadorId: Int
    ): ResponseEntity<*> {
        return try {
            val servicios = servicioDisponibleService.obtenerServiciosOfrecidosPorTrabajador(trabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener los servicios disponibles: ${e.message}"))
        }
    }

    // crea un nuevo servicio
    @PostMapping("/disponibles")
    fun crearServicioDisponible(
        @RequestBody servicioDisponible: ServicioDisponible
    ): ResponseEntity<*> {
        return try {
            val nuevoServicio = servicioDisponibleService.crearServicioDisponible(servicioDisponible)
            ResponseEntity.status(HttpStatus.CREATED).body(nuevoServicio)
        } catch (e: IllegalArgumentException) {
            ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al crear el servicio disponible: ${e.message}"))
        }
    }

    // actualiza un servicio ya creado
    @PutMapping("/disponibles/{id}")
    fun actualizarServicioDisponible(
        @PathVariable id: Int,
        @RequestBody servicioDisponible: ServicioDisponible
    ): ResponseEntity<*> {
        return try {
            val actualizado = servicioDisponibleService.actualizarServicioDisponible(id, servicioDisponible)
            ResponseEntity.ok(actualizado)
        } catch (e: IllegalArgumentException) {
            ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al actualizar el servicio disponible: ${e.message}"))
        }
    }

    // elimina un servicio por id
    @DeleteMapping("/disponibles/{id}")
    fun eliminarServicioDisponible(@PathVariable id: Int): ResponseEntity<*> {
        return try {
            servicioDisponibleService.eliminarServicioDisponible(id)
            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Servicio eliminado correctamente"
            ))
        } catch (e: IllegalArgumentException) {
            ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(mapOf("message" to e.message))
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al eliminar el servicio disponible: ${e.message}"))
        }
    }

    // devuelve el horario de un servicio
    @GetMapping("/disponibles/{id}/horario")
    fun obtenerHorarioServicio(@PathVariable id: Int): ResponseEntity<*> {
        return try {
            val horario = horarioService.obtenerHorarioPorServicio(id)
            if (horario != null) {
                val horarioMap = objectMapper.readValue(horario.horarioJson, Map::class.java)
                ResponseEntity.ok(horarioMap)
            } else {
                // se devuelve estructura vacia si no hay horario
                ResponseEntity.ok(mapOf(
                    "horario_regular" to mapOf(
                        "lunes" to emptyList<Any>(),
                        "martes" to emptyList<Any>(),
                        "miercoles" to emptyList<Any>(),
                        "jueves" to emptyList<Any>(),
                        "viernes" to emptyList<Any>(),
                        "sabado" to emptyList<Any>(),
                        "domingo" to emptyList<Any>()
                    ),
                    "excepciones" to emptyList<Any>()
                ))
            }
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener el horario: ${e.message}"))
        }
    }

    // guarda o actualiza el horario de un servicio
    @PutMapping("/disponibles/{id}/horario")
    fun guardarHorarioServicio(
        @PathVariable id: Int,
        @RequestBody horario: Map<String, Any>
    ): ResponseEntity<*> {
        return try {
            val horarioJson = objectMapper.writeValueAsString(horario)

            val servicio = servicioDisponibleService.obtenerServicioOfrecidoPorId(id)
                ?: return ResponseEntity.notFound().build<Any>()

            val validacion = horarioValidacionService.validarSolapamientoHorarios(
                trabajadorId = servicio.trabajadorId,
                nuevoHorarioJson = horarioJson,
                servicioIdExcluir = id
            )

            if (!validacion.valido) {
                return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(mapOf(
                        "success" to false,
                        "message" to "El horario se solapa con otros servicios"
                    ))
            }

            horarioService.guardarHorario(id, horarioJson)

            ResponseEntity.ok(mapOf(
                "success" to true,
                "message" to "Horario guardado correctamente"
            ))
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al guardar el horario: ${e.message}"))
        }
    }

    // valida un horario sin guardarlo (para previsualizar errores)
    @PostMapping("/disponibles/validar-horario")
    fun validarHorarioSinGuardar(
        @RequestParam trabajadorId: Int,
        @RequestParam(required = false) servicioIdExcluir: Int?,
        @RequestBody horario: Map<String, Any>
    ): ResponseEntity<*> {
        return try {
            val horarioJson = objectMapper.writeValueAsString(horario)

            val validacion = horarioValidacionService.validarSolapamientoHorarios(
                trabajadorId = trabajadorId,
                nuevoHorarioJson = horarioJson,
                servicioIdExcluir = servicioIdExcluir
            )

            ResponseEntity.ok(mapOf(
                "valido" to validacion.valido,
                "mensaje" to if (validacion.valido) {
                    "Horario válido"
                } else {
                    "El horario se solapa con otros servicios"
                }
            ))
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf(
                    "valido" to false,
                    "mensaje" to "Error al validar horario: ${e.message}"
                ))
        }
    }

    // devuelve los servicios mas populares, se puede excluir al trabajador actual
    @GetMapping("/disponibles/mas-populares")
    fun obtenerServiciosMasPopulares(
        @RequestParam(required = false) excluirTrabajadorId: Int?
    ): ResponseEntity<List<ServicioOfrecidoResponse>> {
        return try {
            val servicios = servicioDisponibleService.obtenerServiciosMasPopulares(excluirTrabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(emptyList())
        }
    }

    // busca servicios por texto, puede excluir al trabajador actual
    @GetMapping("/disponibles/buscar")
    fun buscarServicios(
        @RequestParam q: String,
        @RequestParam(required = false) excluirTrabajadorId: Int?
    ): ResponseEntity<List<ServicioOfrecidoResponse>> {
        return try {
            if (q.trim().length < 2) {
                return ResponseEntity.badRequest().body(emptyList())
            }

            val servicios = servicioDisponibleService.buscarServicios(q.trim(), excluirTrabajadorId)
            ResponseEntity.ok(servicios)
        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(emptyList())
        }
    }

    // devuelve los servicios favoritos segun una lista de ids
    @PostMapping("/disponibles/favoritos")
    fun obtenerServiciosFavoritos(
        @RequestBody idsServicios: List<Int>
    ): ResponseEntity<*> {
        return try {
            if (idsServicios.isEmpty()) {
                return ResponseEntity.ok(emptyList<Any>())
            }

            val servicios = servicioDisponibleService.obtenerServiciosPorIds(idsServicios)
            ResponseEntity.ok(servicios)

        } catch (e: Exception) {
            ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("message" to "Error al obtener favoritos: ${e.message}"))
        }
    }

}
