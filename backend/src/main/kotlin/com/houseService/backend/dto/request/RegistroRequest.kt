// contiene los datos que se reciben cuando un usuario se registra
// incluye token de firebase y datos personales opcionales como dni o telefono

package com.houseService.backend.dto.request

data class RegistroRequest(
    val token: String? = null,
    val nombre: String? = null,
    val apellido1: String? = null,
    val apellido2: String? = null,
    val dni: String? = null,
    val correo: String? = null,
    val fechaNacimiento: String? = null,
    val telefono: String? = null
)
