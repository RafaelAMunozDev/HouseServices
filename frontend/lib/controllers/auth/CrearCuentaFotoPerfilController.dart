import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ImagenService.dart';
import '../../ui/auth/CuentaConfirmada.dart';
import '../../utils/Dialogos.dart';
import '../../widgets/Componentes_reutilizables.dart';

class CrearCuentaFotoPerfilController {
  final ImagenService _imagenService = ImagenService();
  File? imagenSeleccionada;

  // selecciona imagen desde la galeria del dispositivo
  Future<File?> seleccionarImagenGaleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (imagen != null) {
      return File(imagen.path);
    }
    return null;
  }

  // toma foto usando la camara del dispositivo
  Future<File?> tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (imagen != null) {
      return File(imagen.path);
    }
    return null;
  }

  // sube la imagen al servidor usando el servicio correspondiente
  Future<bool> subirImagenPerfil(BuildContext context, File imagen) async {
    try {
      // muestra indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const Center(
          child: CirculoCargarPersonalizado(),
        ),
      );

      // sube imagen al servidor
      final imagenPerfil = await _imagenService.subirImagenPerfil(imagen);

      // cierra indicador de carga
      Navigator.pop(context);

      return imagenPerfil != null;
    } catch (e) {
      // cierra carga si esta abierta
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return false;
    }
  }

  // omite el paso de foto de perfil
  void omitirFotoPerfil(BuildContext context) {
    navegarAPantallaPrincipal(context);
  }

  // completa el registro y navega a la pantalla de confirmacion
  void navegarAPantallaPrincipal(BuildContext context) {
    // muestra dialogo de carga personalizado
    Dialogos.mostrarDialogoCarga(context);

    // espera unos segundos y luego navega
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        // cierra el dialogo de carga
        Navigator.of(context).pop();

        // navega a confirmacion eliminando historial
        Componentes_reutilizables.navegarConTransicion(
            context,
            const CuentaConfirmada(),
            reemplazar: true
        );
      }
    });
  }
}