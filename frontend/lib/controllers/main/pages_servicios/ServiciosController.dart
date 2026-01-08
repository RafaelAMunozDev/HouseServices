import '../../../models/Servicio.dart';
import '../../../services/ServicioService.dart';

// controller para la pantalla de servicios/categorias
class ServiciosController {
  // estado basico
  bool _estaCargando = false;
  List<Servicio> _servicios = [];
  String? _mensajeError;

  final ServicioService _servicioService = ServicioService();

  // getters
  bool get estaCargando => _estaCargando;
  List<Servicio> get servicios => _servicios;
  String? get mensajeError => _mensajeError;

  Function()? _onStateChanged;

  // inicializar controller
  void init(Function() onStateChanged) {
    _onStateChanged = onStateChanged;
  }

  // cargar tipos de servicios
  Future<void> cargarServicios() async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      _onStateChanged?.call();

      final servicios = await _servicioService.obtenerTodosLosServicios();

      _estaCargando = false;
      _servicios = servicios;
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