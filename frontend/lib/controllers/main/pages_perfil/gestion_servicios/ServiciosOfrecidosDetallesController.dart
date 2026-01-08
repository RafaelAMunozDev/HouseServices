import '../../../../models/ServicioDisponible.dart';
import '../../../../services/ServicioDisponibleService.dart';

// controla la logica de la pantalla de detalles de servicios ofrecidos
class ServiciosOfrecidosDetallesController {
  // estado del controlador
  bool _estaCargando = true;
  ServicioDisponible? _servicio;
  String? _mensajeError;

  // acceso al estado actual
  bool get estaCargando => _estaCargando;
  ServicioDisponible? get servicio => _servicio;
  String? get mensajeError => _mensajeError;

  final ServicioDisponibleService _servicioDisponibleService = ServicioDisponibleService();
  Function()? _onStateChanged;

  // inicializa el controlador con callback de actualizacion
  void init(Function() onStateChanged) {
    _onStateChanged = onStateChanged;
  }

  // carga los detalles completos del servicio
  Future<void> cargarServicioDetalles(int servicioId) async {
    try {
      _actualizarEstado(estaCargando: true, mensajeError: null);

      final servicio = await _servicioDisponibleService.obtenerServicioDisponiblePorId(servicioId);

      _actualizarEstado(estaCargando: false, servicio: servicio);
    } catch (e) {
      _actualizarEstado(
        estaCargando: false,
        mensajeError: 'Error al cargar el detalle del servicio: ${e.toString()}',
      );
    }
  }

  // elimina el servicio del sistema
  Future<bool> eliminarServicio() async {
    if (_servicio == null) return false;

    try {
      _actualizarEstado(estaCargando: true);

      final eliminado = await _servicioDisponibleService.eliminarServicioDisponible(_servicio!.id);

      if (!eliminado) {
        _actualizarEstado(estaCargando: false);
      }

      return eliminado;
    } catch (e) {
      _actualizarEstado(
        estaCargando: false,
        mensajeError: 'Error al eliminar el servicio: ${e.toString()}',
      );
      return false;
    }
  }

  // actualiza el estado y notifica cambios
  void _actualizarEstado({
    bool? estaCargando,
    ServicioDisponible? servicio,
    String? mensajeError,
  }) {
    if (estaCargando != null) _estaCargando = estaCargando;
    if (servicio != null) _servicio = servicio;
    if (mensajeError != null) _mensajeError = mensajeError;

    _onStateChanged?.call();
  }

  // obtiene la descripcion completa del servicio
  String obtenerDescripcionCompleta() {
    if (_servicio?.descripcion != null && _servicio!.descripcion!.isNotEmpty) {
      return _servicio!.descripcion!;
    }
    return 'Sin descripción disponible.';
  }

  // obtiene las observaciones del servicio
  String? obtenerObservaciones() {
    return _servicio?.observaciones;
  }

  // verifica si el servicio tiene observaciones
  bool tieneObservaciones() {
    return _servicio?.observaciones != null && _servicio!.observaciones!.isNotEmpty;
  }

  // libera recursos del controlador
  void dispose() {
    _onStateChanged = null;
  }
}