import '../../../models/ServicioDisponible.dart';
import '../../../services/ServicioDisponibleService.dart';
import '../../../services/UsuarioService.dart';

// controller para servicios filtrados por categoria
class ServiciosPorCategoriaController {
  // estado basico
  bool _estaCargando = false;
  List<ServicioDisponible> _servicios = [];
  String? _mensajeError;

  final ServicioDisponibleService _servicioDisponibleService = ServicioDisponibleService();
  final UsuarioService _usuarioService = UsuarioService();

  // getters
  bool get estaCargando => _estaCargando;
  List<ServicioDisponible> get servicios => _servicios;
  String? get mensajeError => _mensajeError;

  Function()? _onStateChanged;

  // inicializar controller
  void init(Function() onStateChanged) {
    _onStateChanged = onStateChanged;
  }

  // cargar servicios por categoria
  Future<void> cargarServiciosPorCategoria(int categoriaId) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      _onStateChanged?.call();

      final idUsuarioActual = await _usuarioService.obtenerIdNumericoUsuario();
      final todosLosServicios = await _servicioDisponibleService.obtenerTodosLosServiciosOfrecidos();

      final serviciosFiltrados = todosLosServicios.where((servicio) {
        return servicio.servicioId == categoriaId && (idUsuarioActual == null || servicio.trabajadorId != idUsuarioActual);
      }).toList();

      serviciosFiltrados.sort((a, b) => b.valoracionPromedio.compareTo(a.valoracionPromedio));

      _estaCargando = false;
      _servicios = serviciosFiltrados;
      _onStateChanged?.call();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al cargar servicios';
      _onStateChanged?.call();
    }
  }

  // limpiar recursos
  void dispose() {
    _onStateChanged = null;
  }
}