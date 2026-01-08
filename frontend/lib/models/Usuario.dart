// modelo de datos para representar un usuario en la aplicacion
class Usuario {
  // propiedades del usuario
  final String? id;
  final String? firebaseUid;
  final String nombre;
  final String apellido1;
  final String? apellido2;
  final String? dni;
  final String? fechaNacimiento;
  final String? telefono;
  final String correo;
  final bool primerInicio;

  // constructor principal
  Usuario({
    this.id,
    this.firebaseUid,
    required this.nombre,
    required this.apellido1,
    required this.correo,
    this.apellido2,
    this.dni,
    this.fechaNacimiento,
    this.telefono,
    this.primerInicio = false,
  });

  // metodo para crear un objeto desde json (respuesta de api)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] != null ? json['id'].toString() : null,
      firebaseUid: json['firebaseUid'],
      nombre: json['nombre'],
      apellido1: json['apellido1'],
      apellido2: json['apellido2'],
      dni: json['dni'],
      fechaNacimiento: json['fechaNacimiento'],
      telefono: json['telefono'],
      correo: json['correo'] ?? '',
      primerInicio: json['primerInicio'] == 1,
    );
  }

  // metodo para crear un mapa para enviar a la api
  Map<String, dynamic> toJson({String? token}) {
    // creamos un mapa base con los campos obligatorios
    Map<String, dynamic> mapa = {
      'nombre': nombre,
      'apellido1': apellido1,
      'correo': correo,
      'primerInicio': primerInicio ? 1 : 0,
    };

    // añadimos los campos opcionales solo si no son nulos
    if (id != null) mapa['id'] = id;
    if (apellido2 != null && apellido2!.isNotEmpty) mapa['apellido2'] = apellido2;
    if (dni != null && dni!.isNotEmpty) mapa['dni'] = dni;
    if (fechaNacimiento != null && fechaNacimiento!.isNotEmpty) mapa['fechaNacimiento'] = fechaNacimiento;
    if (telefono != null && telefono!.isNotEmpty) mapa['telefono'] = telefono;
    if (token != null) mapa['token'] = token;

    return mapa;
  }

  // metodo para obtener el nombre completo del usuario
  String get nombreCompleto {
    if (apellido2 != null && apellido2!.isNotEmpty) {
      return '$nombre $apellido1 $apellido2';
    }
    return '$nombre $apellido1';
  }

  Usuario copyWith({
    String? id,
    String? firebaseUid,
    String? nombre,
    String? apellido1,
    String? apellido2,
    String? dni,
    String? fechaNacimiento,
    String? telefono,
    String? correo,
    bool? primerInicio,
  }) {
    return Usuario(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      nombre: nombre ?? this.nombre,
      apellido1: apellido1 ?? this.apellido1,
      apellido2: apellido2 ?? this.apellido2,
      dni: dni ?? this.dni,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      primerInicio: primerInicio ?? this.primerInicio,
    );
  }

  // metodo estatico para el caso de login donde solo tenemos email y contraseña
  static Map<String, dynamic> crearMapaLogin({
    required String correo,
    required String contrasena,
    String? token,
  }) {
    // mapa basico para login
    Map<String, dynamic> mapa = {
      'correo': correo,
      'contrasena': contrasena,
    };

    // añadimos token si existe
    if (token != null) mapa['token'] = token;

    return mapa;
  }
}