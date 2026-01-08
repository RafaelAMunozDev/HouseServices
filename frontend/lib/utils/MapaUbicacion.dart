import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaUbicacion extends StatefulWidget {
  final LatLng ubicacionInicial;
  final void Function(LatLng) alCambiarUbicacion;
  final bool permitirSeleccion;
  final double altura;
  final double ancho;
  final GoogleMapController? controladorExterno;
  final void Function(GoogleMapController)? onControladorCreado;

  const MapaUbicacion({
    Key? key,
    required this.ubicacionInicial,
    required this.alCambiarUbicacion,
    this.permitirSeleccion = true,
    this.altura = 200,
    this.ancho = 330,
    this.controladorExterno,
    this.onControladorCreado,
  }) : super(key: key);

  @override
  State<MapaUbicacion> createState() => _MapaUbicacionState();
}

class _MapaUbicacionState extends State<MapaUbicacion> {
  GoogleMapController? _controladorMapa;
  late LatLng _ubicacion;

  @override
  void initState() {
    super.initState();
    _ubicacion = widget.ubicacionInicial;
  }

  @override
  void didUpdateWidget(MapaUbicacion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // actualiza ubicacion si cambio desde fuera
    if (oldWidget.ubicacionInicial != widget.ubicacionInicial) {
      setState(() {
        _ubicacion = widget.ubicacionInicial;
      });
    }
  }

  void _onMapCreated(GoogleMapController controlador) {
    _controladorMapa = controlador;

    // callback externo para el controlador
    if (widget.onControladorCreado != null) {
      widget.onControladorCreado!(controlador);
    }
  }

  void _onTap(LatLng latLng) {
    if (widget.permitirSeleccion) {
      setState(() {
        _ubicacion = latLng;
      });
      widget.alCambiarUbicacion(latLng);
    }
  }

  // mueve la camara a nueva posicion
  void moverCamara(LatLng posicion, {double zoom = 15.0}) {
    _controladorMapa?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: posicion,
          zoom: zoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.ancho,
      height: widget.altura,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF616281), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _ubicacion,
            zoom: 14.0,
          ),
          onTap: _onTap,
          markers: {
            Marker(
              markerId: MarkerId('selectedLocation'),
              position: _ubicacion,
              infoWindow: InfoWindow(
                title: 'Ubicacion seleccionada',
                snippet: '${_ubicacion.latitude}, ${_ubicacion.longitude}',
              ),
              visible: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
        ),
      ),
    );
  }
}