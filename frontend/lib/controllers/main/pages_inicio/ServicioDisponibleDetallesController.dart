import '../../../../models/ServicioDisponible.dart';
import '../../../../models/HorarioServicio.dart';
import '../../../../services/ServicioDisponibleService.dart';
import '../../../../services/ApiService.dart';
import '../../../../services/UsuarioService.dart';

// controller basico para hacer reservas
class ServicioDisponibleDetallesController {
  // estado del controller
  bool _estaCargando = true;
  ServicioDisponible? _servicio;
  String? _mensajeError;

  // getters para acceder al estado
  bool get estaCargando => _estaCargando;
  ServicioDisponible? get servicio => _servicio;
  String? get mensajeError => _mensajeError;

  // servicios
  final ServicioDisponibleService _servicioDisponibleService = ServicioDisponibleService();
  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();

  Function()? _onStateChanged;

  // inicializar controller
  void init(Function() onStateChanged, {ServicioDisponible? servicio}) {
    _onStateChanged = onStateChanged;

    if (servicio != null) {
      _servicio = servicio;
      _estaCargando = false;
    }
  }

  // cargar detalles del servicio
  Future<void> cargarServicioDetalles(int servicioId) async {
    _actualizarEstado(estaCargando: true, mensajeError: null);

    final servicio = await _servicioDisponibleService.obtenerServicioDisponiblePorId(servicioId);

    if (servicio == null) {
      _actualizarEstado(estaCargando: false, mensajeError: 'No se pudo encontrar el servicio solicitado');
      return;
    }

    _actualizarEstado(estaCargando: false, servicio: servicio);
  }

  // realizar reserva
  Future<bool> contratarServicio({
    required DateTime fechaSeleccionada,
    required String horaSeleccionada,
    String? observaciones,
  }) async {
    if (_servicio == null) return false;

    final usuario = await _usuarioService.obtenerUsuarioActual();

    final clienteId = int.parse(usuario!.id!);
    final datosReserva = _prepararDatosReserva(
      fechaSeleccionada: fechaSeleccionada,
      horaSeleccionada: horaSeleccionada,
      observaciones: observaciones,
    );

    final respuesta = await _apiService.post('servicios-contratados?clienteId=$clienteId', datosReserva);
    return respuesta != null;
  }

  // preparar datos de reserva
  Map<String, dynamic> _prepararDatosReserva({
    required DateTime fechaSeleccionada,
    required String horaSeleccionada,
    String? observaciones,
  }) {
    final horaInicioParts = horaSeleccionada.split(':');
    final horaInicioInt = int.parse(horaInicioParts[0]);
    final minutoInicio = int.parse(horaInicioParts[1]);

    final horaFin = '${(horaInicioInt + 1).toString().padLeft(2, '0')}:${minutoInicio.toString().padLeft(2, '0')}';

    final diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    final diaSemana = diasSemana[fechaSeleccionada.weekday - 1];

    final horarioSeleccionado = {
      'fecha': '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}',
      'dia_semana': diaSemana,
      'hora_inicio': horaSeleccionada,
      'hora_fin': horaFin,
      'duracion_estimada_minutos': 60,
    };

    final datos = {
      'servicio_disponible_id': _servicio!.id,
      'horario_seleccionado': horarioSeleccionado,
    };

    if (observaciones?.trim().isNotEmpty ?? false) {
      datos['observaciones'] = observaciones!.trim();
    }

    return datos;
  }

  // obtener horarios disponibles para una fecha
  List<String> obtenerHorariosDisponiblesPorFecha({
    required HorarioServicio horarioServicio,
    required DateTime fechaSeleccionada,
  }) {
    try {
      final diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
      final diaSemana = diasSemana[fechaSeleccionada.weekday - 1];

      final fechaString = '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}';

      ExcepcionHorario? excepcion;
      try {
        excepcion = horarioServicio.excepciones.firstWhere((e) => e.fecha == fechaString);
      } catch (e) {
        excepcion = null;
      }

      List<RangoHorario> rangosHorarios = [];

      if (excepcion != null) {
        if (excepcion.disponible && excepcion.inicio != null && excepcion.fin != null) {
          rangosHorarios.add(RangoHorario(inicio: excepcion.inicio!, fin: excepcion.fin!));
        }
      } else {
        rangosHorarios = horarioServicio.horarioRegular[diaSemana] ?? [];
      }

      List<String> horariosDisponibles = [];
      for (var rango in rangosHorarios) {
        final horariosRango = _generarSlotsHorarios(rango: rango, fechaSeleccionada: fechaSeleccionada);
        horariosDisponibles.addAll(horariosRango);
      }

      horariosDisponibles.sort();
      return horariosDisponibles;
    } catch (e) {
      return [];
    }
  }

  // generar slots de tiempo
  List<String> _generarSlotsHorarios({
    required RangoHorario rango,
    required DateTime fechaSeleccionada,
  }) {
    List<String> horarios = [];

    try {
      final horaInicioParts = rango.inicio.split(':');
      final horaFinParts = rango.fin.split(':');

      DateTime fechaHoraInicio = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        int.parse(horaInicioParts[0]),
        int.parse(horaInicioParts[1]),
      );

      DateTime fechaHoraFin = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        int.parse(horaFinParts[0]),
        int.parse(horaFinParts[1]),
      );

      while (fechaHoraInicio.add(Duration(hours: 1)).isBefore(fechaHoraFin) || fechaHoraInicio.add(Duration(hours: 1)).isAtSameMomentAs(fechaHoraFin)) {
        bool esMismaFecha = fechaSeleccionada.day == DateTime.now().day &&
            fechaSeleccionada.month == DateTime.now().month &&
            fechaSeleccionada.year == DateTime.now().year;

        if (!esMismaFecha || fechaHoraInicio.isAfter(DateTime.now().add(Duration(minutes: 30)))) {
          horarios.add('${fechaHoraInicio.hour.toString().padLeft(2, '0')}:${fechaHoraInicio.minute.toString().padLeft(2, '0')}');
        }

        fechaHoraInicio = fechaHoraInicio.add(Duration(hours: 1));
      }
    } catch (e) {
      // error generando slots
    }

    return horarios;
  }

  // actualizar estado
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

  // metodos auxiliares
  String obtenerDescripcionCompleta() {
    if (_servicio?.descripcionCompleta?.isNotEmpty ?? false) {
      return _servicio!.descripcionCompleta!;
    }
    return 'Sin descripcion disponible.';
  }

  String? obtenerObservaciones() => _servicio?.observaciones;

  bool tieneObservaciones() => _servicio?.observaciones?.isNotEmpty ?? false;

  bool estaDisponibleParaReserva() => _servicio != null && _servicio!.precioHora > 0;

  String obtenerInfoProveedor() {
    if (_servicio == null) return '';
    return '${_servicio!.nombreTrabajador} - ${_servicio!.valoracionPromedio.toStringAsFixed(1)}⭐ (${_servicio!.totalValoraciones} valoraciones)';
  }

  void dispose() {
    _onStateChanged = null;
  }
}