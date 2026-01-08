import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../models/ServicioDisponible.dart';
import '../../../../../models/HorarioServicio.dart';
import '../../../../../services/ServicioDisponibleService.dart';
import '../../../../../services/ImagenService.dart';
import '../../../../../services/UsuarioService.dart';
import '../../../../../utils/Validadores.dart';
import '../../../../../utils/Dialogos.dart';
import '../../../../../widgets/Componentes_reutilizables.dart';
import '../ServiciosOfrecidosController.dart';

// controla la logica de creacion y edicion de servicios ofrecidos
class CrearServicioOfrecidoController {
  // estado del controlador
  bool _estaCargando = false;
  bool _esEdicion = false;
  ServicioDisponible? _servicioOriginal;

  // datos del formulario
  int? _servicioSeleccionadoId;
  String? _servicioSeleccionadoNombre;
  List<Map<String, dynamic>> _servicios = [];
  List<File> _imagenesNuevas = [];
  List<String> _imagenesExistentes = [];
  HorarioServicio _horarioServicio = HorarioServicio.empty();

  // acceso al estado actual
  bool get estaCargando => _estaCargando;
  bool get esEdicion => _esEdicion;
  ServicioDisponible? get servicioOriginal => _servicioOriginal;
  int? get servicioSeleccionadoId => _servicioSeleccionadoId;
  String? get servicioSeleccionadoNombre => _servicioSeleccionadoNombre;
  List<Map<String, dynamic>> get servicios => _servicios;
  List<File> get imagenesNuevas => _imagenesNuevas;
  List<String> get imagenesExistentes => _imagenesExistentes;
  HorarioServicio get horarioServicio => _horarioServicio;

  // servicios necesarios
  final _servicioDisponibleService = ServicioDisponibleService();
  final _controller = ServiciosOfrecidosController();
  final _imagenService = ImagenService();
  final _usuarioService = UsuarioService();

  Function()? _onStateChanged;

  // inicializa el controlador con callback
  void init(Function() onStateChanged, int? servicioId) {
    _onStateChanged = onStateChanged;
    _esEdicion = servicioId != null;
  }

  // carga datos iniciales del formulario
  Future<void> cargarDatos(int? servicioId) async {
    _actualizarEstado(estaCargando: true);

    try {
      // carga la lista de tipos de servicios disponibles
      final tiposServicios = await _controller.obtenerTiposServicios();
      _servicios = tiposServicios;

      // si es edicion carga los datos del servicio existente
      if (_esEdicion && servicioId != null) {
        await _cargarDatosEdicion(servicioId);
      }

      _actualizarEstado(estaCargando: false);
    } catch (e) {
      _actualizarEstado(estaCargando: false);
      rethrow;
    }
  }

  // carga datos especificos para edicion
  Future<void> _cargarDatosEdicion(int servicioId) async {
    // obtiene datos basicos del servicio
    final servicio = await _servicioDisponibleService.obtenerServicioDisponiblePorId(servicioId);

    if (servicio != null) {
      _servicioOriginal = servicio;
      _servicioSeleccionadoId = servicio.servicioId;
      _servicioSeleccionadoNombre = servicio.nombreServicio;

      // carga las imagenes existentes
      try {
        final imagenes = await _imagenService.obtenerImagenesServicioDisponible(servicioId);
        _imagenesExistentes = imagenes;
      } catch (e) {
        // error silencioso para imagenes
      }

      // carga el horario del servicio
      try {
        final horario = await _servicioDisponibleService.obtenerHorarioServicio(servicioId);
        if (horario != null) {
          _horarioServicio = horario;
        }
      } catch (e) {
        // error silencioso para horario
      }
    } else {
      throw Exception('No se pudo cargar el servicio para editar');
    }
  }

  // selecciona tipo de servicio del dropdown
  void seleccionarTipoServicio(int? servicioId) {
    _servicioSeleccionadoId = servicioId;
    if (servicioId != null) {
      final servicio = _servicios.firstWhere(
            (s) => s['id'] == servicioId,
        orElse: () => {'id': 0, 'nombre': '', 'descripcion': ''},
      );
      _servicioSeleccionadoNombre = servicio['nombre'];
    }
    _onStateChanged?.call();
  }

  // muestra opciones para seleccionar imagenes
  Future<void> mostrarOpcionesImagen(BuildContext context) async {
    Componentes_reutilizables.mostrarMenuOpcionesImagen(
      context: context,
      onGaleria: () async => await _seleccionarImagenesGaleria(),
      onCamara: () async => await _tomarFoto(),
    );
  }

  // selecciona multiples imagenes de la galeria
  Future<void> _seleccionarImagenesGaleria() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      for (var pickedFile in pickedFiles) {
        _imagenesNuevas.add(File(pickedFile.path));
      }
      _onStateChanged?.call();
    }
  }

  // toma foto con la camara
  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _imagenesNuevas.add(File(pickedFile.path));
      _onStateChanged?.call();
    }
  }

  // elimina imagen existente de la lista
  void eliminarImagenExistente(int index) {
    _imagenesExistentes.removeAt(index);
    _onStateChanged?.call();
  }

  // elimina imagen nueva de la lista
  void eliminarImagenNueva(int index) {
    _imagenesNuevas.removeAt(index);
    _onStateChanged?.call();
  }

  // actualiza horario del servicio
  void actualizarHorario(HorarioServicio nuevoHorario) {
    _horarioServicio = nuevoHorario;
    _onStateChanged?.call();
  }

  // sube nuevas imagenes al servidor
  Future<List<String>> _subirImagenesNuevas(int servicioId) async {
    List<String> urlsImagenes = [];

    if (_imagenesNuevas.isEmpty) {
      return urlsImagenes;
    }

    try {
      for (var imagen in _imagenesNuevas) {
        final subidaExitosa = await _imagenService.subirImagenServicioDisponible(imagen, servicioId);
        if (!subidaExitosa) {
          // continua con la siguiente imagen
        }
      }

      // refresca la lista de imagenes para obtener las urls
      return await _imagenService.obtenerImagenesServicioDisponible(servicioId);
    } catch (e) {
      throw Exception('Error al subir imágenes: $e');
    }
  }

  // valida todos los datos del formulario
  Future<bool> validarDatosServicio(
      BuildContext context,
      String descripcion,
      String observaciones,
      String precio,
      ) async {
    // valida tipo de servicio
    if (!Validadores.validarTipoServicio(_servicioSeleccionadoId)) {
      Dialogos.mostrarDialogoError(context, 'Selecciona un tipo de servicio');
      return false;
    }

    // valida descripcion
    if (!Validadores.validarDescripcionServicio(descripcion)) {
      Dialogos.mostrarDialogoError(context, 'La descripcion debe tener al menos 10 caracteres');
      return false;
    }

    // valida observaciones
    if (!Validadores.validarObservaciones(observaciones)) {
      Dialogos.mostrarDialogoError(context, 'Las observaciones son demasiado largas');
      return false;
    }

    // valida precio
    if (!Validadores.validarPrecio(precio)) {
      Dialogos.mostrarDialogoError(context, 'Ingresa un precio valido');
      return false;
    }

    // valida que hay al menos un horario configurado
    if (!_validarHorarioMinimo()) {
      Dialogos.mostrarDialogoError(context, 'Debes configurar al menos un horario de disponibilidad para el servicio');
      return false;
    }

    return true;
  }

  // valida que hay al menos un horario configurado
  bool _validarHorarioMinimo() {
    final List<String> diasSemana = [
      'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'
    ];

    for (String dia in diasSemana) {
      if (_horarioServicio.horarioRegular[dia]!.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // valida horario contra solapamientos usando el endpoint
  Future<bool> _validarHorarioSinSolapamiento(int trabajadorId, int? servicioIdExcluir) async {
    try {
      final validacion = await _servicioDisponibleService.validarHorarioSinGuardar(
        trabajadorId: trabajadorId,
        horario: _horarioServicio,
        servicioIdExcluir: servicioIdExcluir,
      );

      return validacion['valido'] ?? false;
    } catch (e) {
      return true; // en caso de error permitir continuar
    }
  }

  // guarda servicio creando o editando con validacion previa de horario
  Future<bool> guardarServicio({
    required BuildContext context,
    required String descripcion,
    required String observaciones,
    required String precio,
  }) async {
    // valida todos los datos primero
    if (!await validarDatosServicio(context, descripcion, observaciones, precio)) {
      return false;
    }

    _actualizarEstado(estaCargando: true);

    try {
      // obtiene id del usuario actual
      final idTrabajador = await _usuarioService.obtenerIdNumericoUsuario();
      if (idTrabajador == null) {
        Dialogos.mostrarDialogoError(context, 'No se pudo obtener el ID del trabajador');
        return false;
      }

      // valida horario antes de crear o actualizar el servicio
      final horarioValido = await _validarHorarioSinSolapamiento(
          idTrabajador,
          _esEdicion ? _servicioOriginal?.id : null
      );

      if (!horarioValido) {
        Dialogos.mostrarDialogoError(
            context,
            'El horario se solapa con otros servicios. Por favor, ajusta los horarios.'
        );
        return false;
      }

      final precioHora = double.parse(precio);

      // mapeo de datos segun el backend
      final Map<String, dynamic> datosServicio = {
        'trabajador_id': idTrabajador,
        'servicio_id': _servicioSeleccionadoId,
        'descripcion': descripcion,
        'observaciones': observaciones,
        'precio_hora': precioHora,
      };

      int servicioId;

      if (_esEdicion && _servicioOriginal != null) {
        // edicion actualiza servicio existente
        final servicioActualizado = await _servicioDisponibleService.actualizarServicioDisponible(
          _servicioOriginal!.id,
          datosServicio,
        );

        if (servicioActualizado == null) {
          Dialogos.mostrarDialogoError(context, 'Error al actualizar el servicio');
          return false;
        }

        servicioId = _servicioOriginal!.id;
      } else {
        // creacion anade nuevo servicio
        final nuevoServicio = await _servicioDisponibleService.crearServicioDisponible(datosServicio);

        if (nuevoServicio == null) {
          Dialogos.mostrarDialogoError(context, 'Error al crear el servicio');
          return false;
        }

        servicioId = nuevoServicio.id;
      }

      // guarda horario ya validado previamente
      final resultadoHorario = await _servicioDisponibleService.guardarHorarioServicio(servicioId, _horarioServicio);

      if (!resultadoHorario['exito']) {
        Dialogos.mostrarDialogoError(context, resultadoHorario['mensaje']);
        return false;
      }

      // sube nuevas imagenes si las hay
      if (_imagenesNuevas.isNotEmpty) {
        try {
          await _subirImagenesNuevas(servicioId);
        } catch (e) {
          // no hace rollback por imagenes el servicio ya esta creado
        }
      }

      return true;
    } catch (e) {
      Dialogos.mostrarDialogoError(context, 'Error al guardar servicio: ${e.toString()}');
      return false;
    } finally {
      _actualizarEstado(estaCargando: false);
    }
  }

  // actualiza el estado y notifica cambios
  void _actualizarEstado({bool? estaCargando}) {
    if (estaCargando != null) _estaCargando = estaCargando;
    _onStateChanged?.call();
  }

  // libera recursos del controlador
  void dispose() {
    _onStateChanged = null;
  }
}