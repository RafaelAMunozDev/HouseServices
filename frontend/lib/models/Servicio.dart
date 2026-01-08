// models/Servicio.dart
import 'dart:ui';

// modelo para los tipos de servicios disponibles
class Servicio {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String color;

  Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color = "#AAAAFF",
  });

  // crear desde json
  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      icono: json['icono'],
      color: json['color'] ?? "#AAAAFF",
    );
  }

  // convertir a json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'color': color,
    };
  }

  // obtiene el color como color de flutter
  Color obtenerColor() {
    try {
      // remueve el simbolo y convierte a int
      String colorHex = color.replaceAll('#', '');
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (e) {
      // color por defecto si hay error
      return const Color(0xFFAAADFF);
    }
  }

  // obtiene el icono usando iconohelper
  String get iconoParaHelper {
    // si no hay icono definido usa el nombre del servicio para buscar
    if (icono == null || icono!.isEmpty) {
      // mapea nombre del servicio a icono
      switch (nombre.toLowerCase()) {
        case 'limpieza':
          return 'cleaning_services';
        case 'fontanería':
        case 'fontaneria':
          return 'plumbing';
        case 'electricidad':
          return 'electrical_services';
        case 'peluquería':
        case 'peluqueria':
          return 'content_cut';
        case 'masajes':
          return 'spa';
        case 'mecánica':
        case 'mecanica':
          return 'car_repair';
        case 'informática':
        case 'informatica':
          return 'computer';
        case 'pintura':
          return 'format_paint';
        case 'jardinería':
        case 'jardineria':
          return 'local_florist';
        case 'carpintería':
        case 'carpinteria':
          return 'carpenter';
        default:
          return 'work';
      }
    }
    return icono!;
  }

  @override
  String toString() {
    return 'Servicio{id: $id, nombre: $nombre, descripcion: $descripcion, icono: $icono, color: $color}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Servicio && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}