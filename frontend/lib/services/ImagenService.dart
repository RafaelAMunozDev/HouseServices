import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'ApiService.dart';
import 'UsuarioService.dart';
import '../models/UsuarioImagenPerfil.dart';

// servicio para manejo de imagenes de perfil y servicios
class ImagenService {
  static final ImagenService _instancia = ImagenService._interno();
  factory ImagenService() => _instancia;
  ImagenService._interno();

  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();

  // cache para url de imagen de perfil actual
  String? _urlImagenPerfilActual;

  // sube imagen de perfil del usuario
  Future<UsuarioImagenPerfil?> subirImagenPerfil(File imagen) async {
    try {
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // detecta tipo mime del archivo
      final mimeTypeData = lookupMimeType(imagen.path);
      final contentType = mimeTypeData != null ?
      MediaType.parse(mimeTypeData) :
      MediaType('application', 'octet-stream');

      // genera nombre unico para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imagen.path.split('.').last;
      final nombreArchivo = 'usuario_${idUsuario}_perfil_$timestamp.$extension';

      // sube archivo al servidor
      final respuesta = await _apiService.subirArchivo(
        'usuarios/imagenes/perfil/$idUsuario',
        imagen,
        'imagen',
        campos: {'nombre_archivo': nombreArchivo},
      );

      // si el servidor devuelve null o no es mapa crea objeto con valores seguros
      if (respuesta == null || respuesta is! Map<String, dynamic>) {
        return UsuarioImagenPerfil(
          id: null,
          usuarioId: idUsuario,
          urlImagen: 'URL no disponible',
        );
      }

      // intenta crear objeto con la respuesta
      try {
        return UsuarioImagenPerfil(
          id: respuesta['id'] != null ?
          (respuesta['id'] is int ? respuesta['id'] : int.tryParse(respuesta['id'].toString())) :
          null,
          usuarioId: respuesta['usuario_id'] != null ?
          (respuesta['usuario_id'] is int ? respuesta['usuario_id'] : int.parse(respuesta['usuario_id'].toString())) :
          idUsuario,
          urlImagen: respuesta['url_imagen'] ?? 'URL no disponible',
        );
      } catch (e) {
        // a pesar del error crea objeto con valores seguros
        return UsuarioImagenPerfil(
          id: null,
          usuarioId: idUsuario,
          urlImagen: respuesta['url_imagen'] ?? 'URL no disponible',
        );
      }
    } catch (e) {
      throw e;
    }
  }

  // obtiene url de imagen de perfil del usuario actual
  Future<String?> obtenerUrlImagenPerfil() async {
    // si ya tenemos la url en cache la devolvemos
    if (_urlImagenPerfilActual != null) {
      return _urlImagenPerfilActual;
    }

    try {
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return null;
      }

      final respuesta = await _apiService.get('usuarios/imagenes/perfil/$idUsuario');

      // verifica respuesta y extrae url correctamente
      if (respuesta != null && respuesta is Map<String, dynamic>) {
        if (respuesta.containsKey('urlImagen')) {
          _urlImagenPerfilActual = respuesta['urlImagen'];
          return _urlImagenPerfilActual;
        } else if (respuesta.containsKey('url_imagen')) {
          _urlImagenPerfilActual = respuesta['url_imagen'];
          return _urlImagenPerfilActual;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // elimina imagen de perfil del usuario actual
  Future<bool> eliminarImagenPerfil() async {
    try {
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        return false;
      }

      await _apiService.delete('usuarios/imagenes/perfil/$idUsuario');
      _urlImagenPerfilActual = null;

      return true;
    } catch (e) {
      return false;
    }
  }

  // limpia cache de imagen de perfil
  void limpiarCacheImagenPerfil() {
    _urlImagenPerfilActual = null;
  }

  // verifica si el usuario tiene imagen de perfil
  Future<bool> tieneImagenPerfil() async {
    final url = await obtenerUrlImagenPerfil();
    return url != null && url.isNotEmpty;
  }

  // obtiene imagenes de un servicio disponible
  Future<List<String>> obtenerImagenesServicioDisponible(int servicioDisponibleId) async {
    try {
      final respuesta = await _apiService.get('servicios-disponibles/imagenes/$servicioDisponibleId');

      if (respuesta != null && respuesta is List) {
        List<String> urls = [];

        for (var item in respuesta) {
          if (item is Map<String, dynamic>) {
            // el backend devuelve urlImagen
            String? url = item['urlImagen']?.toString();

            if (url != null && url.isNotEmpty) {
              urls.add(url);
            }
          }
        }

        return urls;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // sube imagen para un servicio disponible
  Future<bool> subirImagenServicioDisponible(File imagen, int servicioDisponibleId) async {
    try {
      final idUsuario = await _usuarioService.obtenerIdNumericoUsuario();
      if (idUsuario == null) {
        throw Exception('No se pudo obtener el ID del usuario');
      }

      // genera nombre unico para el archivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imagen.path.split('.').last;
      final nombreArchivo = 'usuario_${idUsuario}_servicio_${servicioDisponibleId}_$timestamp.$extension';

      // usa endpoint correcto igual que en postman
      final respuesta = await _apiService.subirArchivo(
        'servicios-disponibles/imagenes/$servicioDisponibleId',
        imagen,
        'imagen',
        campos: {'nombre_archivo': nombreArchivo},
      );

      // verifica respuesta exitosa
      bool exitoso = respuesta != null &&
          respuesta is Map<String, dynamic> &&
          (respuesta.containsKey('urlImagen') || respuesta.containsKey('id'));

      return exitoso;
    } catch (e) {
      return false;
    }
  }

  // elimina imagen de un servicio disponible
  Future<bool> eliminarImagenServicioDisponible(int imagenId) async {
    try {
      await _apiService.delete('servicios-disponibles/imagenes/$imagenId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // obtiene url de imagen de perfil por id de usuario especifico
  Future<String?> obtenerUrlImagenPerfilPorUsuarioId(int usuarioId) async {
    try {
      final respuesta = await _apiService.get('usuarios/imagenes/perfil/$usuarioId');

      // verifica respuesta y extrae url
      if (respuesta != null && respuesta is Map<String, dynamic>) {
        if (respuesta.containsKey('urlImagen')) {
          return respuesta['urlImagen'];
        } else if (respuesta.containsKey('url_imagen')) {
          return respuesta['url_imagen'];
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}