import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/UbicacionService.dart';
import '../../../models/UsuarioUbicacion.dart';

// controla la logica de edicion de direccion del usuario
class EditarDireccionController {
  final UbicacionService _ubicacionService = UbicacionService();

  // obtiene la ubicacion guardada del usuario desde la base de datos
  Future<UsuarioUbicacion?> obtenerUbicacionUsuario(BuildContext context) async {
    return await _ubicacionService.obtenerUbicacionUsuario(context);
  }

  // obtiene la posicion actual del dispositivo usando gps
  Future<Position?> obtenerUbicacionActual(BuildContext context) async {
    return await _ubicacionService.obtenerUbicacionActual(context);
  }

  // actualiza las coordenadas de ubicacion del usuario en el servidor
  Future<bool> actualizarUbicacion(BuildContext context, int ubicacionId, double latitud, double longitud) async {
    return await _ubicacionService.actualizarUbicacionUsuario(context, ubicacionId, latitud, longitud);
  }
}