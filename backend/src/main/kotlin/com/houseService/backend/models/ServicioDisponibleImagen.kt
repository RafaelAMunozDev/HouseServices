// representa una imagen asociada a un servicio disponible
// se usa para mostrar fotos en la app

package com.houseService.backend.models

import jakarta.persistence.*

@Entity
@Table(name = "servicios_disponibles_imagenes")
data class ServicioDisponibleImagen(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "servicio_disponible_id", nullable = false)
    val servicioDisponibleId: Int,

    @Column(name = "url_imagen", nullable = false)
    var urlImagen: String
)
