import '../../../models/ServicioDisponible.dart';
import '../../../services/FavoritosService.dart';

// controller para la pantalla de favoritos
class FavoritosController {
  // estado basico
  bool _estaCargando = false;
  List<ServicioDisponible> _serviciosFavoritos = [];
  String? _mensajeError;

  final FavoritosService _favoritosService = FavoritosService();

  // getters
  bool get estaCargando => _estaCargando;
  List<ServicioDisponible> get serviciosFavoritos => _serviciosFavoritos;
  String? get mensajeError => _mensajeError;
  bool get tieneFavoritos => _serviciosFavoritos.isNotEmpty;

  Function()? _onStateChanged;

  // inicializar controller
  void init(Function() onStateChanged) {
    _onStateChanged = onStateChanged;
  }

  // cargar servicios favoritos del usuario
  Future<void> cargarFavoritos() async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      _onStateChanged?.call();

      final favoritos = await _favoritosService.obtenerServiciosFavoritos();

      _estaCargando = false;
      _serviciosFavoritos = favoritos;
      _onStateChanged?.call();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al cargar favoritos';
      _onStateChanged?.call();
    }
  }

  // quitar servicio de favoritos
  Future<void> quitarDeFavoritos(int servicioId) async {
    try {
      await _favoritosService.quitarFavorito(servicioId);
      _serviciosFavoritos.removeWhere((servicio) => servicio.id == servicioId);
      _onStateChanged?.call();
    } catch (e) {
      _mensajeError = 'Error al eliminar de favoritos';
      _onStateChanged?.call();
    }
  }

  // limpiar recursos
  void dispose() {
    _onStateChanged = null;
  }
}