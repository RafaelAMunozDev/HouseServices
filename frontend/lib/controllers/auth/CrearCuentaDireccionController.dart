import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/UbicacionService.dart';
import '../../ui/auth/CrearCuentaFotoPerfil.dart';
import '../../widgets/Componentes_reutilizables.dart';

class CrearCuentaDireccionController {
  final UbicacionService _ubicacionService = UbicacionService();

  // obtiene la ubicacion actual del dispositivo usando el servicio
  Future<Position?> obtenerUbicacionActual(BuildContext context) async {
    return await _ubicacionService.obtenerUbicacionActual(context);
  }

  // guarda la ubicacion del usuario en el sistema
  Future<bool> registrarUbicacion(BuildContext context, double latitud, double longitud) async {
    return await _ubicacionService.guardarUbicacionUsuario(context, latitud, longitud);
  }

  void navegarAPantallaConfirmacion(BuildContext context) {
    Componentes_reutilizables.navegarConTransicion(
        context,
        const CrearCuentaFotoPerfil()
    );
  }
}