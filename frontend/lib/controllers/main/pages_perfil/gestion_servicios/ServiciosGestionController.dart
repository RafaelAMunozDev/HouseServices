import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../models/ServicioContratado.dart';
import '../../../../../services/ServicioContratadoService.dart';
import '../../../../../services/FCMService.dart';
import '../../../../../utils/OperacionesServicios.dart';
import '../../../../../utils/Dialogos.dart';
import '../../../../../widgets/ServiciosWidgets.dart';
import 'BaseServiciosController.dart';

// controla la gestion de servicios en progreso del trabajador
class ServiciosGestionController extends BaseServiciosController {
  static final ServiciosGestionController _instancia = ServiciosGestionController._interno();
  factory ServiciosGestionController() => _instancia;
  ServiciosGestionController._interno();

  final ServicioContratadoService _servicioContratadoService = ServicioContratadoService();
  final FCMService _fcmService = FCMService();

  // lista de servicios que esta gestionando el trabajador
  List<ServicioContratado> _serviciosGestion = [];
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);
  Function? _callbackActualizarEstado;

  // acceso a los datos
  List<ServicioContratado> get serviciosGestion => _serviciosGestion;
  bool get tieneServiciosGestion => _serviciosGestion.isNotEmpty;

  // inicia actualizacion automatica de servicios
  void iniciarAutoRefresh(Function actualizarEstado) {
    _callbackActualizarEstado = actualizarEstado;
    cancelarAutoRefresh();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!estaCargando) {
        cargarServiciosGestion(actualizarEstado, silencioso: true);
      }
    });
  }

  void cancelarAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void dispose() {
    cancelarAutoRefresh();
    _callbackActualizarEstado = null;
  }

  // actualiza desde otros controladores
  void actualizarDesdeExterior() {
    if (_callbackActualizarEstado != null && !estaCargando) {
      cargarServiciosGestion(_callbackActualizarEstado!, silencioso: true);
    }
  }

  // carga los servicios que esta gestionando el trabajador
  Future<void> cargarServiciosGestion(Function actualizarEstado, {bool silencioso = false}) async {
    if (!silencioso) {
      actualizarEstadoCarga(true, actualizarEstado);
    }

    final idUsuario = await obtenerIdUsuario();
    if (idUsuario == null) {
      throw Exception('No se pudo obtener el ID del usuario');
    }

    final serviciosCargados = await _servicioContratadoService.obtenerServiciosEnGestion(idUsuario);

    // filtra servicios validos con datos completos
    _serviciosGestion = serviciosCargados.where((servicio) {
      return servicio.id != null &&
          (servicio.nombreServicio != null || servicio.servicioNombre != null);
    }).toList();

    if (!silencioso) {
      actualizarEstadoCarga(false, actualizarEstado);
    } else {
      actualizarEstado();
    }
  }

  // inicia un servicio confirmado por el trabajador
  Future<void> iniciarServicio(int servicioId, Function actualizarEstado, BuildContext context) async {
    final confirmado = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Iniciar Servicio',
      mensaje: '¿Estás listo para iniciar este servicio?',
      textoAceptar: 'Iniciar',
      colorBotonAceptar: const Color(0xFF616281),
    );

    if (confirmado) {
      Dialogos.mostrarDialogoCarga(context);

      final idUsuario = await obtenerIdUsuario();
      if (idUsuario == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      final servicioActualizado = await _servicioContratadoService.iniciarServicio(servicioId, idUsuario);
      Navigator.of(context).pop();

      if (servicioActualizado != null) {
        mostrarMensajeExito(context, 'Servicio iniciado', Colors.green);
        await cargarServiciosGestion(actualizarEstado, silencioso: false);
      } else {
        mostrarMensajeError(context, 'No se pudo iniciar el servicio');
      }
    }
  }

  // marca un servicio como completado
  Future<void> completarServicio(int servicioId, Function actualizarEstado, BuildContext context) async {
    final confirmado = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Completar Servicio',
      mensaje: '¿Has terminado este servicio? Se notificará al cliente.',
      textoAceptar: 'Completar',
      colorBotonAceptar: const Color(0xFF616281),
    );

    if (confirmado) {
      Dialogos.mostrarDialogoCarga(context);

      final idUsuario = await obtenerIdUsuario();

      final servicioActualizado = await _servicioContratadoService.completarServicio(servicioId, idUsuario!);
      Navigator.of(context).pop();

      if (servicioActualizado != null) {
        mostrarMensajeExito(context, 'Servicio completado exitosamente', Colors.green);
        await cargarServiciosGestion(actualizarEstado, silencioso: false);
      } else {
        mostrarMensajeError(context, 'No se pudo completar el servicio');
      }

    }
  }

  // construye la tarjeta visual del servicio en gestion
  Widget construirTarjetaServicioGestion(ServicioContratado servicio, Function actualizarEstado, BuildContext context) {
    return ServiciosWidgets.construirTarjetaServicioGestion(
      context: context,
      servicio: servicio,
      actualizarEstado: actualizarEstado,
      estadoTexto: servicio.estadoNombre?.toUpperCase() ?? 'DESCONOCIDO',
      colorEstado: _obtenerColorEstadoPropio(servicio.estadoNombre),
      botonesAccion: ServiciosWidgets.crearBotonesGestion(
        context: context,
        servicio: servicio,
        iniciarServicio: iniciarServicio,
        completarServicio: completarServicio,
        actualizarEstado: actualizarEstado,
      ),
    );
  }

  // obtiene el color segun el estado del servicio
  Color _obtenerColorEstadoPropio(String? estadoNombre) {
    switch (estadoNombre?.toLowerCase()) {
      case 'confirmado':
        return Colors.blue;
      case 'en_progreso':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'cancelado':
      case 'cancelado_cliente':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // widgets para diferentes estados de la pantalla
  Widget construirIndicadorCarga() => OperacionesServicios.construirIndicadorCarga();
  Widget construirVistaError(Function cargarDatos) => OperacionesServicios.construirVistaError(mensajeError, cargarDatos);
  Widget construirVistaVacia() => OperacionesServicios.construirVistaVaciaGestion();

  // limpia todos los datos y timers
  void limpiarDatos() {
    cancelarAutoRefresh();
    _serviciosGestion.clear();
    limpiarDatosBase();
  }
}