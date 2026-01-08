import '../models/Usuario.dart';
import 'ApiService.dart';
import 'package:firebase_auth/firebase_auth.dart';

// servicio para gestionar informacion de usuario
class UsuarioService {
  static final UsuarioService _instancia = UsuarioService._interno();
  factory UsuarioService() => _instancia;
  UsuarioService._interno();

  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // usuario actualmente autenticado
  Usuario? _usuarioActual;

  // establece el usuario actual despues del registro o login
  void establecerUsuarioActual(Usuario usuario) {
    _usuarioActual = usuario;
  }

  // obtiene el usuario actual desde memoria o backend
  Future<Usuario?> obtenerUsuarioActual() async {
    // si ya tenemos el usuario en memoria lo devuelve
    if (_usuarioActual != null) {
      return _usuarioActual;
    }

    try {
      // intenta renovar el token primero
      bool tokenRenovado = await _apiService.renovarToken();

      // si no se pudo renovar intenta usar el token guardado
      if (!tokenRenovado) {
        final token = await _apiService.obtenerTokenGuardado();
        if (token == null) {
          return null;
        }
      }

      // obtiene perfil de usuario desde backend con token renovado
      final respuesta = await _apiService.get('auth/me');

      // backend devuelve directamente el usuario
      if (respuesta != null) {
        _usuarioActual = Usuario.fromJson(respuesta);
        return _usuarioActual;
      }

      return null;
    } catch (e) {
      // si el error es de token expirado intenta renovarlo una vez
      if (e.toString().contains('token has expired')) {
        try {
          bool renovado = await _apiService.renovarToken();
          if (renovado) {
            final respuesta = await _apiService.get('auth/me');
            if (respuesta != null) {
              _usuarioActual = Usuario.fromJson(respuesta);
              return _usuarioActual;
            }
          }
        } catch (e2) {
          // error silencioso
        }
      }

      return null;
    }
  }

  // obtiene el correo electronico del usuario actual
  Future<String?> obtenerCorreoUsuario() async {
    try {
      // primero intenta obtener el correo de firebase auth
      User? usuarioFirebase = _auth.currentUser;
      if (usuarioFirebase != null && usuarioFirebase.email != null) {
        return usuarioFirebase.email;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // obtiene el nombre de usuario para mostrar
  Future<String> obtenerNombreParaMostrar() async {
    try {
      // primero intenta obtener el usuario actual con todos sus datos
      final usuario = await obtenerUsuarioActual();

      // si tiene el usuario con nombre lo devuelve formateado
      if (usuario != null) {
        return usuario.nombreCompleto;
      }

      // si no tiene el usuario pero si hay usuario en firebase
      User? usuarioFirebase = _auth.currentUser;
      if (usuarioFirebase != null) {
        // intenta usar el displayname de firebase si esta disponible
        if (usuarioFirebase.displayName != null && usuarioFirebase.displayName!.isNotEmpty) {
          return usuarioFirebase.displayName!;
        }

        // si no hay displayname usa el email hasta el arroba
        if (usuarioFirebase.email != null) {
          return usuarioFirebase.email!.split('@')[0];
        }
      }

      // si todo falla devuelve valor predeterminado
      return 'Usuario';
    } catch (e) {
      return 'Usuario';
    }
  }

  // obtiene el id numerico del usuario actual
  Future<int?> obtenerIdNumericoUsuario() async {
    // intenta obtener el usuario actual con todos sus datos
    final usuario = await obtenerUsuarioActual();

    // si lo obtuvo extrae el id numerico
    if (usuario != null && usuario.id != null) {
      try {
        // convierte el id a entero
        return int.parse(usuario.id!);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // obtiene el firebase uid del usuario
  Future<String?> obtenerFirebaseUid() async {
    try {
      // primero intenta obtener el usuario desde memoria o backend
      final usuario = await obtenerUsuarioActual();
      if (usuario != null && usuario.firebaseUid != null) {
        return usuario.firebaseUid;
      }

      // si no funciona intenta obtener el uid de firebase directamente
      final usuarioFirebase = _auth.currentUser;
      if (usuarioFirebase != null) {
        return usuarioFirebase.uid;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // limpia usuario actual de memoria
  void limpiarUsuarioActual() {
    _usuarioActual = null;
  }

  // elimina cuenta del usuario
  Future<bool> eliminarCuenta() async {
    try {
      final idUsuario = await obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return false;
      }

      // hace peticion para eliminar la cuenta
      await _apiService.delete('usuarios/$idUsuario');

      // limpia el usuario actual en memoria
      limpiarUsuarioActual();

      return true;
    } catch (e) {
      return false;
    }
  }

  // actualiza flag de primer inicio
  Future<bool> actualizarPrimerInicio(String usuarioId) async {
    try {
      final id = int.parse(usuarioId);

      // hace peticion para actualizar el flag de primer inicio
      final respuesta = await _apiService.put('usuarios/$id/actualizar-primer-inicio', {
        'primerInicio': 1
      });

      // si el usuario actual tiene este id actualiza tambien en memoria
      if (_usuarioActual != null && _usuarioActual!.id == usuarioId) {
        _usuarioActual = _usuarioActual!.copyWith(primerInicio: true);
      }

      return respuesta != null && respuesta['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // actualiza usuario actual en memoria
  Future<void> actualizarUsuarioActual(Usuario usuarioActualizado) async {
    try {
      // asigna el usuario actualizado a la variable
      _usuarioActual = usuarioActualizado;
    } catch (e) {
      throw e;
    }
  }

  // verifica si el usuario es trabajador usando endpoint
  Future<bool> esTrabajador() async {
    try {
      final idUsuario = await obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return false;
      }

      final respuesta = await _apiService.get('usuarios/$idUsuario/es-trabajador');
      if (respuesta != null && respuesta is Map<String, dynamic>) {
        final esTrabajador = respuesta['esTrabajador'] as bool? ?? false;
        return esTrabajador;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // verifica si el usuario es cliente por defecto todos son clientes
  Future<bool> esCliente() async {
    try {
      // en el sistema todos los usuarios registrados son clientes por defecto
      // solo verifica que tenga un usuario valido
      final usuario = await obtenerUsuarioActual();
      return usuario != null;
    } catch (e) {
      return false;
    }
  }

  // asigna rol de trabajador usando endpoint
  Future<bool> asignarRolTrabajador() async {
    try {
      final idUsuario = await obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return false;
      }

      final respuesta = await _apiService.post('usuarios/$idUsuario/asignar-trabajador', {});
      if (respuesta != null && respuesta is Map<String, dynamic>) {
        final success = respuesta['success'] as bool? ?? false;
        return success;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // quita rol de trabajador usando endpoint
  Future<bool> quitarRolTrabajador() async {
    try {
      final idUsuario = await obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return false;
      }

      final respuesta = await _apiService.delete('usuarios/$idUsuario/quitar-trabajador');
      if (respuesta != null && respuesta is Map<String, dynamic>) {
        final success = respuesta['success'] as bool? ?? false;
        return success;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}