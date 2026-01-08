import 'package:flutter/material.dart';
import '../../../controllers/main/pages_servicios/ServiciosController.dart';
import '../../../models/Servicio.dart';
import '../../../utils/IconoHelper.dart';
import '../../../widgets/TextoEscalable.dart';
import '../../../widgets/Componentes_reutilizables.dart';
import './pages_servicios/ServiciosPorCategoria.dart';

class PaginaServicios extends StatefulWidget {
  const PaginaServicios({Key? key}) : super(key: key);

  @override
  _PaginaServiciosState createState() => _PaginaServiciosState();
}

class _PaginaServiciosState extends State<PaginaServicios> {
  late final ServiciosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiciosController();
    _controller.init(_actualizarEstado);
    _cargarDatos();
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

  // cargar datos iniciales
  Future<void> _cargarDatos() async {
    await _controller.cargarServicios();
  }

  // navegar a categoria de servicios
  void _navegarACategoria(Servicio servicio) {
    Componentes_reutilizables.navegarConTransicion(
      context,
      ServiciosPorCategoria(categoria: servicio),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Servicios',
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

    if (_controller.servicios.isEmpty) {
      return _construirVistaVacia();
    }

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        SizedBox(height: 20),
        ..._controller.servicios.map((servicio) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _construirTarjetaServicio(servicio),
          );
        }).toList(),
      ],
    );
  }

  // construye tarjeta de servicio
  Widget _construirTarjetaServicio(Servicio servicio) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: ListTile(
        leading: IconoHelper.crearIcono(servicio.iconoParaHelper, size: 40, color: servicio.obtenerColor()),
        title: Text(servicio.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: servicio.descripcion?.isNotEmpty == true
            ? Text(servicio.descripcion!, textAlign: TextAlign.justify, maxLines: 4, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Icon(Icons.arrow_forward_ios),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        onTap: () => _navegarACategoria(servicio),
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
          Text('Error al cargar servicios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 8),
          Text(_controller.mensajeError!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
          Icon(Icons.work_off, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text('No hay servicios disponibles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          SizedBox(height: 8),
          Text('Los servicios disponibles apareceran aqui', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}