import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/Usuario.dart';
import '../../services/ApiService.dart';
import '../../services/UsuarioService.dart';
import '../../utils/Dialogos.dart';
import '../../utils/Validadores.dart';
import '../../ui/auth/IniciarSesionExplicaciones.dart';
import '../../ui/main/PantallaHome.dart';
import '../../services/FCMService.dart';
import '../../widgets/Componentes_reutilizables.dart';

class InicioSesionController {
  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();

  // carga credenciales guardadas del almacenamiento
  Future<Map<String, dynamic>> cargarCredencialesGuardadas() async {
    return await _apiService.obtenerCredencialesGuardadas();
  }

  // aplica credenciales guardadas a los controladores
  Future<bool> aplicarCredencialesGuardadas(
      TextEditingController controladorCorreo,
      TextEditingController controladorContrasena
      ) async {
    final credenciales = await cargarCredencialesGuardadas();
    final bool recordarmeActivado = credenciales['recordarme'] == true;

    if (recordarmeActivado) {
      controladorCorreo.text = credenciales['nombreUsuario'] ?? '';
      controladorContrasena.text = credenciales['contrasena'] ?? '';
    }

    return recordarmeActivado;
  }

  // carga estado de recordarme
  Future<bool> cargarEstadoRecordarme() async {
    final credenciales = await cargarCredencialesGuardadas();
    return credenciales['recordarme'] ?? false;
  }

  // guarda estado de recordarme
  Future<void> guardarEstadoRecordarme(bool valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool('recordarme', valor);

    final almacenamientoSeguro = FlutterSecureStorage();

    if (!valor) {
      await almacenamientoSeguro.delete(key: 'nombreUsuario');
      await almacenamientoSeguro.delete(key: 'contrasena');
    }
  }

  // metodo principal de inicio de sesion
  Future<void> iniciarSesion(
      BuildContext contexto,
      String correo,
      String contrasena,
      bool recordarme
      ) async {
    // validaciones basicas
    if (correo.isEmpty || contrasena.isEmpty) {
      Dialogos.mostrarDialogoError(contexto, 'Por favor, complete todos los campos.');
      return;
    }

    correo = correo.trim();

    if (!Validadores.validarCorreo(correo)) {
      Dialogos.mostrarDialogoError(contexto, 'Por favor, ingrese un correo electronico valido.');
      return;
    }

    try {
      // muestra indicador de carga
      showDialog(
        context: contexto,
        barrierDismissible: false,
        builder: (BuildContext contexto) => CirculoCargarPersonalizado(),
      );

      // autenticacion con firebase
      UserCredential credencialesUsuario = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // guarda credenciales si recordarme esta activado
      if (recordarme) {
        await _apiService.guardarCredenciales(correo, contrasena, true);
      }

      // obtiene token del usuario
      String? ficha = await credencialesUsuario.user?.getIdToken(true);

      if (ficha == null) {
        Navigator.pop(contexto);
        Dialogos.mostrarDialogoError(contexto, 'Error de autenticacion.');
        return;
      }

      // guarda token
      await _apiService.guardarToken(ficha);

      // obtiene datos del usuario
      Usuario? usuario;
      try {
        final usuarioData = await _apiService.getConTokenEspecifico('auth/me', ficha);
        usuario = Usuario.fromJson(usuarioData);
        _usuarioService.establecerUsuarioActual(usuario);
        Navigator.pop(contexto);
      } catch (e) {
        Navigator.pop(contexto);
        Dialogos.mostrarDialogoError(contexto, 'Error obteniendo datos del usuario');
        return;
      }

      if (usuario != null) {
        try {
          await FCMService().inicializarFCM(int.parse(usuario.id!));
        } catch (e) {
          // error silencioso
        }

        // verifica si es el primer inicio de sesion
        if (!usuario.primerInicio) {
          Componentes_reutilizables.navegarConTransicion(
              contexto,
              const IniciarSesionExplicaciones(),
              reemplazar: true
          );
          await _usuarioService.actualizarPrimerInicio(usuario.id!);
        } else {
          Componentes_reutilizables.navegarConTransicion(
              contexto,
              const PantallaHome(),
              reemplazar: true
          );
        }
      } else {
        Dialogos.mostrarDialogoError(contexto, 'No se pudo obtener la informacion del usuario. Intentelo nuevamente.');
      }
    } catch (e) {
      // maneja errores durante la autenticacion
      if (Navigator.canPop(contexto)) {
        Navigator.pop(contexto);
      }

      if (e is FirebaseAuthException) {
        Dialogos.mostrarDialogoError(contexto, 'Credenciales incorrectas. Verifique su correo y contraseña.');
      } else {
        Dialogos.mostrarDialogoError(contexto, 'Error durante el inicio de sesion. Intente nuevamente mas tarde.');
      }
    }
  }
}