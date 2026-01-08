import 'package:flutter/material.dart';
import 'package:frontend/ui/main/pages/pages_perfil/gestion_servicios/ServiciosOfrecidosDetalles.dart';
import '../../../../../controllers/main/pages_perfil/gestion_servicios/ServiciosOfrecidosController.dart';
import 'crud_servicios/CrearServicioOfrecido.dart';

// pestana que muestra los servicios que ofrece el trabajador
class ServiciosOfrecidos extends StatefulWidget {
  const ServiciosOfrecidos({Key? key}) : super(key: key);

  @override
  _ServiciosOfrecidosState createState() => _ServiciosOfrecidosState();
}

class _ServiciosOfrecidosState extends State<ServiciosOfrecidos> with AutomaticKeepAliveClientMixin {
  final ServiciosOfrecidosController _controller = ServiciosOfrecidosController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.cargarServiciosOfrecidos(_actualizarEstado);
    _controller.iniciarAutoRefresh(() => _controller.cargarServiciosOfrecidos(_actualizarEstado, silencioso: true));
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

    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // contenido principal con lista de servicios
          _controller.estaCargando
              ? _controller.construirIndicadorCarga()
              : !_controller.tieneServicios
              ? _controller.construirVistaVacia()
              : _controller.construirListaServicios(
            context,
                () => _controller.cargarServiciosOfrecidos(_actualizarEstado),
            _navegarACrearServicio,
            _navegarADetalles,
          ),

          // boton flotante para crear nuevo servicio
          _controller.construirBotonFlotante(_navegarACrearServicio),
        ],
      ),
    );
  }

  // navega a la pantalla para crear un nuevo servicio
  void _navegarACrearServicio() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearServicioOfrecido()),
    );

    // recarga la lista si se creo un servicio exitosamente
    if (resultado == true) {
      _controller.cargarServiciosOfrecidos(_actualizarEstado);
    }
  }

  // navega a los detalles del servicio seleccionado
  void _navegarADetalles(int servicioId) async {
    final resultado = await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animacion, animacionSecundaria) =>
            ServiciosOfrecidosDetalles(servicioId: servicioId),
        transitionsBuilder: (context, animacion, animacionSecundaria, hijo) {
          return FadeTransition(opacity: animacion, child: hijo);
        },
      ),
    );

    // recarga la lista si se modifico el servicio
    if (resultado == true) {
      _controller.cargarServiciosOfrecidos(_actualizarEstado);
    }
  }
}