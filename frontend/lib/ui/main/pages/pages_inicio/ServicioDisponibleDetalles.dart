import 'package:flutter/material.dart';
import '../../../../widgets/ServiciosDetallesWidgets.dart';
import '../../../../controllers/main/pages_perfil/gestion_servicios/ServiciosOfrecidosDetallesController.dart';
import '../../../../widgets/ReservarServicioBottomSheet.dart';
import '../../../../services/FavoritosService.dart';

class ServicioDisponibleDetalles extends StatefulWidget {
  final int servicioId;

  const ServicioDisponibleDetalles({Key? key, required this.servicioId}) : super(key: key);

  @override
  _ServicioDisponibleDetallesState createState() => _ServicioDisponibleDetallesState();
}

class _ServicioDisponibleDetallesState extends State<ServicioDisponibleDetalles> {
  late final ServiciosOfrecidosDetallesController _controller;
  final FavoritosService _favoritosService = FavoritosService();

  // estado del favorito
  bool _esFavorito = false;
  bool _cargandoFavorito = false;

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

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar datos del servicio y verificar favorito
  Future<void> _cargarDatos() async {
    await _controller.cargarServicioDetalles(widget.servicioId);
    await _verificarSiEsFavorito();
  }

  // verificar si el servicio es favorito
  Future<void> _verificarSiEsFavorito() async {
    try {
      final esFav = await _favoritosService.esFavorito(widget.servicioId);
      setState(() => _esFavorito = esFav);
    } catch (e) {
      // error verificando favorito
    }
  }

  // alternar favorito
  Future<void> _toggleFavorito() async {
    if (_cargandoFavorito) return;

    setState(() => _cargandoFavorito = true);

    try {
      final nuevoEstado = await _favoritosService.toggleFavorito(widget.servicioId);

      setState(() {
        _esFavorito = nuevoEstado;
        _cargandoFavorito = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado ? 'Servicio agregado a favoritos' : 'Servicio eliminado de favoritos'),
          backgroundColor: nuevoEstado ? Colors.green[600] : Colors.orange[600],
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _cargandoFavorito = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favoritos'), backgroundColor: Colors.red[600], duration: Duration(seconds: 2)),
      );
    }
  }

  // mostrar bottom sheet de reserva
  void _mostrarBottomSheetReserva() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReservarServicioBottomSheet(servicio: _controller.servicio!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _controller.estaCargando
          ? Center(child: CircularProgressIndicator(color: Color(0xFF616281)))
          : _controller.servicio == null
          ? ServiciosDetallesWidgets.construirPantallaError(
        mensajeError: _controller.mensajeError,
        onVolver: () => Navigator.of(context).pop(),
      )
          : _construirContenidoPrincipal(),
    );
  }

  // construye contenido principal
  Widget _construirContenidoPrincipal() {
    final servicio = _controller.servicio!;
    final colorServicio = servicio.obtenerColorServicio();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // appbar expandible
            ServiciosDetallesWidgets.construirAppBarExpandible(
              titulo: servicio.nombreServicio,
              colorServicio: colorServicio,
              iconoServicio: servicio.iconoServicio,
              onBack: () => Navigator.of(context).pop(),
              acciones: [
                _construirBotonFavoritos(),
                IconButton(icon: Icon(Icons.share, color: Colors.black), onPressed: () {}),
              ],
            ),

            // contenido principal
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiciosDetallesWidgets.construirSeccionProveedor(servicio),
                    Divider(height: 1),
                    ServiciosDetallesWidgets.construirSeccionDescripcion(_controller.obtenerDescripcionCompleta()),
                    Divider(height: 1),
                    ServiciosDetallesWidgets.construirSeccionGaleria(servicio.id),
                    Divider(height: 1),

                    // observaciones si existen
                    if (_controller.tieneObservaciones()) ...[
                      ServiciosDetallesWidgets.construirSeccionObservaciones(_controller.obtenerObservaciones())!,
                      Divider(height: 1),
                    ],

                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),

        // barra inferior fija
        ServiciosDetallesWidgets.construirBarraInferior(
          precio: servicio.precioHora,
          textoBoton: 'Haz tu reserva',
          onPressed: _mostrarBottomSheetReserva,
        ),
      ],
    );
  }

  // construye boton de favoritos con estado dinamico
  Widget _construirBotonFavoritos() {
    return IconButton(
      icon: _cargandoFavorito
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
      )
          : Icon(
        _esFavorito ? Icons.favorite : Icons.favorite_border,
        color: _esFavorito ? Colors.red[400] : Colors.black,
      ),
      onPressed: _cargandoFavorito ? null : _toggleFavorito,
    );
  }
}