import '../models/ServicioContratado.dart';
import 'ApiService.dart';

// servicio para manejo de servicios contratados y su gestion
class ServicioContratadoService {
  static final ServicioContratadoService _instancia = ServicioContratadoService._interno();
  factory ServicioContratadoService() => _instancia;
  ServicioContratadoService._interno();

  final ApiService _apiService = ApiService();

  // obtiene servicios pendientes de un trabajador con estado solicitado
  Future<List<ServicioContratado>> obtenerServiciosPendientes(int trabajadorId) async {
    try {
      final respuesta = await _apiService.get('servicios-contratados/trabajador/$trabajadorId/pendientes');

      if (respuesta != null && respuesta is List) {
        final servicios = respuesta
            .map((json) => ServicioContratado.fromJson(json))
            .toList();

        return servicios;
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener servicios pendientes: $e');
    }
  }

  // obtiene servicios en gestion de un trabajador confirmados rechazados completados
  Future<List<ServicioContratado>> obtenerServiciosEnGestion(int trabajadorId) async {
    try {
      final respuesta = await _apiService.get('servicios-contratados/trabajador/$trabajadorId/gestion');

      if (respuesta != null && respuesta is List) {
        final servicios = respuesta
            .map((json) => ServicioContratado.fromJson(json))
            .toList();

        return servicios;
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener servicios en gestión: $e');
    }
  }

  // obtiene todos los servicios de un trabajador
  Future<List<ServicioContratado>> obtenerTodosLosServicios(int trabajadorId) async {
    try {
      final respuesta = await _apiService.get('servicios-contratados/trabajador/$trabajadorId');

      if (respuesta != null && respuesta is List) {
        final servicios = respuesta
            .map((json) => ServicioContratado.fromJson(json))
            .toList();

        return servicios;
      }

      return [];
    } catch (e) {
      throw Exception('Error al obtener todos los servicios: $e');
    }
  }

  // confirma un servicio trabajador acepta
  Future<ServicioContratado?> confirmarServicio(int servicioId, int trabajadorId) async {
    try {
      // envia trabajadorid como query parameter no en body
      final respuesta = await _apiService.put(
          'servicios-contratados/$servicioId/confirmar?trabajadorId=$trabajadorId',
          {}
      );

      if (respuesta != null) {
        return ServicioContratado.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al confirmar servicio: $e');
    }
  }

  // obtiene historial de servicios contratados por cliente
  Future<List<ServicioContratado>> obtenerHistorialCliente(int clienteId) async {
    try {
      final respuesta = await _apiService.get('servicios-contratados/cliente/$clienteId/historial');

      if (respuesta != null && respuesta is List) {
        final servicios = <ServicioContratado>[];

        for (int i = 0; i < respuesta.length; i++) {
          try {
            final servicioJson = respuesta[i];
            final servicio = ServicioContratado.fromJson(servicioJson);
            servicios.add(servicio);
          } catch (e) {
            // continua con el siguiente elemento en lugar de fallar
          }
        }

        return servicios;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  // rechaza un servicio trabajador rechaza
  Future<ServicioContratado?> rechazarServicio(int servicioId, int trabajadorId) async {
    try {
      // envia trabajadorid como query parameter no en body
      final respuesta = await _apiService.put(
          'servicios-contratados/$servicioId/rechazar?trabajadorId=$trabajadorId',
          {}
      );

      if (respuesta != null) {
        return ServicioContratado.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al rechazar servicio: $e');
    }
  }

  // inicia un servicio cambiar a en progreso
  Future<ServicioContratado?> iniciarServicio(int servicioId, int trabajadorId) async {
    try {
      // envia trabajadorid como query parameter no en body
      final respuesta = await _apiService.put(
          'servicios-contratados/$servicioId/iniciar?trabajadorId=$trabajadorId',
          {}
      );

      if (respuesta != null) {
        return ServicioContratado.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al iniciar servicio: $e');
    }
  }

  // completa un servicio
  Future<ServicioContratado?> completarServicio(int servicioId, int trabajadorId) async {
    try {
      // envia trabajadorid como query parameter no en body
      final respuesta = await _apiService.put(
          'servicios-contratados/$servicioId/completar?trabajadorId=$trabajadorId',
          {}
      );

      if (respuesta != null) {
        return ServicioContratado.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al completar servicio: $e');
    }
  }

  // obtiene detalles de un servicio especifico
  Future<ServicioContratado?> obtenerDetalleServicio(int servicioId) async {
    try {
      final respuesta = await _apiService.get('servicios-contratados/$servicioId');

      if (respuesta != null) {
        final servicio = ServicioContratado.fromJson(respuesta);
        return servicio;
      }

      return null;
    } catch (e) {
      throw Exception('Error al obtener detalles del servicio: $e');
    }
  }

  // cancela un servicio desde el lado del cliente
  Future<ServicioContratado?> cancelarServicio(int servicioId, int clienteId) async {
    try {
      final respuesta = await _apiService.put(
        'servicios-contratados/$servicioId/cancelar?clienteId=$clienteId',
        {},
      );

      // si el backend devolvio un error tipico { "message": "..." }
      if (respuesta is Map && respuesta['message'] != null && (respuesta['id'] == null)) {
        throw Exception(respuesta['message'].toString());
      }

      if (respuesta != null) {
        return ServicioContratado.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      throw Exception('Error al cancelar servicio: $e');
    }
  }

}