import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/ApiService.dart';

// servicio para manejo de roles de usuario con cache
class UsuarioRolService {
  final ApiService _apiService = ApiService();
  final _almacenamientoSeguro = const FlutterSecureStorage();

  // clave para almacenamiento del rol de trabajador
  static const String _claveRolTrabajador = 'es_trabajador';

  // verifica si un usuario tiene rol de trabajador
  Future<bool> verificarRolTrabajador(String? usuarioId) async {
    if (usuarioId == null) {
      return false;
    }

    try {
      // intenta obtener el valor desde almacenamiento seguro
      final cacheKey = '$_claveRolTrabajador:$usuarioId';
      final valorCache = await _almacenamientoSeguro.read(key: cacheKey);

      // si existe un valor en cache lo devuelve
      if (valorCache != null) {
        return valorCache.toLowerCase() == 'true';
      }
    } catch (e) {
      // error silencioso para cache
    }

    // si no hay cache o fallo consulta al servidor
    try {
      final respuesta = await _apiService.get('usuarios/$usuarioId/es-trabajador');
      final esTrabajador = respuesta['esTrabajador'] ?? false;

      // guarda en cache
      try {
        final cacheKey = '$_claveRolTrabajador:$usuarioId';
        await _almacenamientoSeguro.write(key: cacheKey, value: esTrabajador.toString());
      } catch (e) {
        // error silencioso para cache
      }

      return esTrabajador;
    } catch (e) {
      return false;
    }
  }

  // asigna rol de trabajador a un usuario
  Future<bool> asignarRolTrabajador(String? usuarioId) async {
    if (usuarioId == null) {
      return false;
    }

    try {
      final respuesta = await _apiService.post('usuarios/$usuarioId/asignar-trabajador', {});
      final exitoso = respuesta['success'] ?? false;

      // si fue exitoso actualiza la cache
      if (exitoso) {
        try {
          final cacheKey = '$_claveRolTrabajador:$usuarioId';
          await _almacenamientoSeguro.write(key: cacheKey, value: 'true');
        } catch (e) {
          // error silencioso para cache
        }
      }

      return exitoso;
    } catch (e) {
      return false;
    }
  }

  // quita rol de trabajador a un usuario
  Future<bool> quitarRolTrabajador(String? usuarioId) async {
    if (usuarioId == null) {
      return false;
    }

    try {
      final respuesta = await _apiService.delete('usuarios/$usuarioId/quitar-trabajador');
      final exitoso = respuesta['success'] ?? false;

      // si fue exitoso actualiza la cache
      if (exitoso) {
        try {
          final cacheKey = '$_claveRolTrabajador:$usuarioId';
          await _almacenamientoSeguro.write(key: cacheKey, value: 'false');
        } catch (e) {
          // error silencioso para cache
        }
      }

      return exitoso;
    } catch (e) {
      return false;
    }
  }

  // limpia la cache de roles para cierre de sesion
  Future<void> limpiarCacheRoles() async {
    try {
      // obtiene todas las claves
      final todasLasClaves = await _almacenamientoSeguro.readAll();

      // filtra las claves relacionadas con roles
      final clavesRoles = todasLasClaves.keys
          .where((clave) => clave.startsWith('$_claveRolTrabajador:'))
          .toList();

      // elimina cada clave relacionada con roles
      for (final clave in clavesRoles) {
        await _almacenamientoSeguro.delete(key: clave);
      }
    } catch (e) {
      // error silencioso
    }
  }
}