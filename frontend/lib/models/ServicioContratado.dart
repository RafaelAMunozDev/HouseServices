import 'dart:convert';

// modelo para servicios contratados por clientes
class ServicioContratado {
  final int? id;
  final int? clienteId;
  final int? servicioDisponibleId;
  final DateTime? fechaConfirmada;
  final DateTime? fechaRealizada;
  final int? estadoId;
  final Map<String, dynamic>? horarioSeleccionado;
  final String? observaciones;

  // campos adicionales del join con servicio disponible
  final String? nombreServicio;
  final String? nombreTrabajador;
  final double? precioHora;
  final String? estadoNombre;

  // campos especificos para el historial
  final int? servicioId;
  final String? servicioNombre;
  final String? servicioIcono;
  final String? servicioColor;
  final int? trabajadorId;
  final String? trabajadorNombre;
  final String? fecha;
  final String? diaSemana;
  final String? horaInicio;
  final String? horaFin;
  final int? duracionMinutos;

  ServicioContratado({
    this.id,
    this.clienteId,
    this.servicioDisponibleId,
    this.fechaConfirmada,
    this.fechaRealizada,
    this.estadoId,
    this.horarioSeleccionado,
    this.observaciones,
    this.nombreServicio,
    this.nombreTrabajador,
    this.precioHora,
    this.estadoNombre,
    // campos especificos del historial
    this.servicioId,
    this.servicioNombre,
    this.servicioIcono,
    this.servicioColor,
    this.trabajadorId,
    this.trabajadorNombre,
    this.fecha,
    this.diaSemana,
    this.horaInicio,
    this.horaFin,
    this.duracionMinutos,
  });

  factory ServicioContratado.fromJson(Map<String, dynamic> json) {
    try {
      // detecta si es formato de historial o formato normal
      bool esFormatoHistorial = json.containsKey('servicio_nombre') &&
          json.containsKey('trabajador_nombre') &&
          json.containsKey('fecha') &&
          json.containsKey('hora_inicio');

      ServicioContratado servicio;

      if (esFormatoHistorial) {
        // formato del historial del cliente
        servicio = ServicioContratado(
          id: _safeParseInt(json['servicio_contratado_id'] ?? json['id']),
          clienteId: _safeParseInt(json['cliente_id']),
          estadoId: _safeParseInt(json['estado_id']),
          estadoNombre: json['estado_nombre']?.toString(),
          observaciones: json['observaciones']?.toString(),
          fechaConfirmada: _safeParseDateTime(json['fecha_confirmada']),
          fechaRealizada: _safeParseDateTime(json['fecha_realizada']),
          servicioId: _safeParseInt(json['servicio_id']),
          servicioNombre: json['servicio_nombre']?.toString(),
          servicioIcono: json['servicio_icono']?.toString(),
          servicioColor: json['servicio_color']?.toString(),
          precioHora: _safeParseDouble(json['precio_hora']),
          trabajadorId: _safeParseInt(json['trabajador_id']),
          trabajadorNombre: json['trabajador_nombre']?.toString(),
          fecha: json['fecha']?.toString(),
          diaSemana: json['dia_semana']?.toString(),
          horaInicio: json['hora_inicio']?.toString(),
          horaFin: json['hora_fin']?.toString(),
          duracionMinutos: _safeParseInt(json['duracion_minutos']),
          nombreServicio: json['servicio_nombre']?.toString(),
          nombreTrabajador: json['trabajador_nombre']?.toString(),
        );
      } else {
        // formato normal de servicios contratados
        servicio = ServicioContratado(
          id: _safeParseInt(json['servicio_contratado_id'] ?? json['id']),
          clienteId: _safeParseInt(json['cliente_id']),
          servicioDisponibleId: _safeParseInt(json['servicio_disponible_id']),
          fechaConfirmada: _safeParseDateTime(json['fecha_confirmada']),
          fechaRealizada: _safeParseDateTime(json['fecha_realizada']),
          estadoId: _safeParseInt(json['estado_id']),
          horarioSeleccionado: _safeParseHorario(json['horario_seleccionado']),
          observaciones: json['observaciones']?.toString(),
          nombreServicio: json['servicio_nombre']?.toString(),
          nombreTrabajador: json['nombre_trabajador']?.toString(),
          precioHora: _safeParseDouble(json['precio_hora']),
          estadoNombre: json['estado_nombre']?.toString(),
          trabajadorId: _safeParseInt(json['trabajador_id']),
        );
      }

      return servicio;

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // metodos auxiliares seguros para conversion de tipos
  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _safeParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime? _safeParseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String && value.isNotEmpty) {
        return DateTime.parse(value);
      }
    } catch (e) {
      // error silencioso
    }
    return null;
  }

  static Map<String, dynamic>? _safeParseHorario(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return jsonDecode(value);
      } else if (value is Map<String, dynamic>) {
        return value;
      }
    } catch (e) {
      // error silencioso
    }
    return null;
  }

  // getter para compatibilidad con codigo existente
  String get nombreCompletoCliente {
    return nombreTrabajador ?? trabajadorNombre ?? 'Trabajador sin nombre';
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (servicioDisponibleId != null) 'servicio_disponible_id': servicioDisponibleId,
      if (trabajadorId != null) 'trabajador_id': trabajadorId,
      if (fechaConfirmada != null) 'fecha_confirmada': fechaConfirmada!.toIso8601String(),
      if (fechaRealizada != null) 'fecha_realizada': fechaRealizada!.toIso8601String(),
      if (estadoId != null) 'estado_id': estadoId,
      if (horarioSeleccionado != null) 'horario_seleccionado': jsonEncode(horarioSeleccionado),
      'observaciones': observaciones,
    };
  }

  // metodos helper para trabajar con el horario
  String get fechaSeleccionada {
    if (fecha != null) {
      return fecha!;
    } else if (horarioSeleccionado != null) {
      return horarioSeleccionado!['fecha'] ?? '';
    } else {
      return '';
    }
  }

  String get diaSemanaSeleccionado {
    if (diaSemana != null) {
      return diaSemana!;
    } else if (horarioSeleccionado != null) {
      return horarioSeleccionado!['dia_semana'] ?? '';
    } else {
      return '';
    }
  }

  String get horaInicioSeleccionada {
    if (horaInicio != null) {
      return horaInicio!;
    } else if (horarioSeleccionado != null) {
      return horarioSeleccionado!['hora_inicio'] ?? '';
    } else {
      return '';
    }
  }

  String get horaFinSeleccionada {
    if (horaFin != null) {
      return horaFin!;
    } else if (horarioSeleccionado != null) {
      return horarioSeleccionado!['hora_fin'] ?? '';
    } else {
      return '';
    }
  }

  DateTime get fechaSolicitudSegura {
    return DateTime.now();
  }

  DateTime? get fechaHoraInicio {
    try {
      final fechaStr = fechaSeleccionada;
      final horaStr = horaInicioSeleccionada;

      if (fechaStr.isEmpty || horaStr.isEmpty) {
        return null;
      }

      final fechaParts = fechaStr.split('-');
      final horaParts = horaStr.split(':');

      return DateTime(
        int.parse(fechaParts[0]),
        int.parse(fechaParts[1]),
        int.parse(fechaParts[2]),
        int.parse(horaParts[0]),
        int.parse(horaParts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ServicioContratado{id: $id, nombreServicio: $nombreServicio, servicioNombre: $servicioNombre, estadoNombre: $estadoNombre}';
  }
}