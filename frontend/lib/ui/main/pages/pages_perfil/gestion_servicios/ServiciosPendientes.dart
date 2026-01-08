import 'package:flutter/material.dart';
import '../../../../../controllers/main/pages_perfil/gestion_servicios/ServiciosPendientesController.dart';

// pestana que muestra servicios pendientes de confirmacion
class ServiciosPendientes extends StatefulWidget {
  const ServiciosPendientes({Key? key}) : super(key: key);

  @override
  _ServiciosPendientesState createState() => _ServiciosPendientesState();
}

class _ServiciosPendientesState extends State<ServiciosPendientes> with AutomaticKeepAliveClientMixin {
  final ServiciosPendientesController _controller = ServiciosPendientesController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.cargarServiciosPendientes(_actualizarEstado);
    _controller.iniciarAutoRefresh(() => _controller.cargarServiciosPendientes(_actualizarEstado, silencioso: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // actualiza la interfaz cuando hay cambios
  void _actualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // muestra indicador mientras cargan los datos
    if (_controller.estaCargando) {
      return _controller.construirIndicadorCarga();
    }

    // muestra error si hubo problemas al cargar
    if (_controller.mensajeError != null) {
      return _controller.construirVistaError(() => _controller.cargarServiciosPendientes(_actualizarEstado));
    }

    // muestra mensaje cuando no hay servicios pendientes
    if (!_controller.tieneServiciosPendientes) {
      return _controller.construirVistaVacia();
    }

    // lista de servicios con pull to refresh
    return RefreshIndicator(
      onRefresh: () => _controller.cargarServiciosPendientes(_actualizarEstado),
      color: const Color(0xFF616281),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.serviciosPendientes.length,
        itemBuilder: (context, index) {
          final servicio = _controller.serviciosPendientes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _controller.construirTarjetaServicioPendiente(servicio, _actualizarEstado, context),
          );
        },
      ),
    );
  }
}