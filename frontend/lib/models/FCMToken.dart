// models/FCMToken.dart
// modelo para tokens de notificaciones push
class FCMToken {
  final int? id;
  final int usuarioId;
  final String fcmToken;
  final String plataforma;
  final int activo;

  FCMToken({
    this.id,
    required this.usuarioId,
    required this.fcmToken,
    required this.plataforma,
    this.activo = 1,
  });

  factory FCMToken.fromJson(Map<String, dynamic> json) {
    return FCMToken(
      id: json['id'],
      usuarioId: json['usuario_id'],
      fcmToken: json['fcm_token'],
      plataforma: json['plataforma'],
      activo: json['activo'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'fcm_token': fcmToken,
      'plataforma': plataforma,
      'activo': activo,
    };
  }
}