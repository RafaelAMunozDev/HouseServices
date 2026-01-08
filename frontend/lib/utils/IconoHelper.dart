import 'package:flutter/material.dart';

// helper para mapear nombres de iconos a icondata
class IconoHelper {

  // mapa de nombres de iconos
  static final Map<String, IconData> _iconos = {
    // servicios principales
    'cleaning_services': Icons.cleaning_services,
    'plumbing': Icons.plumbing,
    'electrical_services': Icons.electrical_services,
    'content_cut': Icons.content_cut,
    'spa': Icons.spa,
    'car_repair': Icons.car_repair,
    'computer': Icons.computer,
    'format_paint': Icons.format_paint,
    'local_florist': Icons.local_florist,
    'carpenter': Icons.carpenter,

    // iconos adicionales
    'work': Icons.work,
    'build': Icons.build,
    'home_repair_service': Icons.home_repair_service,
    'handyman': Icons.handyman,
    'construction': Icons.construction,
    'design_services': Icons.design_services,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'delivery_dining': Icons.delivery_dining,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'elderly': Icons.elderly,
    'security': Icons.security,
    'cleaning': Icons.cleaning_services,
    'electric': Icons.electrical_services,
  };

  // obtiene el icono correspondiente al nombre
  static IconData obtenerIcono(String? nombreIcono) {
    if (nombreIcono == null || nombreIcono.isEmpty) {
      return Icons.work;
    }

    final iconoLower = nombreIcono.toLowerCase().trim();
    return _iconos[iconoLower] ?? Icons.work;
  }

  // obtiene color por tipo de servicio
  static Color obtenerColorServicio(String? nombreServicio) {
    if (nombreServicio == null) return const Color(0xFF616281);

    switch (nombreServicio.toLowerCase()) {
      case 'limpieza':
        return const Color(0xFF4CAF50);
      case 'fontaneria':
        return const Color(0xFF2196F3);
      case 'electricidad':
        return const Color(0xFFFFC107);
      case 'peluqueria':
        return const Color(0xFF9C27B0);
      case 'masajes':
        return const Color(0xFFFF5722);
      case 'mecanica':
        return const Color(0xFF795548);
      case 'informatica':
        return const Color(0xFF3F51B5);
      case 'pintura':
        return const Color(0xFFE91E63);
      case 'jardineria':
        return const Color(0xFF4CAF50);
      case 'carpinteria':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF616281);
    }
  }

  // crea widget icon dinamico
  static Widget crearIcono(
      String? nombreIcono, {
        double? size,
        Color? color,
      }) {
    return Icon(
      obtenerIcono(nombreIcono),
      size: size,
      color: color,
    );
  }
}