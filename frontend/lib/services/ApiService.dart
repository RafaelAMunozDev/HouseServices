import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'ApiException.dart';

// servicio principal para comunicacion con el backend
class ApiService {
  // url base de la api que apunta al emulador de android
  final String urlBase = const String.fromEnvironment(
    'URL_BASE',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  // claves para almacenamiento local
  static const String _claveToken = 'auth_token';
  static const String _claveNombreUsuario = 'nombreUsuario';
  static const String _claveContrasena = 'contrasena';
  static const String _claveRecordarme = 'recordarme';

  final _almacenamientoSeguro = const FlutterSecureStorage();

  // patron singleton para una sola instancia
  static final ApiService _instancia = ApiService._interno();
  factory ApiService() => _instancia;
  ApiService._interno();

  String? _tokenEnMemoria;

  // obtiene el token actual desde firebase
  Future<String?> obtenerTokenFirebase() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      return await usuario.getIdToken();
    }
    return null;
  }

  // guarda el token en almacenamiento seguro
  Future<bool> guardarToken(String token) async {
    try {
      await _almacenamientoSeguro.write(key: _claveToken, value: token);
      return true;
    } catch (e) {
      // plan b guarda en memoria si falla almacenamiento
      _tokenEnMemoria = token;
      return false;
    }
  }

  // obtiene el token guardado
  Future<String?> obtenerTokenGuardado() async {
    try {
      String? token = await _almacenamientoSeguro.read(key: _claveToken);
      return token ?? _tokenEnMemoria;
    } catch (e) {
      return _tokenEnMemoria;
    }
  }

  // elimina el token para cerrar sesion
  Future<void> eliminarToken() async {
    try {
      await _almacenamientoSeguro.delete(key: _claveToken);
      _tokenEnMemoria = null;
    } catch (e) {
      // error silencioso
    }
  }

  // construye cabeceras para peticiones http incluyendo token
  Future<Map<String, String>> _obtenerCabeceras() async {
    String? token = await obtenerTokenGuardado();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // valida el token con el backend
  Future<bool> validarToken(String token) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$urlBase/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'token': token}),
      );

      return respuesta.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // inicia sesion y gestiona el token
  Future<Map<String, dynamic>> iniciarSesion(UserCredential credencialesUsuario) async {
    try {
      String? token = await credencialesUsuario.user?.getIdToken();

      if (token != null) {
        await guardarToken(token);
        bool esValido = await validarToken(token);

        return {
          'success': esValido,
          'token': token,
          'message': esValido ? 'Autenticación exitosa' : 'Error al validar con el backend'
        };
      }

      return {
        'success': false,
        'message': 'No se pudo obtener el token'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en la autenticación: $e'
      };
    }
  }

  // guarda credenciales para recordarme
  Future<bool> guardarCredenciales(String email, String contrasena, bool recordarme) async {
    try {
      await _almacenamientoSeguro.write(key: _claveRecordarme, value: recordarme.toString());

      if (recordarme) {
        await _almacenamientoSeguro.write(key: _claveNombreUsuario, value: email);
        await _almacenamientoSeguro.write(key: _claveContrasena, value: contrasena);
        return true;
      } else {
        await _almacenamientoSeguro.delete(key: _claveNombreUsuario);
        await _almacenamientoSeguro.delete(key: _claveContrasena);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  // obtiene credenciales guardadas
  Future<Map<String, dynamic>> obtenerCredencialesGuardadas() async {
    try {
      final recordarmeStr = await _almacenamientoSeguro.read(key: _claveRecordarme) ?? 'false';
      final recordarme = recordarmeStr.toLowerCase() == 'true';

      if (recordarme) {
        final nombreUsuario = await _almacenamientoSeguro.read(key: _claveNombreUsuario) ?? '';
        final contrasena = await _almacenamientoSeguro.read(key: _claveContrasena) ?? '';

        return {
          'nombreUsuario': nombreUsuario,
          'contrasena': contrasena,
          'recordarme': recordarme
        };
      }

      return {
        'nombreUsuario': '',
        'contrasena': '',
        'recordarme': recordarme
      };
    } catch (e) {
      return {
        'nombreUsuario': '',
        'contrasena': '',
        'recordarme': false
      };
    }
  }

  // verifica si hay credenciales guardadas
  Future<bool> hayCredencialesGuardadas() async {
    try {
      final recordarmeStr = await _almacenamientoSeguro.read(key: _claveRecordarme) ?? 'false';
      final recordarme = recordarmeStr.toLowerCase() == 'true';

      if (!recordarme) {
        return false;
      }

      final nombreUsuario = await _almacenamientoSeguro.read(key: _claveNombreUsuario);
      return nombreUsuario != null && nombreUsuario.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // limpia credenciales guardadas
  Future<void> limpiarCredenciales() async {
    try {
      await _almacenamientoSeguro.delete(key: _claveRecordarme);
      await _almacenamientoSeguro.delete(key: _claveNombreUsuario);
      await _almacenamientoSeguro.delete(key: _claveContrasena);
    } catch (e) {
      // error silencioso
    }
  }

  // inicia sesion con email y contrasena para recordarme
  Future<Map<String, dynamic>> iniciarSesionConCredenciales(String email, String contrasena, bool recordarme) async {
    try {
      UserCredential credencialesUsuario = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      await guardarCredenciales(email, contrasena, recordarme);
      return await iniciarSesion(credencialesUsuario);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en la autenticación: $e'
      };
    }
  }

  // peticion get generica
  Future<dynamic> get(String endpoint) async {
    try {
      final cabeceras = await _obtenerCabeceras();
      final respuesta = await http.get(
        Uri.parse('$urlBase/$endpoint'),
        headers: cabeceras,
      );

      return _procesarRespuesta(respuesta);
    } catch (e) {
      throw Exception('Error en GET request: $e');
    }
  }

  // peticion post con datos
  Future<dynamic> post(String endpoint, dynamic cuerpo) async {
    final cabeceras = await _obtenerCabeceras();

    final respuesta = await http.post(
      Uri.parse('$urlBase/$endpoint'),
      headers: cabeceras,
      body: json.encode(cuerpo),
    );

    return _procesarRespuesta(respuesta);
  }


  // peticion put para actualizaciones
  Future<dynamic> put(String endpoint, dynamic cuerpo) async {
    try {
      final cabeceras = await _obtenerCabeceras();
      final respuesta = await http.put(
        Uri.parse('$urlBase/$endpoint'),
        headers: cabeceras,
        body: json.encode(cuerpo),
      );

      // maneja error 400 para conflictos de horario
      if (respuesta.statusCode == 400 && respuesta.body.isNotEmpty) {
        try {
          final errorBody = json.decode(respuesta.body);
          if (errorBody is Map<String, dynamic>) {
            return errorBody;
          }
        } catch (e) {
          // si no se puede decodificar lanza excepcion
        }
      }

      return _procesarRespuesta(respuesta);
    } catch (e) {
      throw Exception('Error en PUT request: $e');
    }
  }

  // peticion delete para eliminar
  Future<dynamic> delete(String endpoint) async {
    try {
      final cabeceras = await _obtenerCabeceras();
      final respuesta = await http.delete(
        Uri.parse('$urlBase/$endpoint'),
        headers: cabeceras,
      );

      return _procesarRespuesta(respuesta);
    } catch (e) {
      throw Exception('Error en DELETE request: $e');
    }
  }

  // procesa la respuesta del servidor segun codigo de estado
  dynamic _procesarRespuesta(http.Response respuesta) {

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      if (respuesta.body.isEmpty) {
        return {};
      }

      String cuerpoTexto = utf8.decode(respuesta.bodyBytes).trim();

      if (cuerpoTexto == 'true') {
        return true;
      } else if (cuerpoTexto == 'false') {
        return false;
      }

      try {
        return json.decode(cuerpoTexto);
      } catch (e) {
        return cuerpoTexto;
      }
    }

    if (respuesta.statusCode == 401) {
      String mensaje = 'Sesión expirada o no autorizada';

      try {
        final data = json.decode(utf8.decode(respuesta.bodyBytes));
        if (data is Map && data['message'] != null) {
          mensaje = data['message'];
        }
      } catch (_) {}

      throw ApiException(mensaje, 401);
    }

    String mensaje = 'Error ${respuesta.statusCode}: ${respuesta.reasonPhrase}';

    try {
      final data = json.decode(utf8.decode(respuesta.bodyBytes));
      if (data is Map && data['message'] != null) {
        mensaje = data['message'];
      }
    } catch (_) {}

    throw ApiException(mensaje, respuesta.statusCode);
  }

  // renueva el token si es necesario
  Future<bool> renovarToken() async {
    try {
      String? nuevoToken = await obtenerTokenFirebase();
      if (nuevoToken != null) {
        await guardarToken(nuevoToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // extrae el mensaje de error del backend
  String extraerMensajeError(dynamic error) {
    String mensaje = 'Error al procesar la solicitud.';
    String errorStr = error.toString();

    // si el error es un mapa con clave message
    if (error is Map && error.containsKey('message')) {
      return error['message'];
    }

    // si el mensaje contiene json intenta extraer el contenido
    if (errorStr.contains('{') && errorStr.contains('}')) {
      try {
        int inicio = errorStr.indexOf('{');
        int fin = errorStr.lastIndexOf('}') + 1;
        String jsonStr = errorStr.substring(inicio, fin);

        Map<String, dynamic> mapaError = json.decode(jsonStr);

        if (mapaError.containsKey('message')) {
          return mapaError['message'];
        }
      } catch (e) {
        // error silencioso
      }
    }

    // casos especificos de errores conocidos
    if (errorStr.contains('El DNI establecido ya esta registrado.')) {
      return 'El DNI establecido ya esta registrado.';
    }

    return mensaje;
  }

  // sube archivo al servidor usando multipart
  Future<dynamic> subirArchivo(String endpoint, File archivo, String campo, {Map<String, String>? campos}) async {
    try {
      final cabeceras = await _obtenerCabeceras();
      cabeceras.remove('Content-Type');

      var request = http.MultipartRequest('POST', Uri.parse('$urlBase/$endpoint'));
      request.headers.addAll(cabeceras);

      // detecta el tipo mime del archivo
      final mimeTypeData = lookupMimeType(archivo.path);

      request.files.add(await http.MultipartFile.fromPath(
        campo,
        archivo.path,
        contentType: mimeTypeData != null ?
        MediaType.parse(mimeTypeData) :
        MediaType('application', 'octet-stream'),
      ));

      // anade campos adicionales si se proporcionan
      if (campos != null) {
        request.fields.addAll(campos);
      }

      final response = await request.send();
      final respuesta = await http.Response.fromStream(response);

      return _procesarRespuesta(respuesta);
    } catch (e) {
      throw Exception('Error en la subida del archivo: $e');
    }
  }

  // peticion get con token especifico
  Future<dynamic> getConTokenEspecifico(String endpoint, String token) async {
    try {
      final cabeceras = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final respuesta = await http.get(
        Uri.parse('$urlBase/$endpoint'),
        headers: cabeceras,
      );

      return _procesarRespuesta(respuesta);
    } catch (e) {
      throw Exception('Error en GET request: $e');
    }
  }
}