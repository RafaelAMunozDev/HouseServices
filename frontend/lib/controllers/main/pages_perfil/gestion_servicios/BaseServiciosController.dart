import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../services/UsuarioService.dart';

// clase base para controllers de servicios con actualizacion automatica
abstract class BaseServiciosController {
  final UsuarioService _usuarioService = UsuarioService();

  // estado del controlador
  bool _estaCargando = false;
  String? _mensajeError;
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  // acceso al estado actual
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;

  // inicia la actualizacion automatica de datos cada 30 segundos
  void iniciarAutoRefresh(Function() cargarDatos) {
    cancelarAutoRefresh();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_estaCargando) {
        cargarDatos();
      }
    });
  }

  // detiene la actualizacion automatica
  void cancelarAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // actualiza el estado de carga y errores
  void actualizarEstadoCarga(bool cargando, Function actualizarEstado, {String? error}) {
    _estaCargando = cargando;
    _mensajeError = error;
    actualizarEstado();
  }

  // obtiene el id numerico del usuario actual
  Future<int?> obtenerIdUsuario() async {
    try {
      return await _usuarioService.obtenerIdNumericoUsuario();
    } catch (e) {
      return null;
    }
  }

  // muestra mensaje de exito o error segun el color
  void mostrarMensajeExito(BuildContext context, String mensaje, Color color) {
    final colorFinal = (color == Colors.red) ? Colors.red : Colors.green;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: colorFinal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // muestra mensaje de error en rojo
  void mostrarMensajeError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // limpia el estado y cancela timers
  void limpiarDatosBase() {
    _estaCargando = false;
    _mensajeError = null;
    cancelarAutoRefresh();
  }

  // libera recursos cuando se destruye el widget
  void dispose() {
    cancelarAutoRefresh();
  }
}