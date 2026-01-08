package com.houseService.backend.services

import com.google.firebase.messaging.*
import com.houseService.backend.repositories.UsuariosFcmTokensRepository
import org.springframework.stereotype.Service

@Service
class FCMService(
    private val fcmTokensRepository: UsuariosFcmTokensRepository
) {

    // envia una noti push a un usuario usando sus tokens fcm activos
    fun enviarNotificacionAUsuario(
        usuarioId: Int,
        titulo: String,
        mensaje: String,
        datos: Map<String, String> = emptyMap()
    ) {
        try {
            val tokens = fcmTokensRepository.findByUsuarioIdAndActivo(usuarioId, 1)

            if (tokens.isEmpty()) return

            val notification = Notification.builder()
                .setTitle(titulo)
                .setBody(mensaje)
                .build()

            tokens.forEach { tokenEntity ->
                try {
                    val message = Message.builder()
                        .setToken(tokenEntity.fcmToken)
                        .setNotification(notification)
                        .putAllData(datos)
                        .setAndroidConfig(
                            AndroidConfig.builder()
                                .setNotification(
                                    AndroidNotification.builder()
                                        .setTitle(titulo)
                                        .setBody(mensaje)
                                        .setIcon("logo_notificacion")
                                        .setColor("#AAADFF")
                                        .build()
                                )
                                .build()
                        )
                        .setApnsConfig(
                            ApnsConfig.builder()
                                .setAps(
                                    Aps.builder()
                                        .setAlert(
                                            ApsAlert.builder()
                                                .setTitle(titulo)
                                                .setBody(mensaje)
                                                .build()
                                        )
                                        .setBadge(1)
                                        .setSound("default")
                                        .build()
                                )
                                .build()
                        )
                        .build()

                    FirebaseMessaging.getInstance().send(message)
                } catch (e: Exception) {
                    if (e.message?.contains("invalid-registration-token") == true) {
                        fcmTokensRepository.desactivarToken(tokenEntity.fcmToken)
                    }
                }
            }

        } catch (_: Exception) {}
    }

    // noti cuando cliente pide un servicio
    fun notificarServicioSolicitado(trabajadorId: Int, clienteNombre: String, servicioNombre: String) {
        enviarNotificacionAUsuario(
            trabajadorId,
            "Nuevo servicio solicitado",
            "$clienteNombre te ha solicitado el servicio de $servicioNombre",
            mapOf(
                "tipo" to "servicio_solicitado",
                "accion" to "abrir_pendientes",
                "cliente_nombre" to clienteNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }

    // noti cuando se inicia el servicio
    fun notificarServicioIniciado(clienteId: Int, trabajadorNombre: String, servicioNombre: String) {
        enviarNotificacionAUsuario(
            clienteId,
            "Servicio iniciado",
            "$trabajadorNombre ha comenzado tu servicio de $servicioNombre",
            mapOf(
                "tipo" to "servicio_iniciado",
                "accion" to "ver_historial",
                "trabajador_nombre" to trabajadorNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }

    // noti cuando se confirma un servicio
    fun notificarServicioConfirmado(clienteId: Int, trabajadorNombre: String, servicioNombre: String) {
        enviarNotificacionAUsuario(
            clienteId,
            "Servicio confirmado",
            "$trabajadorNombre ha aceptado tu solicitud del servicio de $servicioNombre",
            mapOf(
                "tipo" to "servicio_confirmado",
                "accion" to "ver_historial",
                "trabajador_nombre" to trabajadorNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }

    // noti cuando el trabajador rechaza
    fun notificarServicioRechazado(clienteId: Int, trabajadorNombre: String, servicioNombre: String) {
        enviarNotificacionAUsuario(
            clienteId,
            "Servicio rechazado",
            "$trabajadorNombre no puede realizar el servicio de $servicioNombre",
            mapOf(
                "tipo" to "servicio_rechazado",
                "accion" to "ver_historial",
                "trabajador_nombre" to trabajadorNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }

    // noti cuando se completa un servicio
    fun notificarServicioCompletado(clienteId: Int, trabajadorNombre: String, servicioNombre: String) {
        enviarNotificacionAUsuario(
            clienteId,
            "Servicio completado",
            "$trabajadorNombre ha finalizado el servicio de $servicioNombre. ¡Valóralo!",
            mapOf(
                "tipo" to "servicio_completado",
                "accion" to "ver_historial",
                "trabajador_nombre" to trabajadorNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }
    // noti cuando el cliente cancela un servicio
    fun notificarServicioCanceladoPorCliente(
        trabajadorId: Int,
        clienteNombre: String,
        servicioNombre: String
    ) {
        enviarNotificacionAUsuario(
            trabajadorId,
            "Servicio cancelado",
            "$clienteNombre ha cancelado el servicio de $servicioNombre",
            mapOf(
                "tipo" to "servicio_cancelado_cliente",
                "accion" to "ver_gestion",
                "cliente_nombre" to clienteNombre,
                "servicio_nombre" to servicioNombre
            )
        )
    }
}
