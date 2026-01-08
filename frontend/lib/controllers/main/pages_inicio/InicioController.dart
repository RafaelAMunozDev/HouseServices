import '../../../models/ServicioDisponible.dart';
import '../../../services/ServicioDisponibleService.dart';
import '../../../services/UsuarioService.dart';

// controller para la pagina de inicio
class InicioController {
  // servicios
  final ServicioDisponibleService _servicioDisponibleService = ServicioDisponibleService();
  final UsuarioService _usuarioService = UsuarioService();

  // estados para servicios populares
  bool _estaCargandoPopulares = false;
  List<ServicioDisponible> _serviciosPopulares = [];
  String? _mensajeErrorPopulares;

  // estados para busqueda
  bool _estaCargandoBusqueda = false;
  List<ServicioDisponible> _resultadosBusqueda = [];
  String? _mensajeErrorBusqueda;
  bool _mostrandoBusqueda = false;

  Function()? _onStateChanged;

  // getters para servicios populares
  bool get estaCargandoPopulares => _estaCargandoPopulares;
  List<ServicioDisponible> get serviciosPopulares => _serviciosPopulares;
  String? get mensajeErrorPopulares => _mensajeErrorPopulares;

  // getters para busqueda
  bool get estaCargandoBusqueda => _estaCargandoBusqueda;
  List<ServicioDisponible> get resultadosBusqueda => _resultadosBusqueda;
  String? get mensajeErrorBusqueda => _mensajeErrorBusqueda;
  bool get mostrandoBusqueda => _mostrandoBusqueda;

  // inicializar controller
  void init(Function() onStateChanged) {
    _onStateChanged = onStateChanged;
  }

  // cargar servicios mas populares
  Future<void> cargarServiciosPopulares() async {
    try {
      _actualizarEstadoPopulares(estaCargando: true, mensajeError: null);

      final idUsuarioActual = await _usuarioService.obtenerIdNumericoUsuario();
      final servicios = await _servicioDisponibleService.obtenerServiciosMasPopulares(excluirTrabajadorId: idUsuarioActual);

      _actualizarEstadoPopulares(estaCargando: false, servicios: servicios);
    } catch (e) {
      _actualizarEstadoPopulares(estaCargando: false, mensajeError: 'Error al cargar servicios populares');
    }
  }

  // buscar servicios por texto
  Future<void> buscarServicios(String textoBusqueda) async {
    try {
      _actualizarEstadoBusqueda(estaCargando: true, mensajeError: null, mostrando: true);

      final idUsuarioActual = await _usuarioService.obtenerIdNumericoUsuario();
      final resultados = await _servicioDisponibleService.buscarServicios(textoBusqueda, excluirTrabajadorId: idUsuarioActual);

      _actualizarEstadoBusqueda(estaCargando: false, resultados: resultados);
    } catch (e) {
      _actualizarEstadoBusqueda(estaCargando: false, mensajeError: 'Error en la busqueda');
    }
  }

  // limpiar busqueda
  void limpiarBusqueda() {
    _actualizarEstadoBusqueda(mostrando: false, resultados: [], mensajeError: null);
  }

  // actualizar estado de servicios populares
  void _actualizarEstadoPopulares({
    bool? estaCargando,
    List<ServicioDisponible>? servicios,
    String? mensajeError,
  }) {
    if (estaCargando != null) _estaCargandoPopulares = estaCargando;
    if (servicios != null) _serviciosPopulares = servicios;
    if (mensajeError != null) _mensajeErrorPopulares = mensajeError;
    _onStateChanged?.call();
  }

  // actualizar estado de busqueda
  void _actualizarEstadoBusqueda({
    bool? estaCargando,
    List<ServicioDisponible>? resultados,
    String? mensajeError,
    bool? mostrando,
  }) {
    if (estaCargando != null) _estaCargandoBusqueda = estaCargando;
    if (resultados != null) _resultadosBusqueda = resultados;
    if (mensajeError != null) _mensajeErrorBusqueda = mensajeError;
    if (mostrando != null) _mostrandoBusqueda = mostrando;
    _onStateChanged?.call();
  }

  // limpiar recursos
  void dispose() {
    _onStateChanged = null;
  }
}