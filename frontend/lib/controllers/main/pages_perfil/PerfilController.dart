import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/Usuario.dart';
import '../../../services/UsuarioService.dart';
import '../../../services/ApiService.dart';
import '../../../utils/Dialogos.dart';
import '../../../ui/auth/InicioSesion.dart';
import '../../../services/UsuarioRolService.dart';
import '../../../widgets/Componentes_reutilizables.dart';

class PerfilController {
  // servicios
  final UsuarioService _usuarioService = UsuarioService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsuarioRolService _rolService = UsuarioRolService();

  // variables para mantener el estado
  Usuario? _usuarioActual;
  String? _correoUsuario;
  String _nombreMostrar = 'Usuario';
  bool _estaCargando = false;
  String? _mensajeError;
  bool _esTrabajador = false;

  // getters para acceder al estado
  Usuario? get usuarioActual => _usuarioActual;
  bool get estaCargando => _estaCargando;
  String? get mensajeError => _mensajeError;
  String get nombreMostrar => _nombreMostrar;
  String get correoUsuario => _correoUsuario ?? 'usuario@example.com';
  bool get esTrabajador => _esTrabajador;

  // cargar datos del perfil
  Future<void> cargarDatosPerfil() async {
    try {
      _estaCargando = true;
      _mensajeError = null;

      await Future.wait([
        _cargarUsuario(),
        _cargarCorreo(),
        _cargarNombre(),
        _cargarRolTrabajador(),
      ]);

      _estaCargando = false;
    } catch (e) {
      _estaCargando = false;
      _mensajeError = 'Error al cargar el perfil';
    }
  }

  // metodos privados para cargar datos
  Future<void> _cargarUsuario() async {
    _usuarioActual = await _usuarioService.obtenerUsuarioActual();
  }

  Future<void> _cargarCorreo() async {
    _correoUsuario = await _usuarioService.obtenerCorreoUsuario();
  }

  Future<void> _cargarNombre() async {
    _nombreMostrar = await _usuarioService.obtenerNombreParaMostrar();
  }

  Future<void> _cargarRolTrabajador() async {
    if (_usuarioActual == null) await _cargarUsuario();
    if (_usuarioActual?.id != null) {
      _esTrabajador = await _rolService.verificarRolTrabajador(_usuarioActual?.id);
    }
  }

  // verifica si hay datos cargados
  bool hayDatosCargados() {
    return _usuarioActual != null;
  }

  // cerrar sesion
  Future<void> cerrarSesion(BuildContext context) async {
    bool confirmarCerrarSesion = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Cerrar sesion',
      mensaje: '¿Estas seguro de que deseas cerrar sesion?',
      textoAceptar: 'Cerrar sesion',
      textoCancelar: 'Cancelar',
    );

    if (confirmarCerrarSesion) {
        Dialogos.mostrarDialogoCarga(context);

        await _rolService.limpiarCacheRoles();
        await _apiService.eliminarToken();
        await _auth.signOut();
        _usuarioService.limpiarUsuarioActual();

        Navigator.pop(context);
        Componentes_reutilizables.navegarConTransicion(context, InicioSesion(), reemplazar: true);
    }
  }

  // eliminar cuenta
  Future<void> eliminarCuenta(BuildContext context) async {
    bool confirmarEliminar = await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar cuenta',
      mensaje: '¿Estas seguro de que deseas eliminar tu cuenta? Esta accion no se puede deshacer.',
      textoAceptar: 'Eliminar',
      textoCancelar: 'Cancelar',
      colorBotonAceptar: Colors.red,
    );

    if (confirmarEliminar) {
      Map<String, dynamic> resultadoContrasena = await Dialogos.mostrarDialogoSolicitarContrasena(
        context: context,
        titulo: 'Confirmar con contrasena',
        mensaje: 'Por seguridad, introduce tu contrasena para confirmar la eliminacion.',
      );

      bool confirmarContrasena = resultadoContrasena['confirmado'];
      String contrasena = resultadoContrasena['contrasena'];

      if (confirmarContrasena && contrasena.isNotEmpty) {
          Dialogos.mostrarDialogoCarga(context);

          User? usuarioFirebase = _auth.currentUser;
          if (usuarioFirebase == null) {
            Navigator.pop(context);
            Dialogos.mostrarDialogoError(context, 'No hay sesion activa. Inicia sesion nuevamente.');
            return;
          }

          try {
            AuthCredential credencial = EmailAuthProvider.credential(
              email: usuarioFirebase.email ?? '',
              password: contrasena,
            );
            await usuarioFirebase.reauthenticateWithCredential(credencial);
          } catch (e) {
            Navigator.pop(context);
            Dialogos.mostrarDialogoError(context, 'Contrasena incorrecta. Intenta nuevamente.');
            return;
          }

          await _usuarioService.eliminarCuenta();
          await usuarioFirebase.delete();
          await _apiService.eliminarToken();
          _usuarioService.limpiarUsuarioActual();

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tu cuenta ha sido eliminada correctamente.'), backgroundColor: Colors.green),
          );

          Componentes_reutilizables.navegarConTransicion(context, InicioSesion(), reemplazar: true);
      } else if (confirmarContrasena) {
        Dialogos.mostrarDialogoError(context, 'Ingresa tu contrasena para confirmar.');
      }
    }
  }

  // comprobar y solicitar rol de trabajador
  Future<bool> comprobarYSolicitarRolTrabajador(BuildContext context) async {
    if (_usuarioActual == null) await _cargarUsuario();

    if (_esTrabajador) return true;

    if (_usuarioActual?.id != null) {
      _esTrabajador = await _rolService.verificarRolTrabajador(_usuarioActual?.id);
      if (_esTrabajador) return true;
    } else {
      Dialogos.mostrarDialogoError(context, 'No se pudo identificar tu cuenta. Inicia sesion nuevamente.');
      return false;
    }

    bool quiereSerTrabajador = await Dialogos.mostrarDialogoSolicitarRolTrabajador(context: context);

    if (quiereSerTrabajador) {
      Dialogos.mostrarDialogoCarga(context);
      bool asignacionExitosa = await _rolService.asignarRolTrabajador(_usuarioActual?.id);
      Navigator.pop(context);

      if (asignacionExitosa) {
        _esTrabajador = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Ahora eres un trabajador! Puedes ofrecer servicios.'), backgroundColor: Colors.green),
        );
        return true;
      } else {
        Dialogos.mostrarDialogoError(context, 'No se pudo asignar el rol de trabajador.');
        return false;
      }
    }

    return false;
  }
}