import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/Dialogos.dart';
import '../../controllers/auth/CrearCuentaDireccionController.dart';
import '../../widgets/Componentes_reutilizables.dart';
import '../../utils/MapaUbicacion.dart';

// pantalla para seleccionar la ubicacion del usuario
class CrearCuentaDireccion extends StatelessWidget {
  const CrearCuentaDireccion({super.key});

  @override
  Widget build(BuildContext context) {
    // evitamos que el usuario pueda retroceder
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFAAADFF),
        body: Column(
          children: [
            const SizedBox(height: 70),

            // logotipo centrado
            SizedBox(
              width: 320,
              height: 200,
              child: Image.asset('assets/logotipo.png', fit: BoxFit.contain),
            ),

            // contenedor principal con el mapa y formularios
            Expanded(child: CuadradoMorado()),
          ],
        ),
      ),
    );
  }
}

// contenedor con el mapa y campos de ubicacion
class CuadradoMorado extends StatefulWidget {
  @override
  State<CuadradoMorado> createState() => _CuadradoMoradoState();
}

class _CuadradoMoradoState extends State<CuadradoMorado> {
  // controladores para latitud y longitud
  final TextEditingController controladorLatitud = TextEditingController();
  final TextEditingController controladorLongitud = TextEditingController();
  final CrearCuentaDireccionController _controlador = CrearCuentaDireccionController();

  GoogleMapController? _controladorMapa;
  late LatLng _ubicacion = LatLng(40.4168, -3.7038); // madrid por defecto
  bool _ubicacionConfirmada = false;

  @override
  void dispose() {
    controladorLatitud.dispose();
    controladorLongitud.dispose();
    super.dispose();
  }

  // comprueba que los campos esten llenos y la ubicacion confirmada
  bool validarCampos() {
    return controladorLatitud.text.isNotEmpty &&
        controladorLongitud.text.isNotEmpty &&
        _ubicacionConfirmada;
  }

  // actualiza la ubicacion cuando se selecciona en el mapa
  void _actualizarUbicacionDesdeMapa(LatLng latLng) {
    setState(() {
      _ubicacion = latLng;
      controladorLatitud.text = latLng.latitude.toString();
      controladorLongitud.text = latLng.longitude.toString();
      _ubicacionConfirmada = true;
    });

    // notificacion de confirmacion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ubicacion actualizada'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // obtiene la ubicacion actual del dispositivo
  Future<void> _obtenerUbicacionActual() async {
    Position? posicion = await _controlador.obtenerUbicacionActual(context);

    if (posicion != null) {
      final nuevaUbicacion = LatLng(posicion.latitude, posicion.longitude);
      setState(() {
        _ubicacion = nuevaUbicacion;
        controladorLatitud.text = posicion.latitude.toString();
        controladorLongitud.text = posicion.longitude.toString();
        _ubicacionConfirmada = true;
      });

      // mueve el mapa a la nueva ubicacion
      _controladorMapa?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: nuevaUbicacion, zoom: 15.0),
        ),
      );

      // confirmacion visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicacion obtenida y confirmada'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: ShapeDecoration(
        color: const Color(0xFFD2D4F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: [
          SizedBox(height: 25),

          // titulo principal fuera del scroll
          Componentes_reutilizables.construirEncabezado(
            titulo: 'CREAR CUENTA',
            subtitulo: null,
          ),

          SizedBox(height: 10),

          // contenido scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 30,
                ),
                child: Column(
                  children: [
                    // titulo y descripcion de la seccion
                    Container(
                      margin: EdgeInsets.only(top: 0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 280,
                            height: 28,
                            child: Text(
                              'ESTABLECE TU UBICACION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // descripcion explicativa
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Para poder contratar los servicios es necesario indicar la ubicacion donde se van a necexitar. '
                                  'Posteriormente se podra cambiar si se desea.',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: Color(0xFF49454F),
                                fontSize: 15,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    // widget del mapa interactivo
                    MapaUbicacion(
                      ubicacionInicial: _ubicacion,
                      alCambiarUbicacion: _actualizarUbicacionDesdeMapa,
                      permitirSeleccion: true,
                      onControladorCreado: (controller) {
                        _controladorMapa = controller;
                      },
                    ),

                    SizedBox(height: 10),

                    // boton para usar gps del dispositivo
                    ElevatedButton.icon(
                      onPressed: _obtenerUbicacionActual,
                      icon: Icon(Icons.my_location),
                      label: Text('Obtener ubicacion actual'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        backgroundColor: Color(0xFF616281),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // campos de coordenadas (solo lectura)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 330,
                      child: TextFormField(
                        controller: controladorLatitud,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'LATITUD',
                          prefixIcon: Icon(Icons.my_location),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF49454F)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF49454F)),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 330,
                      child: TextFormField(
                        controller: controladorLongitud,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'LONGITUD',
                          prefixIcon: Icon(Icons.my_location_outlined),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF49454F)),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF49454F)),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    SizedBox(height: 10),

                    // boton para continuar con el registro
                    Componentes_reutilizables.construirBoton(
                      texto: 'Continuar',
                      alPulsar: () async {
                        if (validarCampos()) {
                          bool exito = await _controlador.registrarUbicacion(
                              context,
                              double.parse(controladorLatitud.text),
                              double.parse(controladorLongitud.text)
                          );

                          if (exito) {
                            _controlador.navegarAPantallaConfirmacion(context);
                          }
                        } else {
                          String mensaje = 'Confirme su ubicacion con el boton de "Obtener ubicacion actual" para rellenar los campos obligatorios.';
                          Dialogos.mostrarDialogoError(context, mensaje);
                        }
                      },
                      ancho: 174,
                      alto: 52,
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}