import '../models/Servicio.dart';
import 'ApiService.dart';

// servicio para manejar los tipos de servicios disponibles
class ServicioService {
  static final ServicioService _instancia = ServicioService._interno();
  factory ServicioService() => _instancia;
  ServicioService._interno();

  final ApiService _apiService = ApiService();

  // obtiene todos los tipos de servicios disponibles
  Future<List<Servicio>> obtenerTodosLosServicios() async {
    try {
      final respuesta = await _apiService.get('tipos-servicios');
      if (respuesta == null) {
        return [];
      }

      final List<Servicio> servicios = (respuesta as List)
          .map((item) => Servicio.fromJson(item))
          .toList();

      return servicios;
    } catch (e) {
      return [];
    }
  }

  // obtiene un tipo de servicio por id
  Future<Servicio?> obtenerServicioPorId(int id) async {
    try {
      final respuesta = await _apiService.get('tipos-servicios/$id');
      if (respuesta == null) {
        return null;
      }

      final servicio = Servicio.fromJson(respuesta);
      return servicio;
    } catch (e) {
      return null;
    }
  }

  // busca servicios por nombre para filtrado local
  Future<List<Servicio>> buscarServiciosPorNombre(String termino) async {
    try {
      final todosLosServicios = await obtenerTodosLosServicios();

      if (termino.isEmpty) {
        return todosLosServicios;
      }

      return todosLosServicios.where((servicio) {
        return servicio.nombre.toLowerCase().contains(termino.toLowerCase()) ||
            (servicio.descripcion?.toLowerCase().contains(termino.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // obtiene servicios mas populares basado en cantidad de servicios disponibles
  Future<List<Servicio>> obtenerServiciosPopulares({int limite = 6}) async {
    try {
      // por ahora devuelve todos y limita localmente
      // en el futuro se puede hacer endpoint especifico en backend
      final servicios = await obtenerTodosLosServicios();

      // toma solo los primeros n servicios
      return servicios.take(limite).toList();
    } catch (e) {
      return [];
    }
  }
}