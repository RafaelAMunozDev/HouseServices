// modelo de datos para representar la ubicacion de un usuario
class UsuarioUbicacion {
  // propiedades de la ubicacion
  final int? id;
  final int usuarioId;
  final double? latitud;
  final double? longitud;

  // constructor principal
  UsuarioUbicacion({
    this.id,
    required this.usuarioId,
    this.latitud,
    this.longitud,
  });

  // metodo para crear un objeto desde json (respuesta de api)
  factory UsuarioUbicacion.fromJson(Map<String, dynamic> json) {
    return UsuarioUbicacion(
      id: json['id'],
      usuarioId: json['usuario_id'],
      latitud: json['latitud'],
      longitud: json['longitud'],
    );
  }

  // metodo para crear un mapa para enviar a la api
  Map<String, dynamic> toJson() {
    // creamos un mapa base con los campos obligatorios
    Map<String, dynamic> mapa = {
      'usuario_id': usuarioId,
    };

    // añadimos los campos opcionales solo si no son nulos
    if (id != null) mapa['id'] = id;
    if (latitud != null) mapa['latitud'] = latitud;
    if (longitud != null) mapa['longitud'] = longitud;

    return mapa;
  }

  // metodo para comprobar si tiene coordenadas validas
  bool get tieneCoordenadas {
    return latitud != null && longitud != null;
  }

  // metodo para crear una copia con diferentes valores
  UsuarioUbicacion copiarCon({
    int? id,
    int? usuarioId,
    double? latitud,
    double? longitud,
  }) {
    return UsuarioUbicacion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }

  // metodo estatico para crear un objeto con solo el id de usuario
  static UsuarioUbicacion crearSoloUsuarioId(int usuarioId) {
    return UsuarioUbicacion(
      usuarioId: usuarioId,
    );
  }
}