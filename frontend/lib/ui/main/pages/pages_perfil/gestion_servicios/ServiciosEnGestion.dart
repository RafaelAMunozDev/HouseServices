import 'package:flutter/material.dart';
import '../../../../../controllers/main/pages_perfil/gestion_servicios/ServiciosGestionController.dart';

// pestana para mostrar servicios que esta gestionando el trabajador
class ServiciosEnGestion extends StatefulWidget {
  const ServiciosEnGestion({Key? key}) : super(key: key);

  @override
  _ServiciosEnGestionState createState() => _ServiciosEnGestionState();
}

class _ServiciosEnGestionState extends State<ServiciosEnGestion> with AutomaticKeepAliveClientMixin {
  final ServiciosGestionController _controller = ServiciosGestionController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.cargarServiciosGestion(_actualizarEstado);
    _controller.iniciarAutoRefresh(() => _controller.cargarServiciosGestion(_actualizarEstado, silencioso: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // actualiza el estado de la interfaz
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
      return _controller.construirVistaError(() => _controller.cargarServiciosGestion(_actualizarEstado));
    }

    // muestra mensaje cuando no hay servicios
    if (!_controller.tieneServiciosGestion) {
      return _controller.construirVistaVacia();
    }

    // lista de servicios con pull to refresh
    return RefreshIndicator(
      onRefresh: () => _controller.cargarServiciosGestion(_actualizarEstado),
      color: const Color(0xFF616281),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.serviciosGestion.length,
        itemBuilder: (context, index) {
          final servicio = _controller.serviciosGestion[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _controller.construirTarjetaServicioGestion(servicio, _actualizarEstado, context),
          );
        },
      ),
    );
  }
}