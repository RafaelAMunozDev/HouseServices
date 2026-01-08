import 'package:flutter/material.dart';
import '../utils/OperacionesServicios.dart';

class ServicioDisponible {
  // propiedades del servicio disponible
  final int id;
  final int trabajadorId;
  final String nombreTrabajador;
  final int servicioId;
  final String nombreServicio;
  final String? descripcionServicio;
  final String? descripcion;
  final String? observaciones;
  final double precioHora;
  final String color;
  final String? iconoServicio;
  final double valoracionPromedio;
  final int totalValoraciones;
  final String? urlImagenPerfilTrabajador;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  // constructor principal
  ServicioDisponible({
    required this.id,
    required this.trabajadorId,
    required this.nombreTrabajador,
    required this.servicioId,
    required this.nombreServicio,
    this.descripcionServicio,
    this.descripcion,
    this.observaciones,
    required this.precioHora,
    required this.color,
    this.iconoServicio,
    required this.valoracionPromedio,
    required this.totalValoraciones,
    this.urlImagenPerfilTrabajador,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  // método para crear un objeto desde json
  factory ServicioDisponible.fromJson(Map<String, dynamic> json) {
    return ServicioDisponible(
      id: json['id'] ?? 0,
      trabajadorId: json['trabajador_id'] ?? json['trabajadorId'] ?? 0,
      nombreTrabajador: json['nombre_trabajador'] ?? json['nombreTrabajador'] ?? '',
      servicioId: json['servicio_id'] ?? json['servicioId'] ?? 0,
      nombreServicio: json['nombre_servicio'] ?? json['nombreServicio'] ?? '',
      descripcionServicio: json['descripcion_servicio'] ?? json['descripcionServicio'],
      descripcion: json['descripcion'],
      observaciones: json['observaciones'],
      precioHora: (json['precio_hora'] ?? json['precioHora'] ?? 0) is num
          ? (json['precio_hora'] ?? json['precioHora'] ?? 0).toDouble()
          : 0.0,
      color: json['color'] ?? '#AAAAFF',
      iconoServicio: json['icono_servicio'] ?? json['iconoServicio'],
      valoracionPromedio: (json['valoracion_promedio'] ?? json['valoracionPromedio'] ?? 0) is num
          ? (json['valoracion_promedio'] ?? json['valoracionPromedio'] ?? 0).toDouble()
          : 0.0,
      totalValoraciones: json['total_valoraciones'] ?? json['totalValoraciones'] ?? 0,
      urlImagenPerfilTrabajador: json['url_imagen_perfil_trabajador'] ?? json['urlImagenPerfilTrabajador'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.tryParse(json['fecha_actualizacion'].toString())
          : null,
    );
  }

  // método para obtener la descripción completa (prioriza descripcionServicio, luego descripcion)
  String? get descripcionCompleta {
    if (descripcionServicio != null && descripcionServicio!.isNotEmpty) {
      return descripcionServicio;
    }
    return descripcion;
  }

  // método para convertir el código de color hexadecimal a Color
  Color obtenerColorServicio() {
    return OperacionesServicios.convertirColor(color);
  }

  // método para crear un mapa para enviar a la api (formato backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trabajador_id': trabajadorId,
      'servicio_id': servicioId,
      'descripcion': descripcion,
      'observaciones': observaciones,
      'precio_hora': precioHora,
    };
  }

  // método para crear un mapa con formato camelCase (si es necesario)
  Map<String, dynamic> toJsonCamelCase() {
    return {
      'id': id,
      'trabajadorId': trabajadorId,
      'nombreTrabajador': nombreTrabajador,
      'servicioId': servicioId,
      'nombreServicio': nombreServicio,
      'descripcionServicio': descripcionServicio,
      'descripcion': descripcion,
      'observaciones': observaciones,
      'precioHora': precioHora,
      'color': color,
      'iconoServicio': iconoServicio,
      'valoracionPromedio': valoracionPromedio,
      'totalValoraciones': totalValoraciones,
      'urlImagenPerfilTrabajador': urlImagenPerfilTrabajador,
    };
  }

  // método para crear una copia con algunos campos modificados
  ServicioDisponible copyWith({
    int? id,
    int? trabajadorId,
    String? nombreTrabajador,
    int? servicioId,
    String? nombreServicio,
    String? descripcionServicio,
    String? descripcion,
    String? observaciones,
    double? precioHora,
    String? color,
    String? iconoServicio,
    double? valoracionPromedio,
    int? totalValoraciones,
    String? urlImagenPerfilTrabajador,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ServicioDisponible(
      id: id ?? this.id,
      trabajadorId: trabajadorId ?? this.trabajadorId,
      nombreTrabajador: nombreTrabajador ?? this.nombreTrabajador,
      servicioId: servicioId ?? this.servicioId,
      nombreServicio: nombreServicio ?? this.nombreServicio,
      descripcionServicio: descripcionServicio ?? this.descripcionServicio,
      descripcion: descripcion ?? this.descripcion,
      observaciones: observaciones ?? this.observaciones,
      precioHora: precioHora ?? this.precioHora,
      color: color ?? this.color,
      iconoServicio: iconoServicio ?? this.iconoServicio,
      valoracionPromedio: valoracionPromedio ?? this.valoracionPromedio,
      totalValoraciones: totalValoraciones ?? this.totalValoraciones,
      urlImagenPerfilTrabajador: urlImagenPerfilTrabajador ?? this.urlImagenPerfilTrabajador,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'ServicioDisponible(id: $id, trabajadorId: $trabajadorId, nombreTrabajador: $nombreTrabajador, servicioId: $servicioId, nombreServicio: $nombreServicio, precioHora: $precioHora)';
  }
}