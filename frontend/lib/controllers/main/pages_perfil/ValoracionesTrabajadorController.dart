import 'package:flutter/material.dart';
import '../../../../models/Valoracion.dart';
import '../../../../services/ValoracionesService.dart';
import '../../../../services/UsuarioService.dart';
import '../../../../utils/OperacionesServicios.dart';

class ValoracionesTrabajadorController {
  final ValoracionesService _valoracionesService = ValoracionesService();
  final UsuarioService _usuarioService = UsuarioService();

  // estado
  List<Valoracion> _valoraciones = [];
  Map<String, dynamic> _estadisticas = {};
  bool _estaCargando = false;
  String? _mensajeError;

  // getters
  List<Valoracion> get valoraciones => _valoraciones;
  Map<String, dynamic> get estadisticas => _estadisticas;
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  bool get tieneValoraciones => _valoraciones.isNotEmpty;

  // cargar valoraciones del trabajador
  Future<void> cargarValoraciones(Function actualizarEstado) async {
    _actualizarEstadoCarga(true, actualizarEstado);

    final usuario = await _usuarioService.obtenerUsuarioActual();
    if (usuario?.id == null) {
      throw Exception('No se pudo obtener el ID del usuario');
    }

    final idTrabajador = int.parse(usuario!.id!);
    _valoraciones = await _valoracionesService.obtenerValoracionesTrabajador(idTrabajador);
    _estadisticas = await _valoracionesService.obtenerEstadisticasTrabajador(idTrabajador);

    _actualizarEstadoCarga(false, actualizarEstado);
  }

  // obtener valoracion promedio
  double get promedioValoraciones {
    if (_estadisticas.containsKey('promedio')) {
      return _estadisticas['promedio'] as double;
    }
    return 0.0;
  }

  // obtener total de valoraciones
  int get totalValoraciones {
    if (_estadisticas.containsKey('total')) {
      return _estadisticas['total'] as int;
    }
    return 0;
  }

  // obtener distribucion de estrellas
  Map<int, int> get distribucionEstrellas {
    if (_estadisticas.containsKey('distribucion')) {
      return Map<int, int>.from(_estadisticas['distribucion']);
    }
    return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  }

  // obtener valoraciones mas recientes
  List<Valoracion> get valoracionesRecientes {
    if (_valoraciones.length <= 5) return _valoraciones;
    return _valoraciones.take(5).toList();
  }

  // filtrar valoraciones por puntuacion
  List<Valoracion> obtenerValoracionesPorPuntuacion(int puntuacion) {
    return _valoraciones.where((v) => v.puntuacion == puntuacion).toList();
  }

  // verificar si tiene valoraciones excelentes
  bool get tieneValoracionesExcelentes {
    return _valoraciones.any((v) => v.puntuacion >= 4);
  }

  // obtener porcentaje de valoraciones positivas
  double get porcentajeValoracionesPositivas {
    if (_valoraciones.isEmpty) return 0.0;
    final positivas = _valoraciones.where((v) => v.puntuacion >= 4).length;
    return (positivas / _valoraciones.length) * 100;
  }

  // actualizar estado de carga
  void _actualizarEstadoCarga(bool cargando, Function actualizarEstado, {String? error}) {
    _estaCargando = cargando;
    _mensajeError = error;
    actualizarEstado();
  }

  // widgets de estado
  Widget construirIndicadorCarga() => OperacionesServicios.construirIndicadorCarga();
  Widget construirVistaError(Function cargarDatos) => OperacionesServicios.construirVistaError(_mensajeError, cargarDatos);

  // recargar valoraciones
  Future<void> recargarValoraciones(Function actualizarEstado) async {
    await cargarValoraciones(actualizarEstado);
  }

  // buscar valoraciones
  List<Valoracion> buscarValoraciones(String termino) {
    if (termino.isEmpty) return _valoraciones;

    final terminoLower = termino.toLowerCase();
    return _valoraciones.where((valoracion) {
      final nombreCliente = valoracion.nombreCompletoCliente.toLowerCase();
      final comentario = (valoracion.comentario ?? '').toLowerCase();
      final servicio = (valoracion.nombreServicio ?? '').toLowerCase();

      return nombreCliente.contains(terminoLower) || comentario.contains(terminoLower) || servicio.contains(terminoLower);
    }).toList();
  }

  // obtener estadisticas resumidas
  Map<String, dynamic> get estadisticasResumidas {
    return {
      'promedio': promedioValoraciones,
      'total': totalValoraciones,
      'positivas': porcentajeValoracionesPositivas,
      'tieneValoraciones': tieneValoraciones,
    };
  }

  // limpiar datos
  void dispose() {
    _valoraciones.clear();
    _estadisticas.clear();
    _estaCargando = false;
    _mensajeError = null;
  }
}