import 'package:flutter/material.dart';
import '../../../../models/HorarioServicio.dart';
import '../../../../models/ServicioDisponible.dart';
import '../../../../services/ApiService.dart';
import '../../../../services/ServicioDisponibleService.dart';
import '../../../../services/UsuarioService.dart';
import '../../../../utils/Dialogos.dart';
import '../../../../widgets/ServiciosWidgets.dart';
import '../../../../widgets/TextoEscalable.dart';
import 'dart:async';

// controla la logica de servicios ofrecidos por el trabajador
class ServiciosOfrecidosController {
  static final ServiciosOfrecidosController _instancia = ServiciosOfrecidosController._interno();
  factory ServiciosOfrecidosController() => _instancia;
  ServiciosOfrecidosController._interno();

  // servicios necesarios para la funcionalidad
  final ServicioDisponibleService _servicioDisponibleService = ServicioDisponibleService();
  final UsuarioService _usuarioService = UsuarioService();
  final ApiService _apiService = ApiService();

  // estado interno del controlador
  bool _estaCargando = false;
  List<ServicioDisponible> _serviciosOfrecidos = [];
  String? _mensajeError;
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  // acceso al estado actual
  bool get estaCargando => _estaCargando;
  List<ServicioDisponible> get serviciosOfrecidos => _serviciosOfrecidos;
  String? get mensajeError => _mensajeError;
  bool get tieneServicios => _serviciosOfrecidos.isNotEmpty;

  // carga todos los servicios disponibles para la pantalla de inicio
  Future<void> cargarTodosLosServiciosDisponibles(Function actualizarEstado) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      actualizarEstado();

      final servicios = await _servicioDisponibleService.obtenerTodosLosServiciosOfrecidos();
      _serviciosOfrecidos = servicios;
      _estaCargando = false;
      actualizarEstado();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al cargar los servicios: ${e.toString()}';
      actualizarEstado();
    }
  }

  // carga los servicios del usuario actual para la pantalla de perfil
  Future<void> cargarServiciosOfrecidos(Function actualizarEstado, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _estaCargando = true;
        _mensajeError = null;
        actualizarEstado();
      }

      // obtiene el id del usuario actual
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        _serviciosOfrecidos = [];
        if (!silencioso) {
          _estaCargando = false;
          _mensajeError = 'No se pudo obtener el ID del usuario actual';
        }
        actualizarEstado();
        return;
      }

      // obtiene servicios del trabajador
      final servicios = await _servicioDisponibleService.obtenerServiciosOfrecidosPorTrabajador(idUsuario);
      _serviciosOfrecidos = servicios;

      if (!silencioso) {
        _estaCargando = false;
      }
      actualizarEstado();
    } catch (e) {
      if (!silencioso) {
        _estaCargando = false;
        _mensajeError = 'Error al cargar los servicios: ${e.toString()}';
      }
      actualizarEstado();
    }
  }

  // carga servicios de un trabajador especifico
  Future<void> cargarServiciosPorTrabajador(int trabajadorId, Function actualizarEstado) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      actualizarEstado();

      final servicios = await _servicioDisponibleService.obtenerServiciosOfrecidosPorTrabajador(trabajadorId);
      _serviciosOfrecidos = servicios;
      _estaCargando = false;
      actualizarEstado();
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al cargar los servicios del trabajador: ${e.toString()}';
      actualizarEstado();
    }
  }

  // crea un nuevo servicio ofrecido
  Future<ServicioDisponible?> crearServicioDisponible(Map<String, dynamic> datos, Function actualizarEstado, {Function? recargarDatos}) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      actualizarEstado();

      // valida campos requeridos segun el backend
      final camposRequeridos = ['servicio_id', 'precio_hora'];
      final camposFaltantes = <String>[];

      for (String campo in camposRequeridos) {
        if (!datos.containsKey(campo) || datos[campo] == null) {
          camposFaltantes.add(campo);
        }
      }

      if (camposFaltantes.isNotEmpty) {
        throw Exception('Campos requeridos faltantes: ${camposFaltantes.join(', ')}');
      }

      // obtiene id del usuario actual
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        throw Exception('No se pudo obtener el ID del usuario actual');
      }

      // formatea datos para el backend
      final datosFormateados = {
        'trabajador_id': idUsuario,
        'servicio_id': datos['servicio_id'] ?? datos['tipo_servicio_id'],
        'descripcion': datos['descripcion'],
        'observaciones': datos['observaciones'],
        'precio_hora': datos['precio_hora'] ?? datos['precio'],
      };

      // llama al servicio para crear
      final nuevoServicio = await _servicioDisponibleService.crearServicioDisponible(datosFormateados);

      // añade a la lista si se creo correctamente
      if (nuevoServicio != null) {
        _serviciosOfrecidos.add(nuevoServicio);
      }

      _estaCargando = false;
      actualizarEstado();

      if (recargarDatos != null) {
        await Future.delayed(Duration(milliseconds: 500));
        recargarDatos();
      }

      return nuevoServicio;
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al crear el servicio: ${e.toString()}';
      actualizarEstado();
      return null;
    }
  }

  // actualiza un servicio existente
  Future<ServicioDisponible?> actualizarServicioDisponible(int id, Map<String, dynamic> datos, Function actualizarEstado) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      actualizarEstado();

      final servicioActualizado = await _servicioDisponibleService.actualizarServicioDisponible(id, datos);

      // actualiza la lista si fue exitoso
      if (servicioActualizado != null) {
        final index = _serviciosOfrecidos.indexWhere((servicio) => servicio.id == id);
        if (index != -1) {
          _serviciosOfrecidos[index] = servicioActualizado;
        }
      }

      _estaCargando = false;
      actualizarEstado();
      return servicioActualizado;
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al actualizar el servicio: ${e.toString()}';
      actualizarEstado();
      return null;
    }
  }

  // elimina un servicio de la lista
  Future<bool> eliminarServicioDisponible(int id, Function actualizarEstado) async {
    try {
      _estaCargando = true;
      _mensajeError = null;
      actualizarEstado();

      final eliminado = await _servicioDisponibleService.eliminarServicioDisponible(id);

      // remueve de la lista local si fue exitoso
      if (eliminado) {
        _serviciosOfrecidos.removeWhere((servicio) => servicio.id == id);
      }

      _estaCargando = false;
      actualizarEstado();
      return eliminado;
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al eliminar el servicio: ${e.toString()}';
      actualizarEstado();
      return false;
    }
  }

  // obtiene los tipos de servicios desde el backend
  Future<List<Map<String, dynamic>>> obtenerTiposServicios() async {
    try {
      final respuesta = await _apiService.get('tipos-servicios');
      if (respuesta != null && respuesta is List) {
        return List<Map<String, dynamic>>.from(respuesta);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // obtiene el horario de un servicio especifico
  Future<HorarioServicio?> obtenerHorarioServicio(int servicioId) async {
    try {
      final respuesta = await _apiService.get('servicios/disponibles/$servicioId/horario');
      if (respuesta != null) {
        return HorarioServicio.fromJson(respuesta);
      }
      return HorarioServicio.empty();
    } catch (e) {
      return HorarioServicio.empty();
    }
  }

  // guarda el horario de un servicio
  Future<bool> guardarHorarioServicio(int servicioId, HorarioServicio horario) async {
    try {
      final respuesta = await _apiService.put(
          'servicios/disponibles/$servicioId/horario',
          horario.toJson()
      );
      return respuesta != null;
    } catch (e) {
      return false;
    }
  }

  // construye widget de indicador de carga
  Widget construirIndicadorCarga() {
    return Center(child: CirculoCargarPersonalizado());
  }

  // construye widget de vista vacia
  Widget construirVistaVacia() {
    return Center(
      child: Transform.translate(
        offset: Offset(0, -67),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.work,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              TextoEscalable(
                texto: 'Aún no has añadido ningún servicio',
                estilo: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextoEscalable(
                texto: 'Pulsa el botón + para ofrecer un nuevo servicio',
                estilo: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                alineacion: TextAlign.center,
              ),
              if (_mensajeError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _mensajeError!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // construye lista de servicios con pull to refresh
  Widget construirListaServicios(BuildContext context, Function cargarServicios, Function navegarACrearServicio, Function navegarADetalles) {
    return RefreshIndicator(
      onRefresh: () => cargarServicios(),
      color: const Color(0xFF616281),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        child: ListView.builder(
          itemCount: _serviciosOfrecidos.length,
          itemBuilder: (context, index) {
            final servicio = _serviciosOfrecidos[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ServiciosWidgets.construirTarjetaServicio(
                context,
                servicio,
                onTap: () => navegarADetalles(servicio.id),
              ),
            );
          },
        ),
      ),
    );
  }

  // construye boton flotante para crear servicios
  Widget construirBotonFlotante(Function navegarACrearServicio) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () => navegarACrearServicio(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF616281),
        elevation: 6,
      ),
    );
  }

  // inicia actualizacion automatica cada 30 segundos
  void iniciarAutoRefresh(Function() cargarDatos) {
    cancelarAutoRefresh();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_estaCargando) {
        cargarDatos();
      }
    });
  }

  // cancela la actualizacion automatica
  void cancelarAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // libera recursos cuando se destruye el widget
  void dispose() {
    cancelarAutoRefresh();
  }
}