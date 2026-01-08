package com.houseService.backend.services

import com.houseService.backend.models.Servicio
import com.houseService.backend.repositories.ServicioRepository
import org.springframework.stereotype.Service

@Service
class ServicioService(
    private val servicioRepository: ServicioRepository
) {

    // trae todos los servicios registrados
    fun obtenerTodosLosServicios(): List<Servicio> {
        return servicioRepository.findAll()
    }

    // busca un servicio segun su id
    fun obtenerServicioPorId(id: Int): Servicio? {
        return servicioRepository.findById(id).orElse(null)
    }
}
