import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../controllers/main/pages_perfil/EditarDireccionController.dart';
import '../../../../utils/Dialogos.dart';
import '../../../../widgets/Componentes_reutilizables.dart';
import '../../../../utils/MapaUbicacion.dart';
import '../../../../widgets/TextoEscalable.dart';

// pantalla para editar la direccion del usuario
class EditarDireccion extends StatefulWidget {
  const EditarDireccion({Key? key}) : super(key: key);

  @override
  _EditarDireccionState createState() => _EditarDireccionState();
}

class _EditarDireccionState extends State<EditarDireccion> {
  // controladores para los campos de coordenadas
  final TextEditingController controladorLatitud = TextEditingController();
  final TextEditingController controladorLongitud = TextEditingController();
  final EditarDireccionController _controlador = EditarDireccionController();

  GoogleMapController? _controladorMapa;
  LatLng _ubicacion = LatLng(40.4168, -3.7038); // madrid por defecto
  int? _ubicacionId;
  bool _ubicacionConfirmada = false;
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUbicacionUsuario();
  }

  // carga la ubicacion guardada del usuario
  Future<void> _cargarUbicacionUsuario() async {
    setState(() => _estaCargando = true);

    try {
      final ubicacionUsuario = await _controlador.obtenerUbicacionUsuario(context);

      if (ubicacionUsuario != null) {
        final double latitud = ubicacionUsuario.latitud ?? 0.0;
        final double longitud = ubicacionUsuario.longitud ?? 0.0;

        setState(() {
          _ubicacion = LatLng(latitud, longitud);
          _ubicacionId = ubicacionUsuario.id;
          controladorLatitud.text = latitud.toString();
          controladorLongitud.text = longitud.toString();
          _ubicacionConfirmada = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró una ubicación guardada. Por favor, establezca su ubicación.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Dialogos.mostrarDialogoError(context, 'Error al cargar la ubicación: ${e.toString()}');
    } finally {
      setState(() => _estaCargando = false);
    }
  }

  @override
  void dispose() {
    controladorLatitud.dispose();
    controladorLongitud.dispose();
    super.dispose();
  }

  // verifica que los campos necesarios esten completos
  bool validarCampos() {
    return controladorLatitud.text.isNotEmpty &&
        controladorLongitud.text.isNotEmpty &&
        _ubicacionConfirmada &&
        _ubicacionId != null;
  }

  // actualiza ubicacion cuando se selecciona en el mapa
  void _actualizarUbicacionDesdeMapa(LatLng latLng) {
    setState(() {
      _ubicacion = latLng;
      controladorLatitud.text = latLng.latitude.toString();
      controladorLongitud.text = latLng.longitude.toString();
      _ubicacionConfirmada = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ubicación actualizada'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // obtiene la posicion actual del dispositivo
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

      // mueve la camara del mapa a la nueva posicion
      _controladorMapa?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: nuevaUbicacion, zoom: 15.0),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicación obtenida y confirmada'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // guarda los cambios de ubicacion en el servidor
  Future<void> _guardarCambios() async {
    if (!validarCampos()) {
      Dialogos.mostrarDialogoError(context, 'Por favor, confirme su ubicación antes de guardar los cambios.');
      return;
    }

    try {
      final exito = await _controlador.actualizarUbicacion(
        context,
        _ubicacionId!,
        double.parse(controladorLatitud.text),
        double.parse(controladorLongitud.text),
      );

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ubicación actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      Dialogos.mostrarDialogoError(context, 'Error al actualizar la ubicación: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Editar Dirección',
          estilo: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _estaCargando
          ? Center(child: CircularProgressIndicator())
          : Componentes_reutilizables.construirContenedorPrincipal(
        contenido: _construirFormulario(),
      ),
    );
  }

  // construye el formulario con mapa y campos de ubicacion
  Widget _construirFormulario() {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // encabezado con titulo y descripcion
            Componentes_reutilizables.construirEncabezado(
              titulo: 'MI DIRECCIÓN',
              subtitulo: 'En esta ventana puedes actualizar la ubicación en la que te encuentras para ajustar donde necesitas nuestros servicios.',
              anchoTitulo: MediaQuery.of(context).size.width - 40,
              context: context,
            ),

            // componente del mapa interactivo
            MapaUbicacion(
              ubicacionInicial: _ubicacion,
              alCambiarUbicacion: _actualizarUbicacionDesdeMapa,
              permitirSeleccion: true,
              onControladorCreado: (controller) => _controladorMapa = controller,
            ),

            SizedBox(height: 15),

            // boton para obtener ubicacion actual del dispositivo
            ElevatedButton.icon(
              onPressed: _obtenerUbicacionActual,
              icon: Icon(Icons.my_location),
              label: Text('Obtener ubicación actual'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Color(0xFF616281),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            SizedBox(height: 15),

            // campos para mostrar coordenadas actuales
            _construirCampoCoordenada(controladorLatitud, 'LATITUD', Icons.my_location),
            _construirCampoCoordenada(controladorLongitud, 'LONGITUD', Icons.my_location_outlined),

            SizedBox(height: 20),

            // boton para guardar los cambios realizados
            Componentes_reutilizables.construirBoton(
              texto: 'Guardar cambios',
              alPulsar: _guardarCambios,
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // construye campo deshabilitado para mostrar coordenadas
  Widget _construirCampoCoordenada(TextEditingController controlador, String etiqueta, IconData icono) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 330,
      child: TextFormField(
        controller: controlador,
        enabled: false,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
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
    );
  }
}