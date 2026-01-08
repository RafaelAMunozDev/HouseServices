import 'package:flutter/material.dart';
import '../../../../../controllers/main/pages_perfil/HistorialServiciosController.dart';
import '../../../../../widgets/ServiciosWidgets.dart';
import '../../../../../widgets/TextoEscalable.dart';

class HistorialServiciosContratados extends StatefulWidget {
  const HistorialServiciosContratados({Key? key}) : super(key: key);

  @override
  _HistorialServiciosContratadosState createState() => _HistorialServiciosContratadosState();
}

class _HistorialServiciosContratadosState extends State<HistorialServiciosContratados>
    with WidgetsBindingObserver {
  final HistorialServiciosController _controller = HistorialServiciosController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarHistorial();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.iniciarAutoRefresh(_actualizarEstado);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.verificarServiciosCompletadosSinValorar(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // detectar cuando la app vuelve del background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          _cargarHistorial();
          _controller.verificarServiciosCompletadosSinValorar(context);
          if (!_controller.tieneAutoRefreshActivo) {
            _controller.iniciarAutoRefresh(_actualizarEstado);
          }
        }
        break;
      case AppLifecycleState.paused:
        _controller.cancelarAutoRefresh();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar historial
  Future<void> _cargarHistorial() async {
    await _controller.cargarHistorial(_actualizarEstado);
  }

  // recargar completo
  Future<void> _recargarCompleto() async {
    setState(() {});
    await _cargarHistorial();
    if (mounted) {
      await _controller.verificarServiciosCompletadosSinValorar(context);
    }
    if (!_controller.tieneAutoRefreshActivo) {
      _controller.iniciarAutoRefresh(_actualizarEstado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Historial de Servicios',
          estilo: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _controller.estaCargando ? Colors.grey : Colors.black),
            onPressed: _controller.estaCargando ? null : _recargarCompleto,
            tooltip: 'Recargar historial',
          ),
        ],
      ),
      body: Builder(
        builder: (contextoScaffold) {
          return ServiciosWidgets.construirContenedorPrincipal(
            child: _construirContenido(contextoScaffold),
          );
        },
      ),
    );
  }

  // construye contenido principal
  Widget _construirContenido(BuildContext contextoScaffold) {
    if (_controller.estaCargando) {
      return _construirIndicadorCargaConAutoRefresh();
    }

    if (_controller.mensajeError != null) {
      return _controller.construirVistaError(_cargarHistorial, _controller.mensajeError);
    }

    if (!_controller.tieneServicios) {
      return _controller.construirVistaVacia();
    }

    return Column(
      children: [
        _construirIndicadorAutoRefresh(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _recargarCompleto,
            color: const Color(0xFF616281),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.historialServicios.length,
              itemBuilder: (context, index) {
                final servicio = _controller.historialServicios[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _controller.construirTarjetaHistorial(servicio, _actualizarEstado, contextoScaffold),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // construye indicador de carga con auto-refresh
  Widget _construirIndicadorCargaConAutoRefresh() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF616281))),
          const SizedBox(height: 16),
          TextoEscalable(texto: 'Cargando historial...', estilo: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          TextoEscalable(
            texto: 'Auto-actualizacion activada',
            estilo: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // construye indicador de auto-refresh
  Widget _construirIndicadorAutoRefresh() {
    final tieneAutoRefresh = _controller.tieneAutoRefreshActivo;

    if (!tieneAutoRefresh) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          TextoEscalable(
            texto: 'Actualizacion automatica activa',
            estilo: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          TextoEscalable(texto: 'Cada 30s', estilo: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}