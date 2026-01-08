import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/main/pages/pages_perfil/gestion_servicios/ServiciosEnGestion.dart';
import 'dart:io';
import 'ApiService.dart';
import 'UsuarioService.dart';
import '../../main.dart';
import '../ui/main/pages/pages_perfil/gestion_servicios/GestionServicios.dart';
import '../ui/main/pages/pages_perfil/HistorialServiciosContratados.dart';

// servicio para manejo de notificaciones push con firebase
class FCMService {
  static final FCMService _instancia = FCMService._interno();
  factory FCMService() => _instancia;
  FCMService._interno();

  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Function(Map<String, dynamic>)? onNotificationReceived;
  String? _ultimaNotificacionId;

  // inicializa fcm despues del login exitoso
  Future<void> inicializarFCM(int usuarioId) async {
    try {
      await _solicitarPermisos();
      await _registrarToken(usuarioId);
      _configurarListeners();
    } catch (e) {
      // error silencioso
    }
  }

  // solicita permisos de notificacion al usuario
  Future<void> _solicitarPermisos() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // obtiene token y lo registra en el backend
  Future<void> _registrarToken(int usuarioId) async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        String plataforma = Platform.isAndroid ? 'android' : 'ios';

        await _apiService.post('usuarios/fcm-tokens?usuarioId=$usuarioId', {
          'fcm_token': token,
          'plataforma': plataforma
        });
      }
    } catch (e) {
      // error silencioso
    }
  }

  // configura listeners de notificaciones
  void _configurarListeners() {
    // app en primer plano muestra notificaciones
    FirebaseMessaging.onMessage.listen(_manejarNotificacionEnPrimerPlano);

    // app en background usuario toca notificacion
    FirebaseMessaging.onMessageOpenedApp.listen(_manejarNotificacionTocada);

    // token refresh
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  // maneja notificacion cuando app esta en primer plano
  Future<void> _manejarNotificacionEnPrimerPlano(RemoteMessage message) async {
    // previene duplicados
    if (_ultimaNotificacionId == message.messageId) {
      return;
    }
    _ultimaNotificacionId = message.messageId;

    // muestra notificacion en app
    _mostrarNotificacionEnApp(message);

    if (onNotificationReceived != null) {
      onNotificationReceived!(message.data);
    }
  }

  // maneja cuando usuario toca una notificacion
  void _manejarNotificacionTocada(RemoteMessage message) {
    _navegarSegunTipoNotificacion(message.data);
  }

  // muestra notificacion dentro de la app con snackbar
  void _mostrarNotificacionEnApp(RemoteMessage message) {
    final context = navigatorKey.currentState?.context;

    if (context != null) {
      // oculta snackbar anterior primero
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // obtiene datos de la notificacion
      final tipo = message.data['tipo'] ?? 'general';
      final clienteNombre = message.data['cliente_nombre'] ?? 'Cliente';
      final servicioNombre = message.data['servicio_nombre'] ?? 'Servicio';
      final trabajadorNombre = message.data['trabajador_nombre'] ?? 'Trabajador';

      // crea mensaje personalizado con datos reales
      String mensajePersonalizado = _obtenerMensajePersonalizado(
          tipo, clienteNombre, servicioNombre, trabajadorNombre, message
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _obtenerIconoSegunTipo(tipo),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.notification?.title ?? '¡Nueva notificación!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mensajePersonalizado,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF616281),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () => _navegarSegunTipoNotificacion(message.data),
          ),
        ),
      );
    }
  }

  // obtiene mensaje personalizado con nombres reales
  String _obtenerMensajePersonalizado(String tipo, String clienteNombre,
      String servicioNombre, String trabajadorNombre, RemoteMessage message) {

    switch (tipo) {
      case 'servicio_solicitado':
        return '$clienteNombre ha solicitado tu servicio de $servicioNombre';

      case 'servicio_confirmado':
        return '$trabajadorNombre ha confirmado tu servicio de $servicioNombre';

      case 'servicio_rechazado':
        return '$trabajadorNombre no puede realizar tu servicio de $servicioNombre';

      case 'servicio_iniciado':
        return '$trabajadorNombre ha iniciado tu servicio de $servicioNombre';

      case 'servicio_completado':
        return '$trabajadorNombre ha completado tu servicio de $servicioNombre';
      case 'servicio_cancelado_cliente':
        return '$clienteNombre ha cancelado el servicio de $servicioNombre';

      default:
        return message.notification?.body ?? 'Nueva notificación recibida';
    }
  }

  // obtiene icono segun el tipo de notificacion
  IconData _obtenerIconoSegunTipo(String tipo) {
    switch (tipo) {
      case 'servicio_solicitado':
        return Icons.work_outline;
      case 'servicio_confirmado':
        return Icons.check_circle_outline;
      case 'servicio_rechazado':
        return Icons.cancel_outlined;
      case 'servicio_iniciado':
        return Icons.play_circle_outline;
      case 'servicio_completado':
        return Icons.task_alt;
      case 'mensaje':
        return Icons.message_outlined;
      case 'servicio_cancelado_cliente':
        return Icons.event_busy_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  // navega segun tipo de notificacion usando endpoints del sistema
  void _navegarSegunTipoNotificacion(Map<String, dynamic> data) async {
    final tipo = data['tipo'];

    final context = navigatorKey.currentState?.context;
    if (context == null) {
      return;
    }

    try {
      // obtiene roles del usuario usando endpoints
      final esCliente = await _usuarioService.esCliente();
      final esTrabajador = await _usuarioService.esTrabajador();

      switch (tipo) {
        case 'servicio_solicitado':
        // solo trabajadores reciben esta notificacion
          if (esTrabajador) {
            _navegarAServiciosPendientes(context);
          }
          break;
        case 'servicio_cancelado_cliente':
        // solo trabajadores reciben esta noti
          if (esTrabajador) {
            _navegarAServiciosEnGestion();
          }
          break;
        case 'servicio_confirmado':
        case 'servicio_rechazado':
        case 'servicio_iniciado':
        case 'servicio_completado':
        // clientes reciben estas notificaciones
          if (esCliente) {
            _navegarAHistorialServicios(context);
          }
          break;

        case 'mensaje':
        // todo implementar cuando tengas pantalla de mensajes
          break;

        default:
          break;
      }
    } catch (e) {
      // error silencioso en navegacion
    }
  }

  // navega a servicios pendientes para trabajadores
  void _navegarAServiciosPendientes(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const GestionServicios(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // navega a historial de servicios para clientes
  void _navegarAHistorialServicios(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const GestionServicios(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // cuando el token se renueva
  void _onTokenRefresh(String token) async {
    try {
      final usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario != null && usuario.id != null) {
        await _registrarToken(int.parse(usuario.id!));
      }
    } catch (e) {
      // error silencioso
    }
  }

  void _navegarAServiciosEnGestion() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
        const GestionServicios(pestanaInicial: 2),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
          (route) => route.isFirst, // deja solo la raiz
    );
  }


  // desactiva token al hacer logout
  Future<void> desactivarToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _apiService.delete('usuarios/fcm-tokens/$token');
      }
    } catch (e) {
      // error silencioso
    }
  }
}