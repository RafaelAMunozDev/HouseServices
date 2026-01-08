// servicio ke se encarga de eliminar un usuario y reasignar sus cosas pa ke no se rompa na

package com.houseService.backend.services

import com.houseService.backend.repositories.UsuarioRepository
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class EliminarUsuarioService(
    private val jdbcTemplate: JdbcTemplate,
    private val usuarioRepository: UsuarioRepository
) {
    private val idUsuarioEliminado = -1

    // elimina el usuario y reasigna sus relaciones a un usuario fantasma
    @Transactional
    fun eliminarUsuarioYReasignar(idUsuario: Int): Boolean {
        return try {
            if (!usuarioRepository.existsById(idUsuario)) {
                return false
            }

            crearUsuarioEliminadoSiNoExiste()
            reasignarRelaciones(idUsuario)
            usuarioRepository.deleteById(idUsuario)

            true
        } catch (e: Exception) {
            false
        }
    }

    // crea el usuario -1 si no existe pa usarlo como referencia
    private fun crearUsuarioEliminadoSiNoExiste() {
        jdbcTemplate.update(
            """
            INSERT INTO usuarios (id, nombre, apellido_1, correo, primer_inicio)
            SELECT ?, 'Usuario', 'Eliminado', 'eliminado@house.app', 1
            WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE id = ?)
            """.trimIndent(),
            idUsuarioEliminado, idUsuarioEliminado
        )
    }

    // reasigna todo lo ke estaba relacionado al usuario eliminado
    private fun reasignarRelaciones(idUsuario: Int) {
        jdbcTemplate.update(
            "UPDATE servicios_contratados SET cliente_id = ? WHERE cliente_id = ?",
            idUsuarioEliminado, idUsuario
        )

        val serviciosDisponiblesIds = jdbcTemplate.queryForList(
            "SELECT id FROM servicios_disponibles WHERE trabajador_id = ?",
            Int::class.java,
            idUsuario
        )

        if (serviciosDisponiblesIds.isNotEmpty()) {
            val idsString = serviciosDisponiblesIds.joinToString(",")

            val estadoCancelado = try {
                jdbcTemplate.queryForObject(
                    "SELECT id FROM servicios_estados WHERE estado = 'cancelado_trabajador'",
                    Int::class.java
                )
            } catch (e: Exception) {
                jdbcTemplate.update(
                    "INSERT INTO servicios_estados (estado) VALUES ('cancelado_trabajador')"
                )
                jdbcTemplate.queryForObject(
                    "SELECT id FROM servicios_estados WHERE estado = 'cancelado_trabajador'",
                    Int::class.java
                )
            }

            jdbcTemplate.update(
                """
                UPDATE servicios_contratados 
                SET estado_id = ? 
                WHERE servicio_disponible_id IN ($idsString) 
                AND estado_id NOT IN (
                    SELECT id FROM servicios_estados 
                    WHERE estado IN ('completado', 'cancelado_cliente', 'cancelado_trabajador')
                )
                """.trimIndent(),
                estadoCancelado
            )
        }

        // actualiza cliente y trabajador en valoraciones
        jdbcTemplate.update(
            "UPDATE valoraciones SET cliente_id = ? WHERE cliente_id = ?",
            idUsuarioEliminado, idUsuario
        )
        jdbcTemplate.update(
            "UPDATE valoraciones SET trabajador_id = ? WHERE trabajador_id = ?",
            idUsuarioEliminado, idUsuario
        )

        if (serviciosDisponiblesIds.isNotEmpty()) {
            val idsString = serviciosDisponiblesIds.joinToString(",")
            jdbcTemplate.update(
                "DELETE FROM servicios_disponibles_horarios WHERE servicio_disponible_id IN ($idsString)"
            )
            jdbcTemplate.update(
                "DELETE FROM servicios_disponibles_imagenes WHERE servicio_disponible_id IN ($idsString)"
            )
        }

        // borra servicios del trabajador
        jdbcTemplate.update(
            "DELETE FROM servicios_disponibles WHERE trabajador_id = ?",
            idUsuario
        )

        // borra relaciones directas del usuario
        jdbcTemplate.update("DELETE FROM usuarios_ubicacion WHERE usuario_id = ?", idUsuario)
        jdbcTemplate.update("DELETE FROM usuarios_roles WHERE usuario_id = ?", idUsuario)
        jdbcTemplate.update("DELETE FROM usuarios_fcm_tokens WHERE usuario_id = ?", idUsuario)
        jdbcTemplate.update("DELETE FROM usuarios_imagenes_perfil WHERE usuario_id = ?", idUsuario)

        // borra ubicaciones de servicios ligados al usuario
        jdbcTemplate.update(
            """
            DELETE FROM servicios_ubicacion 
            WHERE servicio_contratado_id IN (
                SELECT id FROM servicios_contratados 
                WHERE cliente_id = ?
            )
            """.trimIndent(),
            idUsuario
        )
    }
}
