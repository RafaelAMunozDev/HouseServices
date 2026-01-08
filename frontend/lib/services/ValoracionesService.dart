import '../models/Valoracion.dart';
import 'ApiService.dart';

// servicio para manejo de valoraciones de servicios
class ValoracionesService {
  static final ValoracionesService _instancia = ValoracionesService._interno();
  factory ValoracionesService() => _instancia;
  ValoracionesService._interno();

  final ApiService _apiService = ApiService();

  // crea valoracion con trabajadorid y clienteid como parametro url
  Future<Valoracion?> crearValoracion({
    required int clienteId,
    required int trabajadorId,
    required int servicioContratadoId,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final request = {
        'servicio_contratado_id': servicioContratadoId,
        'trabajador_id': trabajadorId,
        'puntuacion': puntuacion,
        'comentario': comentario,
      };

      // clienteid como parametro de url
      final respuesta = await _apiService.post(
        'valoraciones?clienteId=$clienteId',
        request,
      );

      if (respuesta != null) {
        return Valoracion.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al crear valoración: $e');
    }
  }

  // obtiene valoraciones realizadas por un cliente
  Future<List<Valoracion>> obtenerValoracionesCliente(int clienteId) async {
    try {
      final respuesta = await _apiService.get('valoraciones/cliente/$clienteId');

      if (respuesta != null && respuesta is List) {
        final valoraciones = respuesta
            .map((json) => Valoracion.fromJson(json))
            .toList();

        return valoraciones;
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener valoraciones del cliente: $e');
    }
  }

  // obtiene valoraciones recibidas por un trabajador
  Future<List<Valoracion>> obtenerValoracionesTrabajador(int trabajadorId) async {
    try {
      final respuesta = await _apiService.get('valoraciones/trabajador/$trabajadorId');

      if (respuesta != null && respuesta is List) {
        final valoraciones = respuesta
            .map((json) => Valoracion.fromJsonConDetalles(json))
            .toList();

        return valoraciones;
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener valoraciones del trabajador: $e');
    }
  }

  // obtiene valoracion especifica de un servicio
  Future<Valoracion?> obtenerValoracionServicio(int servicioContratadoId) async {
    try {
      final respuesta = await _apiService.get('valoraciones/servicio/$servicioContratadoId');

      if (respuesta != null) {
        return Valoracion.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // verifica si un servicio ya fue valorado
  Future<bool> existeValoracion(int servicioContratadoId) async {
    try {
      final respuesta = await _apiService.get('valoraciones/servicio/$servicioContratadoId/existe');

      if (respuesta != null && respuesta is Map<String, dynamic>) {
        final existe = respuesta['existe'] as bool;
        return existe;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // obtiene servicios completados sin valorar para un cliente
  Future<List<Map<String, dynamic>>> obtenerServiciosCompletadosSinValorar(int clienteId) async {
    try {
      final respuesta = await _apiService.get('valoraciones/cliente/$clienteId/pendientes');

      if (respuesta != null && respuesta is List) {
        return respuesta.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // calcula promedio de valoraciones de un trabajador
  Future<Map<String, dynamic>> obtenerEstadisticasTrabajador(int trabajadorId) async {
    try {
      final valoraciones = await obtenerValoracionesTrabajador(trabajadorId);

      if (valoraciones.isEmpty) {
        return {
          'promedio': 0.0,
          'total': 0,
          'distribucion': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      // calcula promedio
      final totalPuntos = valoraciones.fold<int>(0, (sum, v) => sum + v.puntuacion);
      final promedio = totalPuntos / valoraciones.length;

      // calcula distribucion por estrellas
      final distribucion = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (final valoracion in valoraciones) {
        distribucion[valoracion.puntuacion] = (distribucion[valoracion.puntuacion] ?? 0) + 1;
      }

      return {
        'promedio': double.parse(promedio.toStringAsFixed(1)),
        'total': valoraciones.length,
        'distribucion': distribucion,
        'valoraciones': valoraciones,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas del trabajador: $e');
    }
  }
}