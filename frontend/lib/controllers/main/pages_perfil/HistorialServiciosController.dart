import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../models/ServicioContratado.dart';
import '../../../../services/ServicioContratadoService.dart';
import '../../../../services/UsuarioService.dart';
import '../../../../services/ValoracionesService.dart';
import '../../../../widgets/ServiciosWidgets.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../../widgets/DialogoValoracionCliente.dart';
import '../../../utils/Dialogos.dart';

class HistorialServiciosController {
  static final HistorialServiciosController _instancia = HistorialServiciosController._interno();
  factory HistorialServiciosController() => _instancia;
  HistorialServiciosController._interno();

  final ServicioContratadoService _servicioService = ServicioContratadoService();
  final UsuarioService _usuarioService = UsuarioService();
  final ValoracionesService _valoracionesService = ValoracionesService();

  // auto-refresh
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  // estado del controller
  List<ServicioContratado> _historialServicios = [];
  final List<ServicioContratado> _serviciosPendientesValorar = [];
  bool _estaCargando = true;
  String? _mensajeError;

  // getters
  List<ServicioContratado> get historialServicios => _historialServicios;
  List<ServicioContratado> get serviciosPendientesValorar => _serviciosPendientesValorar;
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  bool get tieneServicios => _historialServicios.isNotEmpty;

  // getters para auto-refresh
  bool get tieneAutoRefreshActivo => _refreshTimer?.isActive == true;
  String get estadoAutoRefresh {
    if (_refreshTimer == null) return 'No iniciado';
    if (_refreshTimer!.isActive) return 'Activo';
    return 'Inactivo';
  }

  // iniciar auto-refresh
  void iniciarAutoRefresh(Function actualizarEstado) {
    cancelarAutoRefresh();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_estaCargando) {
        cargarHistorial(actualizarEstado, silencioso: true);
      }
    });
  }

  // cancelar auto-refresh
  void cancelarAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // verificar servicios completados sin valorar
  Future<void> verificarServiciosCompletadosSinValorar(BuildContext context) async {
    final usuario = await _usuarioService.obtenerUsuarioActual();
    if (usuario?.id == null) return;

    final idUsuario = int.parse(usuario!.id!);
    final serviciosHistorial = await _servicioService.obtenerHistorialCliente(idUsuario);

    _serviciosPendientesValorar.clear();

    for (final servicio in serviciosHistorial) {
      if (servicio.estadoNombre?.toLowerCase() == 'completado' &&
          servicio.id != null &&
          servicio.trabajadorId != null) {
        final tieneValoracion = await _valoracionesService.existeValoracion(servicio.id!);
        if (!tieneValoracion) {
          _serviciosPendientesValorar.add(servicio);
        }
      }
    }

    if (_serviciosPendientesValorar.isNotEmpty && context.mounted) {
      await _mostrarSiguienteDialogoValoracion(context);
    }
  }

  // mostrar dialogos de valoracion en secuencia
  Future<void> _mostrarSiguienteDialogoValoracion(BuildContext context) async {
    if (_serviciosPendientesValorar.isEmpty || !context.mounted) return;

    final servicio = _serviciosPendientesValorar.first;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return DialogoValoracionCliente(
          servicio: servicio,
          onValoracionCreada: () {
            _serviciosPendientesValorar.removeWhere((s) => s.id == servicio.id);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                _mostrarSiguienteDialogoValoracion(context);
              }
            });
          },
        );
      },
    );
  }

  // cargar historial de servicios
  Future<void> cargarHistorial(Function actualizarEstado, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _estaCargando = true;
        _mensajeError = null;
        actualizarEstado();
      }

      final usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario?.id == null) {
        throw Exception('No se pudo obtener el usuario actual');
      }

      final clienteId = int.parse(usuario!.id!);
      final serviciosCargados = await _servicioService.obtenerHistorialCliente(clienteId);

      _historialServicios = serviciosCargados.where((servicio) => servicio.id != null).toList();

      _historialServicios.sort((a, b) {
        final fechaA = a.fechaRealizada ?? a.fechaConfirmada ?? DateTime.now();
        final fechaB = b.fechaRealizada ?? b.fechaConfirmada ?? DateTime.now();
        return fechaB.compareTo(fechaA);
      });

      _estaCargando = false;
      actualizarEstado();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = e.toString();
      actualizarEstado();
    }
  }

  // valorar servicio desde historial
  Future<void> valorarServicio(ServicioContratado servicio, BuildContext context, Function actualizarEstado) async {
    if (servicio.id == null || servicio.trabajadorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del servicio incompletos'), backgroundColor: Colors.red),
      );
      return;
    }

    final yaValorado = await _valoracionesService.existeValoracion(servicio.id!);
    if (yaValorado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este servicio ya ha sido valorado'), backgroundColor: Colors.orange),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return DialogoValoracionCliente(
          servicio: servicio,
          onValoracionCreada: () {
            cargarHistorial(actualizarEstado);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Valoracion guardada correctamente!'),
                backgroundColor: Color(0xFF616281),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  // construir tarjeta de historial
  Widget construirTarjetaHistorial(ServicioContratado servicio, Function actualizarEstado, BuildContext context) {
    if (servicio.id == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Card(child: Padding(padding: const EdgeInsets.all(16), child: const Text('Error: Servicio sin datos validos'))),
      );
    }

    final colorEstado = ServiciosWidgets.obtenerColorPorEstado(servicio.estadoNombre);
    final textoEstado = _obtenerTextoEstado(servicio.estadoNombre);

    return ServiciosWidgets.construirTarjetaServicioGestion(
      context: context,
      servicio: servicio,
      actualizarEstado: actualizarEstado,
      estadoTexto: textoEstado,
      colorEstado: colorEstado,
      botonesAccion: _construirBotonesHistorial(servicio, context, actualizarEstado),
    );
  }

  // obtener texto del estado
  String _obtenerTextoEstado(String? estadoNombre) {
    switch (estadoNombre?.toLowerCase()) {
      case 'solicitado':
        return 'SOLICITADO';
      case 'confirmado':
        return 'CONFIRMADO';
      case 'en_progreso':
        return 'EN PROGRESO';
      case 'completado':
        return 'COMPLETADO';
      case 'rechazado':
        return 'RECHAZADO';
      case 'cancelado_cliente':
        return 'CANCELADO';
      case 'cancelado_trabajador':
        return 'NO DISPONIBLE';
      default:
        return estadoNombre?.toUpperCase() ?? 'DESCONOCIDO';
    }
  }

  // construir botones especificos para historial
  List<Widget>? _construirBotonesHistorial(ServicioContratado servicio, BuildContext context, Function actualizarEstado) {
    final estado = servicio.estadoNombre?.toLowerCase();

    switch (estado) {
      case 'completado':
        return [
          Container(
            width: double.infinity,
            child: FutureBuilder<bool>(
              future: _valoracionesService.existeValoracion(servicio.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  );
                }

                final yaValorado = snapshot.data ?? false;

                if (yaValorado) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Servicio Valorado', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: () => valorarServicio(servicio, context, actualizarEstado),
                    icon: const Icon(Icons.star_rate, size: 18),
                    label: const Text('Valorar Servicio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF616281),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                }
              },
            ),
          ),
        ];

      case 'solicitado':
      case 'confirmado':
        return [
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarDialogoCancelacion(servicio, context, actualizarEstado),
              icon: const Icon(Icons.cancel, size: 18),
              label: Text(
                estado == 'solicitado'
                    ? 'Cancelar Solicitud'
                    : 'Cancelar Servicio',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ];
      default:
        return null;
    }
  }

  Future<void> _mostrarDialogoCancelacion(
      ServicioContratado servicio,
      BuildContext context,
      Function actualizarEstado,
      ) async {

    bool confirmar = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Cancelar servicio',
      mensaje: '¿Estas seguro de que deseas cancelar este servicio? Esta accion no se puede deshacer.',
      textoAceptar: 'Cancelar servicio',
      textoCancelar: 'Volver',
      colorBotonAceptar: Colors.red,
    );

    if (!confirmar) return;

    await  _cancelarServicioUI(servicio, context, actualizarEstado);
  }

  Future<void> _cancelarServicioUI(
      ServicioContratado servicio,
      BuildContext context,
      Function actualizarEstado,
      ) async {

    final messenger = ScaffoldMessenger.of(context);

    if (servicio.id == null) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Error: servicio invalido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario?.id == null) {
        throw Exception('No se pudo obtener el usuario');
      }

      // mostramos loading
      if (!context.mounted) return;
      Dialogos.mostrarDialogoCarga(context);

      // llamada backend
      final resultado = await _servicioService.cancelarServicio(
        servicio.id!,
        int.parse(usuario!.id!),
      );

      // si por lo que sea el backend no lanzo exception pero tampoco devolvio cancelado
      // evitamos mostrar el snackbar verde incorrecto
      if (resultado == null || resultado.estadoId != 6) {
        throw Exception('No se pudo cancelar el servicio');
      }

      // cerramos loading (solo si hay algo que cerrar)
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }

      // mini pausa para que el dialogo termine de cerrarse
      await Future.delayed(const Duration(milliseconds: 80));

      // refrescar historial
      await cargarHistorial(actualizarEstado);

      if (!context.mounted) return;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Servicio cancelado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {

      // cerrar loading si sigue abierto
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
      }

      await Future.delayed(const Duration(milliseconds: 80));
      if (!context.mounted) return;

      String mensaje = e.toString();

      // quita dobles prefijos tipicos
      mensaje = mensaje.replaceAll('Exception: ', '');
      mensaje = mensaje.replaceAll('Error al cancelar servicio: ', '');
      mensaje = mensaje.trim();

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // widgets de estado
  Widget construirIndicadorCarga() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF616281))),
          const SizedBox(height: 16),
          TextoEscalable(texto: 'Cargando historial...', estilo: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget construirVistaError(Function cargarDatos, String? mensajeError) {
    return ServiciosWidgets.construirVistaVacia(
      mensaje: 'Error al cargar el historial',
      subtitulo: 'Ha ocurrido un problema al obtener tus servicios',
      mensajeError: mensajeError,
      icono: Icons.error_outline,
    );
  }

  Widget construirVistaVacia() {
    return ServiciosWidgets.construirVistaVacia(
      mensaje: 'Aun no has contratado servicios',
      subtitulo: '',
      icono: Icons.history,
    );
  }

  // limpiar datos
  void limpiarDatos() {
    cancelarAutoRefresh();
    _historialServicios.clear();
    _serviciosPendientesValorar.clear();
    _estaCargando = true;
    _mensajeError = null;
  }

  void dispose() {
    cancelarAutoRefresh();
  }
}