import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/Usuario.dart';
import '../../../services/ImagenService.dart';
import '../../../services/UsuarioService.dart';
import '../../../services/ApiService.dart';
import '../../../utils/Dialogos.dart';
import '../../../utils/Validadores.dart';

// controla la logica de edicion del perfil de usuario
class EditarPerfilController {
  final UsuarioService _usuarioService = UsuarioService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagenService _imagenService = ImagenService();
  String? _urlImagenPerfilActual;

  String? get urlImagenPerfilActual => _urlImagenPerfilActual;

  // carga los datos del usuario actual en los controladores
  Future<bool> cargarDatosUsuario(
      TextEditingController dniControlador,
      TextEditingController nombreControlador,
      TextEditingController apellido1Controlador,
      TextEditingController apellido2Controlador,
      TextEditingController correoControlador,
      TextEditingController telefonoControlador,
      TextEditingController fechaNacimientoControlador,
      ) async {
    try {
      Usuario? usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario == null) return false;

      // llena los controladores con los datos del usuario
      dniControlador.text = usuario.dni ?? '';
      nombreControlador.text = usuario.nombre ?? '';
      apellido1Controlador.text = usuario.apellido1 ?? '';
      apellido2Controlador.text = usuario.apellido2 ?? '';
      correoControlador.text = usuario.correo ?? '';
      telefonoControlador.text = usuario.telefono ?? '';

      // formatea la fecha para mostrarla correctamente
      if (usuario.fechaNacimiento != null && usuario.fechaNacimiento!.isNotEmpty) {
        DateTime fecha = DateTime.parse(usuario.fechaNacimiento!);
        fechaNacimientoControlador.text = "${fecha.day}/${fecha.month}/${fecha.year}";
      }

      // obtiene la url de la imagen de perfil actual
      _urlImagenPerfilActual = await _imagenService.obtenerUrlImagenPerfil();

      return true;
    } catch (e) {
      return false;
    }
  }

  // actualiza los datos del perfil en el servidor
  Future<void> actualizarPerfil(
      BuildContext context,
      String dni,
      String nombre,
      String apellido1,
      String apellido2,
      String telefono,
      String fechaNacimiento,
      ) async {
    try {
      // valida los datos antes de enviarlos
      if (!await validarDatos(context, dni, nombre, apellido1, apellido2, telefono, fechaNacimiento)) {
        return;
      }

      Usuario? usuarioExistente = await _usuarioService.obtenerUsuarioActual();
      if (usuarioExistente == null) {
        Dialogos.mostrarDialogoError(context, 'No se pudieron cargar los datos del usuario.');
        return;
      }

      // verifica que el dni no este en uso por otro usuario
      if (dni.isNotEmpty && dni != usuarioExistente.dni) {
        if (await _verificarDniExistente(context, dni, usuarioExistente)) {
          return;
        }
      }

      // verifica que el telefono no este en uso por otro usuario
      if (telefono.isNotEmpty && telefono != usuarioExistente.telefono) {
        if (await _verificarTelefonoExistente(context, telefono)) {
          return;
        }
      }

      // muestra indicador de carga durante la actualizacion
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CirculoCargarPersonalizado(),
      );

      // obtiene token de firebase para autenticacion
      User? usuarioFirebase = _auth.currentUser;
      if (usuarioFirebase == null) {
        Navigator.pop(context);
        Dialogos.mostrarDialogoError(context, 'No hay sesión activa. Inicie sesión nuevamente.');
        return;
      }

      String? token = await usuarioFirebase.getIdToken();
      if (token == null) {
        Navigator.pop(context);
        Dialogos.mostrarDialogoError(context, 'No se pudo obtener el token de autenticación.');
        return;
      }

      // prepara los datos actualizados del usuario
      int? idNumerico = int.tryParse(usuarioExistente.id ?? '');
      if (idNumerico == null) {
        Navigator.pop(context);
        Dialogos.mostrarDialogoError(context, 'El ID del usuario no es válido.');
        return;
      }

      String firebaseUid = usuarioExistente.firebaseUid ?? usuarioFirebase.uid;

      // crea objeto con los datos actualizados
      Usuario usuarioActualizado = usuarioExistente.copyWith(
        firebaseUid: firebaseUid,
        nombre: nombre.trim(),
        apellido1: apellido1.trim(),
        apellido2: apellido2.trim().isEmpty ? null : apellido2.trim(),
        dni: dni.trim().isEmpty ? null : dni.trim(),
        fechaNacimiento: fechaNacimiento.isEmpty
            ? usuarioExistente.fechaNacimiento
            : Validadores.formatearFecha(fechaNacimiento),
        telefono: telefono.trim().isEmpty ? null : telefono.trim(),
      );

      // envia los datos al servidor
      Map<String, dynamic> datosUsuario = usuarioActualizado.toJson();
      if (!datosUsuario.containsKey('firebaseUid') && firebaseUid.isNotEmpty) {
        datosUsuario['firebaseUid'] = firebaseUid;
      }

      final respuesta = await _apiService.put('usuarios/$idNumerico', datosUsuario);
      Navigator.pop(context);

      // procesa la respuesta del servidor
      bool exitoso = _procesarRespuestaActualizacion(respuesta);
      String mensaje = _obtenerMensajeRespuesta(respuesta, exitoso);

      if (exitoso) {
        await _usuarioService.actualizarUsuarioActual(usuarioActualizado);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        Dialogos.mostrarDialogoError(context, mensaje);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String mensaje = 'Error al actualizar perfil';

      Dialogos.mostrarDialogoError(context, mensaje);
    }
  }

  // verifica si el dni ya esta registrado por otro usuario
  Future<bool> _verificarDniExistente(BuildContext context, String dni, Usuario usuarioExistente) async {
    String firebaseUid = usuarioExistente.firebaseUid ?? _auth.currentUser?.uid ?? '';
    if (firebaseUid.isEmpty) {
      Dialogos.mostrarDialogoError(context, 'No se pudo obtener el UID del usuario.');
      return true;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CirculoCargarPersonalizado(),
    );

    final existeDniRespuesta = await _apiService.get(
      'usuarios/existe-dni/$dni?firebaseUidActual=$firebaseUid',
    );

    Navigator.pop(context);

    if (existeDniRespuesta == true) {
      Dialogos.mostrarDialogoError(context, 'El DNI establecido ya esta registrado.');
      return true;
    }

    return false;
  }

  // verifica si el telefono ya esta registrado por otro usuario
  Future<bool> _verificarTelefonoExistente(BuildContext context, String telefono) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CirculoCargarPersonalizado(),
    );

    final existeTelefonoRespuesta = await _apiService.get(
      'usuarios/existe-telefono/$telefono',
    );

    Navigator.pop(context);

    if (existeTelefonoRespuesta == true) {
      Dialogos.mostrarDialogoError(context, 'El teléfono establecido ya está registrado.');
      return true;
    }

    return false;
  }

  // procesa la respuesta del servidor para determinar si fue exitosa
  bool _procesarRespuestaActualizacion(dynamic respuesta) {
    if (respuesta is Map<String, dynamic>) {
      if (respuesta.containsKey('success')) {
        return respuesta['success'] == true;
      }
      return true;
    }
    return true;
  }

  // obtiene el mensaje apropiado segun la respuesta
  String _obtenerMensajeRespuesta(dynamic respuesta, bool exitoso) {
    if (respuesta is Map<String, dynamic>) {
      if (respuesta.containsKey('message')) {
        return respuesta['message'] ?? (exitoso ? 'Perfil actualizado correctamente' : 'Error al actualizar perfil');
      }
    }
    return exitoso ? 'Perfil actualizado correctamente' : 'Error al actualizar perfil';
  }

  // valida los datos del formulario antes de enviarlos
  Future<bool> validarDatos(
      BuildContext context,
      String dni,
      String nombre,
      String apellido1,
      String apellido2,
      String telefono,
      String fechaNacimiento,
      ) async {
    // verifica que los campos obligatorios no esten vacios
    if (nombre.isEmpty || apellido1.isEmpty) {
      Dialogos.mostrarDialogoError(context, 'El nombre y primer apellido son obligatorios.');
      return false;
    }

    // valida formato del dni si se proporciona
    if (dni.isNotEmpty && !Validadores.validarDNI(dni.trim())) {
      Dialogos.mostrarDialogoError(context, 'El DNI debe tener 8 números seguidos de una letra válida.');
      return false;
    }

    // verifica que el usuario sea mayor de edad
    if (fechaNacimiento.isNotEmpty && !Validadores.validarMayorDeEdad(fechaNacimiento.trim())) {
      Dialogos.mostrarDialogoError(context, 'Debes ser mayor de 18 años para usar esta aplicación.');
      return false;
    }

    // valida formato del telefono movil
    if (telefono.isNotEmpty && !Validadores.validarTelefonoMovil(telefono.trim())) {
      Dialogos.mostrarDialogoError(context, 'El número de teléfono debe ser un móvil válido (9 dígitos empezando por 6 o 7).');
      return false;
    }

    return true;
  }

  // abre galeria para seleccionar imagen
  Future<File?> seleccionarImagenGaleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    return imagen != null ? File(imagen.path) : null;
  }

  // abre camara para tomar foto
  Future<File?> tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    return imagen != null ? File(imagen.path) : null;
  }

  // sube nueva imagen de perfil al servidor
  Future<bool> actualizarImagenPerfil(BuildContext context, File imagen) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CirculoCargarPersonalizado(),
    );

    final imagenPerfil = await _imagenService.subirImagenPerfil(imagen);
    Navigator.pop(context);

    if (imagenPerfil != null) {
      // limpia cache y recarga url desde el servidor
      _imagenService.limpiarCacheImagenPerfil();
      _urlImagenPerfilActual = await _imagenService.obtenerUrlImagenPerfil();
      return true;
    } else {
      Dialogos.mostrarDialogoError(context, 'Error al actualizar la imagen de perfil');
      return false;
    }
  }
}