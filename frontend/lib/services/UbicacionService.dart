import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/Dialogos.dart';
import './ApiService.dart';
import './UsuarioService.dart';
import '../models/UsuarioUbicacion.dart';

// servicio para manejo de ubicaciones y geolocalizacion
class UbicacionService {
  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();

  // obtiene ubicacion actual del dispositivo
  Future<Position?> obtenerUbicacionActual(BuildContext context) async {
    try {
      // verifica servicio de ubicacion
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        Dialogos.mostrarDialogoError(context, 'Por favor, habilita los servicios de ubicación.');
        return null;
      }

      // verifica permisos
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          Dialogos.mostrarDialogoError(context, 'Permiso de ubicación denegado.');
          return null;
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        Dialogos.mostrarDialogoError(context, 'Permiso de ubicación denegado permanentemente.');
        return null;
      }

      // obtiene posicion con alta precision
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      Dialogos.mostrarDialogoError(context, 'Error al obtener la ubicación: $e');
      return null;
    }
  }

  // guarda ubicacion del usuario en el servidor
  Future<bool> guardarUbicacionUsuario(BuildContext context, double latitud, double longitud) async {
    try {
      // muestra indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CirculoCargarPersonalizado(),
      );

      // obtiene el usuario actual
      final usuario = await _usuarioService.obtenerUsuarioActual();

      // si no puede obtener el usuario maneja el error
      if (usuario == null) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // intenta obtener el uid directamente de firebase
        final firebaseUid = await _usuarioService.obtenerFirebaseUid();

        if (firebaseUid == null) {
          Dialogos.mostrarDialogoError(context, 'No se pudo identificar al usuario actual. Por favor, inicia sesión nuevamente.');
          return false;
        }

        // usa el uid de firebase para crear la ubicacion
        try {
          await _apiService.post('ubicaciones/crear-por-uid', {
            'firebaseUid': firebaseUid,
            'latitud': latitud,
            'longitud': longitud
          });

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          return true;
        } catch (e) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          Dialogos.mostrarDialogoError(context, 'Error al guardar la ubicación: ${e.toString()}');
          return false;
        }
      }

      // si tiene el usuario procede normalmente
      final ubicacion = UsuarioUbicacion(
        usuarioId: int.parse(usuario.id!),
        latitud: latitud,
        longitud: longitud,
      );

      await _apiService.post('ubicaciones', ubicacion.toJson());

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return true;
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      Dialogos.mostrarDialogoError(context, 'Error al guardar la ubicación: ${e.toString()}');
      return false;
    }
  }

  // actualiza ubicacion de usuario existente
  Future<bool> actualizarUbicacionUsuario(BuildContext context, int ubicacionId, double latitud, double longitud) async {
    try {
      // muestra indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CirculoCargarPersonalizado(),
      );

      // obtiene el usuario actual
      final usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario == null || usuario.id == null) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Dialogos.mostrarDialogoError(context, 'No se pudo identificar al usuario actual');
        return false;
      }

      // actualiza la ubicacion con el usuario id incluido
      await _apiService.put('ubicaciones/$ubicacionId', {
        'usuario_id': int.parse(usuario.id!),
        'latitud': latitud,
        'longitud': longitud
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return true;
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      Dialogos.mostrarDialogoError(context, 'Error al actualizar la ubicación: ${e.toString()}');
      return false;
    }
  }

  // obtiene la ubicacion actual del usuario desde el servidor
  Future<UsuarioUbicacion?> obtenerUbicacionUsuario(BuildContext context) async {
    try {
      final usuario = await _usuarioService.obtenerUsuarioActual();
      if (usuario == null || usuario.id == null) {
        return null;
      }

      final respuesta = await _apiService.get('ubicaciones/usuario/${usuario.id}');
      if (respuesta == null) {
        return null;
      }

      // verifica si la respuesta es una lista
      if (respuesta is List && respuesta.isNotEmpty) {
        // si es una lista toma el primer elemento
        return UsuarioUbicacion.fromJson(respuesta[0]);
      } else if (respuesta is Map<String, dynamic>) {
        // si ya es un objeto directo
        return UsuarioUbicacion.fromJson(respuesta);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // convierte position a latlng
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}