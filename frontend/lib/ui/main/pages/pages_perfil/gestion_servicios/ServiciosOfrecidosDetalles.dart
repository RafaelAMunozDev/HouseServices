import 'package:flutter/material.dart';
import '../../../../../controllers/main/pages_perfil/gestion_servicios/ServiciosOfrecidosDetallesController.dart';
import '../../../../../utils/Dialogos.dart';
import '../../../../../widgets/ServiciosDetallesWidgets.dart';
import '../../../../../utils/ServiciosDetallesOperaciones.dart';
import 'crud_servicios/CrearServicioOfrecido.dart';

// pantalla de detalles de un servicio ofrecido
class ServiciosOfrecidosDetalles extends StatefulWidget {
  final int servicioId;

  const ServiciosOfrecidosDetalles({
    Key? key,
    required this.servicioId,
  }) : super(key: key);

  @override
  _ServiciosOfrecidosDetallesState createState() => _ServiciosOfrecidosDetallesState();
}

class _ServiciosOfrecidosDetallesState extends State<ServiciosOfrecidosDetalles> {
  late final ServiciosOfrecidosDetallesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiciosOfrecidosDetallesController();
    _controller.init(_actualizarEstado);
    _cargarDatos();
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

  // carga los datos completos del servicio
  Future<void> _cargarDatos() async {
    await _controller.cargarServicioDetalles(widget.servicioId);
  }

  // muestra menu con opciones para editar o eliminar
  void _mostrarMenuOpciones() {
    ServiciosDetallesOperaciones.mostrarMenuOpciones(
      context: context,
      onEditar: _editarServicio,
      onEliminar: _confirmarEliminarServicio,
    );
  }

  // pide confirmacion antes de eliminar el servicio
  void _confirmarEliminarServicio() async {
    final confirmar = await ServiciosDetallesOperaciones.mostrarConfirmacionEliminar(context);
    if (confirmar) {
      await _eliminarServicio();
    }
  }

  // elimina el servicio y vuelve a la pantalla anterior
  Future<void> _eliminarServicio() async {
    final eliminado = await _controller.eliminarServicio();

    if (eliminado) {
      ServiciosDetallesOperaciones.mostrarMensajeExito(context, 'Servicio eliminado correctamente');
      Navigator.of(context).pop(true);
    } else {
      ServiciosDetallesOperaciones.mostrarMensajeError(
          context, _controller.mensajeError ?? 'No se pudo eliminar el servicio');
    }
  }

  // navega a la pantalla de edicion del servicio
  void _editarServicio() async {
    final resultado = await ServiciosDetallesOperaciones.navegarAEdicion(
      context: context,
      servicioId: _controller.servicio!.id,
      pantalla: CrearServicioOfrecido(servicioId: _controller.servicio!.id),
    );

    if (resultado == true) {
      await _cargarDatos();
      ServiciosDetallesOperaciones.mostrarMensajeExito(context, 'Servicio actualizado correctamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.estaCargando
          ? Center(child: CirculoCargarPersonalizado())
          : _controller.servicio == null
          ? ServiciosDetallesWidgets.construirPantallaError(
        mensajeError: _controller.mensajeError,
        onVolver: () => Navigator.of(context).pop(),
      )
          : _construirContenidoPrincipal(),
    );
  }

  // construye el contenido principal con toda la informacion del servicio
  Widget _construirContenidoPrincipal() {
    final servicio = _controller.servicio!;
    final colorServicio = servicio.obtenerColorServicio();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // barra superior expandible con titulo y menu
            ServiciosDetallesWidgets.construirAppBarExpandible(
              titulo: servicio.nombreServicio,
              colorServicio: colorServicio,
              iconoServicio: servicio.iconoServicio,
              onBack: () => Navigator.of(context).pop(),
              acciones: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: _mostrarMenuOpciones,
                ),
              ],
            ),

            // contenido desplazable con toda la informacion
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // datos del proveedor del servicio
                    ServiciosDetallesWidgets.construirSeccionProveedor(servicio),
                    Divider(height: 1),

                    // descripcion detallada del servicio
                    ServiciosDetallesWidgets.construirSeccionDescripcion(_controller.obtenerDescripcionCompleta()),
                    Divider(height: 1),

                    // galeria de imagenes del servicio
                    ServiciosDetallesWidgets.construirSeccionGaleria(servicio.id),
                    Divider(height: 1),

                    // observaciones adicionales si existen
                    if (_controller.tieneObservaciones()) ...[
                      ServiciosDetallesWidgets.construirSeccionObservaciones(_controller.obtenerObservaciones())!,
                      Divider(height: 1),
                    ],

                    // banner con informacion para el usuario
                    ServiciosDetallesWidgets.construirBannerInformativo(),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),

        // barra fija en la parte inferior con el precio
        ServiciosDetallesWidgets.construirBarraInferiorSoloprecio(precio: servicio.precioHora),
      ],
    );
  }
}