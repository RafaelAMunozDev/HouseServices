import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/ApiException.dart';
import '../../services/ApiService.dart';
import '../../utils/Dialogos.dart';
import '../../utils/Validadores.dart';
import '../../models/Usuario.dart';
import '../../ui/auth/CrearCuentaDireccion.dart';
import '../../widgets/Componentes_reutilizables.dart';

// maneja la logica de creacion de cuenta de usuario
class CrearCuentaController {
  final ApiService apiService = ApiService();

  // valida todos los datos del formulario de registro
  Future<bool> validarDatos(
      BuildContext context,
      String dni,
      String nombre,
      String apellido1,
      String apellido2,
      String correo,
      String contrasena,
      String confirmarContrasena,
      String telefono,
      String fechaNacimiento
      ) async {
    // comprueba que no haya campos obligatorios vacios
    if (nombre.isEmpty ||
        apellido1.isEmpty ||
        apellido2.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        confirmarContrasena.isEmpty ||
        telefono.isEmpty ||
        fechaNacimiento.isEmpty) {
      Dialogos.mostrarDialogoError(context, 'Por favor, completa los campos obligatorios.');
      return false;
    }

    // verifica formato del correo
    if (!Validadores.validarCorreo(correo.trim())) {
      Dialogos.mostrarDialogoError(context, 'Por favor, ingrese un correo electronico valido.');
      return false;
    }

    // comprueba que las contraseñas coincidan
    if (!Validadores.validarContrasenaCoinciden(contrasena, confirmarContrasena)) {
      Dialogos.mostrarDialogoError(context, 'Las contraseñas no coinciden.');
      return false;
    }

    // verifica longitud minima de contraseña
    if (!Validadores.validarContrasena(contrasena)) {
      Dialogos.mostrarDialogoError(context, 'La contraseña debe tener al menos 6 caracteres.');
      return false;
    }

    // valida formato del dni
    if (!Validadores.validarDNI(dni.trim())) {
      Dialogos.mostrarDialogoError(context, 'El DNI debe tener 8 numeros seguidos de una letra valida.');
      return false;
    }

    // comprueba mayoria de edad
    if (!Validadores.validarMayorDeEdad(fechaNacimiento.trim())) {
      Dialogos.mostrarDialogoError(context, 'Debes ser mayor de 18 años para registrarte.');
      return false;
    }

    // valida telefono movil español
    if (!Validadores.validarTelefonoMovil(telefono.trim())) {
      Dialogos.mostrarDialogoError(context, 'El numero de telefono debe ser un movil valido (9 digitos empezando por 6 o 7).');
      return false;
    }

    return true;
  }

  // gestiona el proceso completo de registro
  Future<void> registrarUsuario(
      BuildContext context,
      String dni,
      String nombre,
      String apellido1,
      String apellido2,
      String correo,
      String contrasena,
      String confirmarContrasena,
      String telefono,
      String fechaNacimiento
      ) async {
    try {
      // valida datos del formulario
      if (!await validarDatos(
          context,
          dni,
          nombre,
          apellido1,
          apellido2,
          correo,
          contrasena,
          confirmarContrasena,
          telefono,
          fechaNacimiento
      )) {
        return;
      }

      Map<String, dynamic> preRegister;

      try {
        preRegister = await apiService.post(
          'auth/pre-register',
          {
            'dni': dni.trim().isEmpty ? null : dni.trim(),
            'telefono': telefono.trim().isEmpty ? null : telefono.trim(),
          },
        );
      } catch (e) {
        if (e is ApiException) {
          Dialogos.mostrarDialogoError(context, e.message);
        } else {
          Dialogos.mostrarDialogoError(context, 'Error inesperado');
        }
        return;
      }

      // muestra indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CirculoCargarPersonalizado(),
      );

      // crea usuario en firebase
      UserCredential credencialesUsuario = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      await apiService.eliminarToken();

      // obtiene token de autenticacion
      String? token = await credencialesUsuario.user?.getIdToken(true);
      if (token == null) {
        Navigator.pop(context);
        Dialogos.mostrarDialogoError(context, 'No se pudo obtener el token de autenticacion.');
        await credencialesUsuario.user?.delete();
        return;
      }

      await apiService.guardarToken(token);

      try {
        // crea objeto usuario con datos del formulario
        Usuario usuario = Usuario(
          nombre: nombre.trim(),
          apellido1: apellido1.trim(),
          correo: correo.trim(),
          apellido2: apellido2.trim().isEmpty ? null : apellido2.trim(),
          dni: dni.trim().isEmpty ? null : dni.trim(),
          fechaNacimiento: fechaNacimiento.isEmpty
              ? null
              : Validadores.formatearFecha(fechaNacimiento),
          telefono: telefono.trim().isEmpty ? null : telefono.trim(),
        );

        // envia datos al backend
        Map<String, dynamic> datosUsuario = usuario.toJson(token: token);
        final respuesta = await apiService.post('auth/register', datosUsuario);

        Navigator.pop(context);

        // navega a pantalla de direccion si fue exitoso
        if (respuesta['success'] == true) {
          Componentes_reutilizables.navegarConTransicion(
              context,
              const CrearCuentaDireccion()
          );
        } else {
          Dialogos.mostrarDialogoError(context, respuesta['message'] ?? 'Error al registrar usuario');
        }
      } catch (errorBackend) {
        Navigator.pop(context);

        String mensaje = apiService.extraerMensajeError(errorBackend);

        // elimina usuario de firebase si hay conflicto de datos
        if (mensaje.contains('El DNI establecido ya esta registrado.') ||
            mensaje.contains('El telefono establecido ya esta registrado.')) {
          try {
            await credencialesUsuario.user?.delete();
          } catch (errorEliminar) {
            // error silencioso
          }
        }

        Dialogos.mostrarDialogoError(context, mensaje);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String mensaje = 'Error durante el registro.';
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          mensaje = 'Este correo electronico ya esta en uso.';
        }
      }

      Dialogos.mostrarDialogoError(context, mensaje);
    }
  }
}