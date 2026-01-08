package com.houseService.backend.controllers

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import com.houseService.backend.models.Usuario
import com.houseService.backend.services.UsuarioService
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import com.houseService.backend.dto.request.RegistroRequest
import org.springframework.dao.DataIntegrityViolationException

@RestController
@RequestMapping("/api/auth")
class AuthController(private val usuarioService: UsuarioService) {

    private val logger = LoggerFactory.getLogger(AuthController::class.java)

    // Endpoint para validar los datos unicos
    // antes de dar de alta en firebase al usuario
    @PostMapping("/pre-register")
    fun preRegister(@RequestBody registroRequest: RegistroRequest): ResponseEntity<Map<String, Any>> {

        // se comprueba si el dni ya existe
        if (!registroRequest.dni.isNullOrBlank() && usuarioService.existeDni(registroRequest.dni)) {
            return ResponseEntity.badRequest().body(
                mapOf("success" to false, "message" to "El DNI establecido ya esta registrado.")
            )
        }

        // se comprueba si el telefono ya existe
        if (!registroRequest.telefono.isNullOrBlank() && usuarioService.existeTelefono(registroRequest.telefono)) {
            return ResponseEntity.badRequest().body(
                mapOf("success" to false, "message" to "El telefono establecido ya esta registrado.")
            )
        }

        // se comprueba si el correo ya existe (aunque firebase lo valide)
        if (!registroRequest.correo.isNullOrBlank() && usuarioService.existeCorreo(registroRequest.correo)) {
            return ResponseEntity.badRequest().body(
                mapOf("success" to false, "message" to "El correo electronico ya esta registrado.")
            )
        }

        return ResponseEntity.ok(mapOf("success" to true))
    }

    // endpoint para registrar un usuario nuevo
    // se valida el token de firebase y se comprueba que no este registrado
    // tambien se validan campos como dni y telefono
    @PostMapping("/register")
    fun registerUser(@RequestBody registroRequest: RegistroRequest): ResponseEntity<Map<String, Any>> {
        logger.info("Recibida solicitud de registro: ${registroRequest.nombre} ${registroRequest.apellido1}")

        return try {
            val decodedToken = FirebaseAuth.getInstance().verifyIdToken(registroRequest.token)
            val firebaseUid = decodedToken.uid
            val email = decodedToken.email

            val usuarioExistente = usuarioService.findByFirebaseUid(firebaseUid)
            if (usuarioExistente.isPresent) {
                return ResponseEntity.ok(
                    mapOf(
                        "success" to true,
                        "message" to "Usuario ya registrado",
                        "usuario" to usuarioExistente.get()
                    )
                )
            }

            // se comprueba si el dni ya existe
            if (registroRequest.dni != null && usuarioService.existeDni(registroRequest.dni)) {
                return ResponseEntity.badRequest().body(
                    mapOf(
                        "success" to false,
                        "message" to "El DNI establecido ya esta registrado."
                    )
                )
            }

            // se comprueba si el telefono ya existe
            if (registroRequest.telefono != null && usuarioService.existeTelefono(registroRequest.telefono)) {
                return ResponseEntity.badRequest().body(
                    mapOf(
                        "success" to false,
                        "message" to "El teléfono establecido ya está registrado."
                    )
                )
            }

            // se intenta parsear la fecha de nacimiento si se envia
            val fechaNacimiento = registroRequest.fechaNacimiento?.let {
                try {
                    LocalDate.parse(it, DateTimeFormatter.ISO_DATE)
                } catch (e: Exception) {
                    logger.warn("Error al parsear fecha de nacimiento: ${it}", e)
                    null
                }
            }

            // se crea y guarda el nuevo usuario
            val nuevoUsuario = Usuario(
                firebaseUid = firebaseUid,
                nombre = registroRequest.nombre,
                apellido1 = registroRequest.apellido1,
                apellido2 = registroRequest.apellido2,
                dni = registroRequest.dni,
                fechaNacimiento = fechaNacimiento,
                telefono = registroRequest.telefono,
                correo = email,
                primerInicio = 0
            )

            val usuarioGuardado = usuarioService.save(nuevoUsuario)

            // se asigna el rol al nuevo usuario
            usuarioService.asignarRolUsuario(usuarioGuardado)

            ResponseEntity.ok(
                mapOf(
                    "success" to true,
                    "message" to "Usuario registrado correctamente",
                    "usuario" to usuarioGuardado
                )
            )
        } catch (e: DataIntegrityViolationException) {
            // violacion de claves unicas (dni, telefono, correo)
            logger.warn("Conflicto de datos duplicados al registrar usuario", e)
            ResponseEntity.badRequest().body(
                mapOf(
                    "success" to false,
                    "message" to "Ya existe un usuario con esos datos."
                )
            )
        } catch (e: FirebaseAuthException) {
            // error de token invalido
            logger.error("Error de autenticación de Firebase", e)
            ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                mapOf(
                    "success" to false,
                    "message" to "Token inválido: ${e.message}"
                )
            )
        } catch (e: Exception) {
            // error general en el registro
            logger.error("Error al registrar usuario", e)
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                mapOf(
                    "success" to false,
                    "message" to "Error al registrar usuario: ${e.message}"
                )
            )
        }
    }

    // endpoint para validar si un token de firebase es correcto y si el usuario ya esta en la base de datos
    @PostMapping("/validate")
    fun validateToken(@RequestBody request: Map<String, String>): ResponseEntity<Map<String, Any>> {
        val token = request["token"] ?: return ResponseEntity.badRequest().body(
            mapOf("valid" to false, "message" to "Token no proporcionado")
        )

        return try {
            val decodedToken = FirebaseAuth.getInstance().verifyIdToken(token)
            val firebaseUid = decodedToken.uid

            val usuarioOpt = usuarioService.findByFirebaseUid(firebaseUid)

            ResponseEntity.ok(
                mapOf(
                    "valid" to true,
                    "userExists" to usuarioOpt.isPresent,
                    "message" to if (usuarioOpt.isPresent) "Usuario autenticado" else "Usuario no registrado"
                )
            )
        } catch (e: FirebaseAuthException) {
            ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                mapOf("valid" to false, "message" to "Token inválido: ${e.message}")
            )
        } catch (e: Exception) {
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                mapOf("valid" to false, "message" to "Error en el servidor: ${e.message}")
            )
        }
    }

    // endpoint para obtener el usuario actual desde el token de autenticacion
    @GetMapping("/me")
    fun getCurrentUser(@RequestHeader("Authorization") authHeader: String?): ResponseEntity<Any> {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                mapOf("message" to "Token no proporcionado")
            )
        }

        val token = authHeader.substring(7)

        return try {
            val decodedToken = FirebaseAuth.getInstance().verifyIdToken(token)
            val firebaseUid = decodedToken.uid

            val usuarioOpt = usuarioService.findByFirebaseUid(firebaseUid)

            if (usuarioOpt.isPresent) {
                ResponseEntity.ok(usuarioOpt.get())
            } else {
                ResponseEntity.notFound().build()
            }
        } catch (e: FirebaseAuthException) {
            ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                mapOf("message" to "Token inválido: ${e.message}")
            )
        }
    }
}
