import 'package:flutter/material.dart';
import '../../../controllers/main/pages_favoritos/FavoritosController.dart';
import '../../../models/ServicioDisponible.dart';
import '../../../widgets/TextoEscalable.dart';
import '../../../widgets/ServiciosWidgets.dart';
import './pages_inicio/ServicioDisponibleDetalles.dart';

class PaginaFavoritos extends StatefulWidget {
  const PaginaFavoritos({Key? key}) : super(key: key);

  @override
  _PaginaFavoritosState createState() => _PaginaFavoritosState();
}

class _PaginaFavoritosState extends State<PaginaFavoritos> {
  late final FavoritosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritosController();
    _controller.init(_actualizarEstado);
    _cargarFavoritos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar favoritos
  Future<void> _cargarFavoritos() async {
    await _controller.cargarFavoritos();
  }

  // navegar a detalles del servicio
  void _navegarADetalles(ServicioDisponible servicio) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => ServicioDisponibleDetalles(servicioId: servicio.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) => _cargarFavoritos());
  }

  // confirmar quitar favorito
  void _confirmarQuitarFavorito(ServicioDisponible servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quitar de favoritos'),
        content: Text('¿Quitar este servicio de favoritos?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _quitarDeFavoritos(servicio);
            },
            child: Text('Quitar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // quitar servicio de favoritos
  Future<void> _quitarDeFavoritos(ServicioDisponible servicio) async {
    await _controller.quitarDeFavoritos(servicio.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Servicio eliminado de favoritos'),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Favoritos',
          estilo: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: _controller.estaCargando
              ? Center(child: CircularProgressIndicator(color: Color(0xFF616281)))
              : _construirContenido(),
        ),
      ),
    );
  }

  // construye contenido principal
  Widget _construirContenido() {
    if (_controller.mensajeError != null) {
      return _construirVistaError();
    }

    if (!_controller.tieneFavoritos) {
      return _construirVistaVacia();
    }

    return RefreshIndicator(
      onRefresh: _cargarFavoritos,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _construirSeccionInfo(),
          ..._controller.serviciosFavoritos.map((servicio) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _construirTarjetaFavorito(servicio),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // construye seccion de informacion
  Widget _construirSeccionInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.red[400], size: 24),
          SizedBox(width: 8),
          Expanded(
            child: TextoEscalable(
              texto: 'Mis servicios favoritos (${_controller.serviciosFavoritos.length})',
              estilo: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // construye tarjeta de favorito con opcion de quitar
  Widget _construirTarjetaFavorito(ServicioDisponible servicio) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ServiciosWidgets.construirTarjetaServicio(context, servicio, onTap: () => _navegarADetalles(servicio)),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: IconButton(
                onPressed: () => _confirmarQuitarFavorito(servicio),
                icon: Icon(Icons.favorite, color: Colors.red[400], size: 16),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // construye vista de error
  Widget _construirVistaError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
          SizedBox(height: 16),
          Text('Error al cargar favoritos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 8),
          Text(_controller.mensajeError!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarFavoritos,
            icon: Icon(Icons.refresh),
            label: Text('Reintentar'),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF616281), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // construye vista vacia
  Widget _construirVistaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text('No tienes favoritos todavia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          SizedBox(height: 8),
          Text('Guarda tus servicios favoritos aqui', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}