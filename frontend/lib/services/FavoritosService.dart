import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/ServicioDisponible.dart';
import '../services/ApiService.dart';
import '../services/UsuarioService.dart';

// servicio para manejar favoritos con firestore
class FavoritosService {
  static final FavoritosService _instancia = FavoritosService._interno();
  factory FavoritosService() => _instancia;
  FavoritosService._interno();

  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'houseservices-db',
  );

  final ApiService _apiService = ApiService();
  final UsuarioService _usuarioService = UsuarioService();

  // agrega servicio a favoritos del usuario
  Future<void> agregarFavorito(int servicioId) async {
    try {
      final userId = await _usuarioService.obtenerIdNumericoUsuario();
      if (userId == null) throw Exception('Usuario no encontrado');

      final userIdString = userId.toString();

      await _firestore
          .collection('favoritos')
          .doc(userIdString)
          .collection('servicios')
          .doc(servicioId.toString())
          .set({'fechaCreacion': FieldValue.serverTimestamp()});

    } catch (e) {
      throw Exception('Error al agregar favorito');
    }
  }

  // quita servicio de favoritos del usuario
  Future<void> quitarFavorito(int servicioId) async {
    try {
      final userId = await _usuarioService.obtenerIdNumericoUsuario();
      if (userId == null) throw Exception('Usuario no encontrado');

      final userIdString = userId.toString();

      await _firestore
          .collection('favoritos')
          .doc(userIdString)
          .collection('servicios')
          .doc(servicioId.toString())
          .delete();

    } catch (e) {
      throw Exception('Error al quitar favorito');
    }
  }

  // verifica si un servicio es favorito del usuario
  Future<bool> esFavorito(int servicioId) async {
    try {
      final userId = await _usuarioService.obtenerIdNumericoUsuario();
      if (userId == null) return false;

      final userIdString = userId.toString();

      final doc = await _firestore
          .collection('favoritos')
          .doc(userIdString)
          .collection('servicios')
          .doc(servicioId.toString())
          .get();

      return doc.exists;

    } catch (e) {
      return false;
    }
  }

  // obtiene ids de servicios favoritos del usuario
  Future<List<int>> obtenerIdsFavoritos() async {
    try {
      final userId = await _usuarioService.obtenerIdNumericoUsuario();
      if (userId == null) return [];

      final userIdString = userId.toString();

      final snapshot = await _firestore
          .collection('favoritos')
          .doc(userIdString)
          .collection('servicios')
          .orderBy('fechaCreacion', descending: true)
          .get();

      return snapshot.docs.map((doc) => int.parse(doc.id)).toList();

    } catch (e) {
      return [];
    }
  }

  // obtiene servicios favoritos completos con datos del backend
  Future<List<ServicioDisponible>> obtenerServiciosFavoritos() async {
    try {
      // obtiene ids desde firestore
      final ids = await obtenerIdsFavoritos();

      if (ids.isEmpty) {
        return [];
      }

      // obtiene servicios completos desde el backend
      final respuesta = await _apiService.post('servicios/disponibles/favoritos', ids);

      if (respuesta == null) {
        return [];
      }

      // convierte a objetos servicioDisponible
      final servicios = (respuesta as List)
          .map((item) => ServicioDisponible.fromJson(item))
          .toList();

      return servicios;

    } catch (e) {
      throw Exception('Error al cargar favoritos');
    }
  }

  // alterna favorito agregar si no existe quitar si existe
  Future<bool> toggleFavorito(int servicioId) async {
    try {
      final esFav = await esFavorito(servicioId);

      if (esFav) {
        await quitarFavorito(servicioId);
        return false; // ya no es favorito
      } else {
        await agregarFavorito(servicioId);
        return true; // ahora es favorito
      }

    } catch (e) {
      rethrow;
    }
  }

  // obtiene cantidad de favoritos del usuario
  Future<int> obtenerCantidadFavoritos() async {
    try {
      final ids = await obtenerIdsFavoritos();
      return ids.length;
    } catch (e) {
      return 0;
    }
  }

  // limpia todos los favoritos del usuario
  Future<void> limpiarTodosFavoritos() async {
    try {
      final userId = await _usuarioService.obtenerIdNumericoUsuario();
      if (userId == null) throw Exception('Usuario no encontrado');

      final userIdString = userId.toString();

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('favoritos')
          .doc(userIdString)
          .collection('servicios')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

    } catch (e) {
      throw Exception('Error al limpiar favoritos');
    }
  }
}