// lib/models/UsuarioImagenPerfil.dart
class UsuarioImagenPerfil {
  final int? id;
  final int usuarioId;
  final String urlImagen;

  UsuarioImagenPerfil({
    this.id,
    required this.usuarioId,
    required this.urlImagen,
  });

  factory UsuarioImagenPerfil.fromJson(Map<String, dynamic> json) {
    return UsuarioImagenPerfil(
      id: json['id'],
      usuarioId: json['usuario_id'],
      urlImagen: json['url_imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapa = {
      'usuario_id': usuarioId,
      'url_imagen': urlImagen,
    };

    if (id != null) {
      mapa['id'] = id;
    }

    return mapa;
  }
}