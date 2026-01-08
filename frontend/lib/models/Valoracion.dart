class Valoracion {
  final int? id;
  final int servicioContratadoId;
  final int clienteId;
  final int? trabajadorId;
  final int puntuacion;
  final String? comentario;
  final DateTime fechaValoracion;

  // Campos adicionales que pueden venir del backend
  final String? nombreCliente;
  final String? apellidoCliente;
  final String? nombreTrabajador;
  final String? apellidoTrabajador;
  final String? nombreServicio;

  Valoracion({
    this.id,
    required this.servicioContratadoId,
    required this.clienteId,
    this.trabajadorId,
    required this.puntuacion,
    this.comentario,
    required this.fechaValoracion,
    this.nombreCliente,
    this.apellidoCliente,
    this.nombreTrabajador,
    this.apellidoTrabajador,
    this.nombreServicio,
  });

  // Constructor desde JSON del backend
  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'] as int?,
      servicioContratadoId: json['servicio_contratado_id'] as int,
      clienteId: json['cliente_id'] as int,
      trabajadorId: json['trabajador_id'] as int?,
      puntuacion: json['puntuacion'] as int,
      comentario: json['comentario'] as String?,
      fechaValoracion: DateTime.parse(json['fecha_valoracion'] as String),
      nombreCliente: json['nombre_cliente'] as String?,
      apellidoCliente: json['apellido_cliente'] as String?,
      nombreTrabajador: json['nombre_trabajador'] as String?,
      apellidoTrabajador: json['apellido_trabajador'] as String?,
      nombreServicio: json['nombre_servicio'] as String?,
    );
  }


  // Constructor desde JSON con detalles (para trabajador)
  factory Valoracion.fromJsonConDetalles(Map<String, dynamic> json) {
    final valoracionData = json['valoracion'] as Map<String, dynamic>;
    final servicioData = json['servicio_contratado'] as Map<String, dynamic>?;

    return Valoracion(
      id: valoracionData['id'] as int?,
      servicioContratadoId: valoracionData['servicio_contratado_id'] as int,
      clienteId: valoracionData['cliente_id'] as int,
      trabajadorId: valoracionData['trabajador_id'] as int,
      puntuacion: valoracionData['puntuacion'] as int,
      comentario: valoracionData['comentario'] as String?,
      fechaValoracion: DateTime.parse(valoracionData['fecha_valoracion'] as String),
      nombreCliente: servicioData?['cliente_nombre'] as String?,
      apellidoCliente: servicioData?['cliente_apellido'] as String?,
      nombreTrabajador: servicioData?['trabajador_nombre'] as String?,
      apellidoTrabajador: servicioData?['trabajador_apellido'] as String?,
      nombreServicio: servicioData?['nombre_servicio'] as String?,
    );
  }

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'servicio_contratado_id': servicioContratadoId,
      'cliente_id': clienteId,
      'trabajador_id': trabajadorId,
      'puntuacion': puntuacion,
      'comentario': comentario,
    };
  }

  // Getter para nombre completo del cliente
  String get nombreCompletoCliente {
    if (nombreCliente != null && apellidoCliente != null) {
      return '$nombreCliente $apellidoCliente';
    } else if (nombreCliente != null) {
      return nombreCliente!;
    }
    return 'Cliente';
  }

  // Getter para nombre completo del trabajador
  String get nombreCompletoTrabajador {
    if (nombreTrabajador != null && apellidoTrabajador != null) {
      return '$nombreTrabajador $apellidoTrabajador';
    } else if (nombreTrabajador != null) {
      return nombreTrabajador!;
    }
    return 'Trabajador';
  }

  // Getter para fecha formateada
  String get fechaFormateada {
    return '${fechaValoracion.day.toString().padLeft(2, '0')}/'
        '${fechaValoracion.month.toString().padLeft(2, '0')}/'
        '${fechaValoracion.year}';
  }

  // Getter para fecha y hora formateadas
  String get fechaHoraFormateada {
    return '${fechaValoracion.day.toString().padLeft(2, '0')}/'
        '${fechaValoracion.month.toString().padLeft(2, '0')}/'
        '${fechaValoracion.year} '
        '${fechaValoracion.hour.toString().padLeft(2, '0')}:'
        '${fechaValoracion.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Valoracion{id: $id, servicioContratadoId: $servicioContratadoId, '
        'clienteId: $clienteId, trabajadorId: $trabajadorId, puntuacion: $puntuacion, '
        'comentario: $comentario, fechaValoracion: $fechaValoracion}';
  }
}