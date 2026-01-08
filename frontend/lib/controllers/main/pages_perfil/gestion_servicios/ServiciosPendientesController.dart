import 'package:flutter/material.dart';
import '../../../../../models/ServicioContratado.dart';
import '../../../../../services/ServicioContratadoService.dart';
import '../../../../../utils/OperacionesServicios.dart';
import '../../../../../utils/Dialogos.dart';
import '../../../../../widgets/ServiciosWidgets.dart';
import 'BaseServiciosController.dart';

// controla servicios pendientes de confirmacion del trabajador
class ServiciosPendientesController extends BaseServiciosController {
  static final ServiciosPendientesController _instancia = ServiciosPendientesController._interno();
  factory ServiciosPendientesController() => _instancia;
  ServiciosPendientesController._interno();

  final ServicioContratadoService _servicioContratadoService = ServicioContratadoService();

  // lista de servicios esperando confirmacion
  List<ServicioContratado> _serviciosPendientes = [];

  // acceso a los datos
  List<ServicioContratado> get serviciosPendientes => _serviciosPendientes;
  bool get tieneServiciosPendientes => _serviciosPendientes.isNotEmpty;

  // carga servicios que estan pendientes de confirmacion
  Future<void> cargarServiciosPendientes(Function actualizarEstado, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        actualizarEstadoCarga(true, actualizarEstado);
      }

      final idUsuario = await obtenerIdUsuario();
      if (idUsuario == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      _serviciosPendientes = await _servicioContratadoService.obtenerServiciosPendientes(idUsuario);

      if (!silencioso) {
        actualizarEstadoCarga(false, actualizarEstado);
      } else {
        actualizarEstado();
      }
    } catch (e) {
      if (!silencioso) {
        actualizarEstadoCarga(false, actualizarEstado, error: 'Error al cargar servicios pendientes: $e');
      }
    }
  }

  // confirma un servicio pendiente y notifica al cliente
  Future<void> confirmarServicio(int servicioId, Function actualizarEstado, BuildContext context) async {
    final confirmado = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Confirmar Servicio',
      mensaje: '¿Estás seguro de que quieres aceptar este servicio? Se notificará al cliente.',
      textoAceptar: 'Confirmar',
      colorBotonAceptar: const Color(0xFF616281),
    );

    if (confirmado) {
      Dialogos.mostrarDialogoCarga(context);

      try {
        final idUsuario = await obtenerIdUsuario();
        if (idUsuario == null) {
          throw Exception('No se pudo obtener el ID del usuario');
        }

        final servicioActualizado = await _servicioContratadoService.confirmarServicio(servicioId, idUsuario);
        Navigator.of(context).pop();

        if (servicioActualizado != null) {
          mostrarMensajeExito(context, 'Servicio confirmado exitosamente', Colors.green);
          await cargarServiciosPendientes(actualizarEstado, silencioso: false);
        } else {
          mostrarMensajeError(context, 'No se pudo confirmar el servicio');
        }
      } catch (e) {
        Navigator.of(context).pop();
        mostrarMensajeError(context, 'Error al confirmar servicio: $e');
      }
    }
  }

  // rechaza un servicio pendiente y notifica al cliente
  Future<void> rechazarServicio(int servicioId, Function actualizarEstado, BuildContext context) async {
    final rechazado = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Rechazar Servicio',
      mensaje: '¿Estás seguro de que quieres rechazar este servicio? Se notificará al cliente.',
      textoAceptar: 'Rechazar',
      colorBotonAceptar: Colors.red,
    );

    if (rechazado) {
      Dialogos.mostrarDialogoCarga(context);

      try {
        final idUsuario = await obtenerIdUsuario();
        if (idUsuario == null) {
          throw Exception('No se pudo obtener el ID del usuario');
        }

        final servicioActualizado = await _servicioContratadoService.rechazarServicio(servicioId, idUsuario);
        Navigator.of(context).pop();

        if (servicioActualizado != null) {
          mostrarMensajeExito(context, 'Servicio rechazado', Colors.red);
          await cargarServiciosPendientes(actualizarEstado, silencioso: false);
        } else {
          mostrarMensajeError(context, 'No se pudo rechazar el servicio');
        }
      } catch (e) {
        Navigator.of(context).pop();
        mostrarMensajeError(context, 'Error al rechazar servicio: $e');
      }
    }
  }

  // construye la tarjeta visual del servicio pendiente
  Widget construirTarjetaServicioPendiente(ServicioContratado servicio, Function actualizarEstado, BuildContext context) {
    return ServiciosWidgets.construirTarjetaServicioGestion(
      context: context,
      servicio: servicio,
      actualizarEstado: actualizarEstado,
      estadoTexto: 'PENDIENTE',
      colorEstado: const Color(0xFFAAADFF),
      botonesAccion: ServiciosWidgets.crearBotonesPendientes(
        context: context,
        servicioId: servicio.id ?? 0,
        confirmarServicio: confirmarServicio,
        rechazarServicio: rechazarServicio,
        actualizarEstado: actualizarEstado,
      ),
    );
  }

  // widgets para diferentes estados de la pantalla
  Widget construirIndicadorCarga() => OperacionesServicios.construirIndicadorCarga();
  Widget construirVistaError(Function cargarDatos) => OperacionesServicios.construirVistaError(mensajeError, cargarDatos);
  Widget construirVistaVacia() => OperacionesServicios.construirVistaVaciaPendientes();

  // limpia todos los datos del controlador
  void limpiarDatos() {
    _serviciosPendientes.clear();
    limpiarDatosBase();
  }
}