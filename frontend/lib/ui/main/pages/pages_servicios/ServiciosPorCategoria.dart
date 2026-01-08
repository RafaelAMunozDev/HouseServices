import 'package:flutter/material.dart';
import '../../../../controllers/main/pages_servicios/ServiciosPorCategoriaController.dart';
import '../../../../models/Servicio.dart';
import '../../../../models/ServicioDisponible.dart';
import '../../../../utils/IconoHelper.dart';
import '../../../../widgets/ServiciosWidgets.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../pages_inicio/ServicioDisponibleDetalles.dart';


class ServiciosPorCategoria extends StatefulWidget {
  final Servicio categoria;

  const ServiciosPorCategoria({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  _ServiciosPorCategoriaState createState() => _ServiciosPorCategoriaState();
}

class _ServiciosPorCategoriaState extends State<ServiciosPorCategoria> {
  late final ServiciosPorCategoriaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiciosPorCategoriaController();
    _controller.init(_actualizarEstado);
    _cargarServicios();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Actualizar el estado de la UI
  void _actualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Cargar servicios de la categoría
  Future<void> _cargarServicios() async {
    await _controller.cargarServiciosPorCategoria(widget.categoria.id);
  }

  /// Navegar a detalles del servicio
  void _navegarADetalles(ServicioDisponible servicio) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animacion, animacionSecundaria) =>
            ServicioDisponibleDetalles(servicioId: servicio.id),
        transitionsBuilder: (context, animacion, animacionSecundaria, hijo) {
          return FadeTransition(opacity: animacion, child: hijo);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            IconoHelper.crearIcono(
              widget.categoria.iconoParaHelper,
              size: 24,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextoEscalable(
                texto: widget.categoria.nombre,
                estilo: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: _controller.estaCargando
              ? Center(child: CircularProgressIndicator(color: Color(0xFF616281)))
              : _construirContenido(),
        ),
      ),
    );
  }

  /// Construir contenido principal
  Widget _construirContenido() {
    if (_controller.mensajeError != null) {
      return _construirVistaError();
    }

    if (_controller.servicios.isEmpty) {
      return _construirVistaVacia();
    }

    return RefreshIndicator(
      onRefresh: _cargarServicios,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 24),

          // Lista de servicios
          ..._controller.servicios.map((servicio) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ServiciosWidgets.construirTarjetaServicio(
                context,
                servicio,
                onTap: () => _navegarADetalles(servicio),
              ),
            );
          }).toList(),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Construir vista de error
  Widget _construirVistaError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[600],
          ),
          SizedBox(height: 16),
          Text(
            'Error al cargar servicios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _controller.mensajeError!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir vista vacía (igual que la página de inicio)
  Widget _construirVistaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'No hay profesionales disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aún no hay profesionales en ${widget.categoria.nombre}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}