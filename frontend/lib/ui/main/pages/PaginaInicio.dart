import 'package:flutter/material.dart';
import '../../../controllers/main/pages_inicio/InicioController.dart';
import '../../../widgets/ServiciosWidgets.dart';
import '../../../widgets/Componentes_reutilizables.dart';
import './pages_inicio/ServicioDisponibleDetalles.dart';

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({Key? key}) : super(key: key);

  @override
  _PaginaInicioState createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {
  late final InicioController _controller;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = InicioController();
    _controller.init(_actualizarEstado);
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar datos iniciales
  Future<void> _cargarDatosIniciales() async {
    await _controller.cargarServiciosPopulares();
  }

  // buscar servicios
  Future<void> _buscarServicios() async {
    final textoBusqueda = _busquedaController.text.trim();

    if (textoBusqueda.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingresa al menos 7 caracteres para buscar'), backgroundColor: Colors.red[600]));
      return;
    }

    await _controller.buscarServicios(textoBusqueda);
  }

  // limpiar busqueda
  void _limpiarBusqueda() {
    _busquedaController.clear();
    _controller.limpiarBusqueda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _construirHeaderConLogotipo(),
          _construirBarraBusqueda(),
          Expanded(
            child: ServiciosWidgets.construirContenedorPrincipal(
              child: _controller.mostrandoBusqueda ? _construirResultadosBusqueda() : _construirContenidoPrincipal(),
            ),
          ),
        ],
      ),
    );
  }

  // construye header con logotipo
  Widget _construirHeaderConLogotipo() {
    return Container(
      color: const Color(0xFFAAADFF),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        bottom: 5,
      ),
      child: Center(
        child: Image.asset('assets/logotipo.png', width: 220, height: 80, fit: BoxFit.contain),
      ),
    );
  }

  // construye barra de busqueda
  Widget _construirBarraBusqueda() {
    return Container(
      color: const Color(0xFFAAADFF),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: TextField(
                controller: _busquedaController,
                decoration: InputDecoration(
                  hintText: 'Buscar servicios o trabajadores...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _buscarServicios(),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: Color(0xFF616281), borderRadius: BorderRadius.circular(8)),
            child: IconButton(onPressed: _buscarServicios, icon: Icon(Icons.search, color: Colors.white)),
          ),
          if (_controller.mostrandoBusqueda) ...[
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(8)),
              child: IconButton(onPressed: _limpiarBusqueda, icon: Icon(Icons.clear, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  // construye contenido principal con servicios populares
  Widget _construirContenidoPrincipal() {
    return RefreshIndicator(
      onRefresh: _cargarDatosIniciales,
      child: _controller.estaCargandoPopulares
          ? Center(child: CircularProgressIndicator(color: Color(0xFF616281)))
          : _controller.serviciosPopulares.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[600]),
            SizedBox(height: 16),
            Text('No hay servicios disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('Los servicios disponibles apareceran aqui', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      )
          : ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Servicios mas populares',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          ..._controller.serviciosPopulares.map((servicio) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ServiciosWidgets.construirTarjetaServicio(
                context,
                servicio,
                onTap: () => Componentes_reutilizables.navegarConTransicion(
                  context,
                  ServicioDisponibleDetalles(servicioId: servicio.id),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // construye resultados de busqueda
  Widget _construirResultadosBusqueda() {
    if (_controller.estaCargandoBusqueda) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF616281)));
    }

    if (_controller.mensajeErrorBusqueda != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
            SizedBox(height: 16),
            Text('Error en la busqueda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text(_controller.mensajeErrorBusqueda!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (_controller.resultadosBusqueda.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            SizedBox(height: 12),
            Text('Sin resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('No se encontraron servicios', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Resultados de busqueda (${_controller.resultadosBusqueda.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        ..._controller.resultadosBusqueda.map((servicio) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ServiciosWidgets.construirTarjetaServicio(
              context,
              servicio,
              onTap: () => Componentes_reutilizables.navegarConTransicion(
                context,
                ServicioDisponibleDetalles(servicioId: servicio.id),
              ),
            ),
          );
        }).toList(),
        SizedBox(height: 20),
      ],
    );
  }
}