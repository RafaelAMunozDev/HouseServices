import '../models/ServicioDisponible.dart';
import 'ApiService.dart';
import '../models/HorarioServicio.dart';

// servicio para manejo de servicios disponibles ofrecidos por trabajadores
class ServicioDisponibleService {
  static final ServicioDisponibleService _instancia = ServicioDisponibleService._interno();
  factory ServicioDisponibleService() => _instancia;
  ServicioDisponibleService._interno();

  final ApiService _apiService = ApiService();

  // obtiene todos los servicios ofrecidos
  Future<List<ServicioDisponible>> obtenerTodosLosServiciosOfrecidos() async {
    try {
      final respuesta = await _apiService.get('servicios/disponibles');
      if (respuesta == null) return [];

      return (respuesta as List)
          .map((item) => ServicioDisponible.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // obtiene servicio por id especifico
  Future<ServicioDisponible?> obtenerServicioDisponiblePorId(int id) async {
    try {
      final respuesta = await _apiService.get('servicios/disponibles/$id');
      return respuesta != null ? ServicioDisponible.fromJson(respuesta) : null;
    } catch (e) {
      return null;
    }
  }

  // obtiene servicios ofrecidos por un trabajador especifico
  Future<List<ServicioDisponible>> obtenerServiciosOfrecidosPorTrabajador(int trabajadorId) async {
    try {
      final respuesta = await _apiService.get('servicios/disponibles/trabajador/$trabajadorId');
      if (respuesta == null) return [];

      return (respuesta as List)
          .map((item) => ServicioDisponible.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // obtiene horas ocupadas para un servicio y fecha
  Future<List<String>> obtenerHorasOcupadas({
    required int servicioDisponibleId,
    required DateTime fecha,
  }) async {
    try {
      final fechaStr =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

      final respuesta = await _apiService.get(
        'servicios-contratados/disponibilidad/$servicioDisponibleId?fecha=$fechaStr',
      );

      if (respuesta == null) return [];

      final lista = (respuesta['horas_ocupadas'] as List?) ?? [];
      return lista.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // crea nuevo servicio disponible
  Future<ServicioDisponible?> crearServicioDisponible(Map<String, dynamic> datos) async {
    try {
      final respuesta = await _apiService.post('servicios/disponibles', datos);
      return respuesta != null ? ServicioDisponible.fromJson(respuesta) : null;
    } catch (e) {
      rethrow;
    }
  }

  // actualiza servicio existente
  Future<ServicioDisponible?> actualizarServicioDisponible(int id, Map<String, dynamic> datos) async {
    try {
      final respuesta = await _apiService.put('servicios/disponibles/$id', datos);
      return respuesta != null ? ServicioDisponible.fromJson(respuesta) : null;
    } catch (e) {
      return null;
    }
  }

  // elimina servicio disponible
  Future<bool> eliminarServicioDisponible(int id) async {
    try {
      final respuesta = await _apiService.delete('servicios/disponibles/$id');
      return respuesta != null && respuesta['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // obtiene horario de un servicio
  Future<HorarioServicio?> obtenerHorarioServicio(int servicioId) async {
    try {
      final respuesta = await _apiService.get('servicios/disponibles/$servicioId/horario');
      return respuesta != null ? HorarioServicio.fromJson(respuesta) : HorarioServicio.empty();
    } catch (e) {
      return HorarioServicio.empty();
    }
  }

  // guarda horario de servicio con validacion de solapamientos
  Future<Map<String, dynamic>> guardarHorarioServicio(int servicioId, HorarioServicio horario) async {
    try {
      final respuesta = await _apiService.put(
          'servicios/disponibles/$servicioId/horario',
          horario.toJson()
      );

      if (respuesta != null && respuesta['success'] == false) {
        return {
          'exito': false,
          'mensaje': respuesta['message'] ?? 'El horario se solapa con otros servicios'
        };
      }

      return {
        'exito': true,
        'mensaje': 'Horario guardado correctamente'
      };
    } catch (e) {
      if (e.toString().contains('400')) {
        return {
          'exito': false,
          'mensaje': 'El horario se solapa con otros servicios'
        };
      }

      return {
        'exito': false,
        'mensaje': 'Error al guardar horario'
      };
    }
  }

  // valida horario sin guardar para prevenir conflictos
  Future<Map<String, dynamic>> validarHorarioSinGuardar({
    required int trabajadorId,
    required HorarioServicio horario,
    int? servicioIdExcluir,
  }) async {
    try {
      final queryParams = {
        'trabajadorId': trabajadorId.toString(),
        if (servicioIdExcluir != null) 'servicioIdExcluir': servicioIdExcluir.toString(),
      };

      final respuesta = await _apiService.post(
          'servicios/disponibles/validar-horario?${Uri(queryParameters: queryParams).query}',
          horario.toJson()
      );

      if (respuesta != null) {
        return {
          'valido': respuesta['valido'] ?? false,
          'mensaje': respuesta['mensaje'] ?? 'Error desconocido'
        };
      }

      return {
        'valido': false,
        'mensaje': 'No se pudo validar el horario'
      };
    } catch (e) {
      return {
        'valido': false,
        'mensaje': 'Error al validar horario'
      };
    }
  }

  // obtiene servicios mas populares con opcion de excluir trabajador
  Future<List<ServicioDisponible>> obtenerServiciosMasPopulares({
    int? excluirTrabajadorId,
  }) async {
    try {
      String url = 'servicios/disponibles/mas-populares';

      // anade parametros si es necesario
      if (excluirTrabajadorId != null) {
        url += '?excluirTrabajadorId=$excluirTrabajadorId';
      }

      final respuesta = await _apiService.get(url);
      if (respuesta == null) return [];

      return (respuesta as List)
          .map((item) => ServicioDisponible.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // busca servicios por texto en nombre descripcion o trabajador
  Future<List<ServicioDisponible>> buscarServicios(
      String textoBusqueda, {
        int? excluirTrabajadorId,
      }) async {
    try {
      if (textoBusqueda.trim().length < 2) {
        throw Exception('El texto de búsqueda debe tener al menos 2 caracteres');
      }

      String url = 'servicios/disponibles/buscar?q=${Uri.encodeComponent(textoBusqueda.trim())}';

      // anade parametros adicionales si es necesario
      if (excluirTrabajadorId != null) {
        url += '&excluirTrabajadorId=$excluirTrabajadorId';
      }

      final respuesta = await _apiService.get(url);
      if (respuesta == null) return [];

      return (respuesta as List)
          .map((item) => ServicioDisponible.fromJson(item))
          .toList();
    } catch (e) {
      rethrow; // relanza para que el controller pueda manejar el error
    }
  }
}