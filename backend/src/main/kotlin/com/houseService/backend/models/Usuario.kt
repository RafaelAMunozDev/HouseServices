// representa a un usuario registrado, puede ser cliente o trabajador

package com.houseService.backend.models

import jakarta.persistence.*
import java.time.LocalDate

@Entity
@Table(name = "usuarios")
data class Usuario(

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "firebase_uid", unique = true)
    var firebaseUid: String? = null,

    @Column(nullable = false)
    var nombre: String? = "",

    @Column(name = "apellido_1", nullable = false)
    var apellido1: String? = "",

    @Column(name = "apellido_2")
    var apellido2: String? = null,

    @Column(unique = true)
    var dni: String? = null,

    @Column(name = "fecha_nacimiento")
    var fechaNacimiento: LocalDate? = null,

    @Column(unique = true)
    var telefono: String? = null,

    @Column(unique = true)
    var correo: String? = null,

    @Column(name = "primer_inicio")
    var primerInicio: Int = 0
)
