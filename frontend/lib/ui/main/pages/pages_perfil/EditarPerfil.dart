import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../controllers/main/pages_perfil/EditarPerfilController.dart';
import '../../../../utils/Dialogos.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../../widgets/Componentes_reutilizables.dart';

// pantalla para editar datos del perfil de usuario
class EditarPerfil extends StatefulWidget {
  const EditarPerfil({Key? key}) : super(key: key);

  @override
  _EditarPerfilState createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final EditarPerfilController _controlador = EditarPerfilController();

  // controladores para los campos del formulario
  final TextEditingController dniControlador = TextEditingController();
  final TextEditingController nombreControlador = TextEditingController();
  final TextEditingController apellido1Controlador = TextEditingController();
  final TextEditingController apellido2Controlador = TextEditingController();
  final TextEditingController telefonoControlador = TextEditingController();
  final TextEditingController fechaNacimientoControlador = TextEditingController();

  File? _nuevaImagenPerfil;
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // carga los datos del usuario actual en los campos
  Future<void> _cargarDatosUsuario() async {
    setState(() => _estaCargando = true);

    bool datosObtenidos = await _controlador.cargarDatosUsuario(
      dniControlador,
      nombreControlador,
      apellido1Controlador,
      apellido2Controlador,
      TextEditingController(),
      telefonoControlador,
      fechaNacimientoControlador,
    );

    setState(() => _estaCargando = false);

    if (!datosObtenidos && mounted) {
      Dialogos.mostrarDialogoError(context, 'No se pudieron cargar los datos del usuario');
    }
  }

  @override
  void dispose() {
    // libera memoria de los controladores
    dniControlador.dispose();
    nombreControlador.dispose();
    apellido1Controlador.dispose();
    apellido2Controlador.dispose();
    telefonoControlador.dispose();
    fechaNacimientoControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Editar Perfil',
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

  // construye el formulario principal con todos los campos
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
              titulo: 'EDITAR PERFIL',
              subtitulo: 'En esta ventana puedes actualizar tus datos personales para mantener tu perfil al día. Estos datos se utilizarán para mejorar tu experiencia con nuestros servicios.',
              anchoTitulo: MediaQuery.of(context).size.width - 40,
              context: context,
            ),

            SizedBox(height: 5),
            _construirAvatarEditable(),
            SizedBox(height: 20),

            // campos del formulario usando componentes reutilizables
            Componentes_reutilizables.construirCampoTexto(
              controlador: dniControlador,
              etiqueta: 'DNI',
              icono: Icons.badge,
            ),

            Componentes_reutilizables.construirCampoTexto(
              controlador: nombreControlador,
              etiqueta: 'NOMBRE',
              icono: Icons.person,
            ),

            Componentes_reutilizables.construirCampoTexto(
              controlador: apellido1Controlador,
              etiqueta: 'PRIMER APELLIDO',
              icono: Icons.person,
            ),

            Componentes_reutilizables.construirCampoTexto(
              controlador: apellido2Controlador,
              etiqueta: 'SEGUNDO APELLIDO',
              icono: Icons.person,
            ),

            Componentes_reutilizables.construirCampoTexto(
              controlador: telefonoControlador,
              etiqueta: 'TELÉFONO',
              icono: Icons.phone,
              tipoTeclado: TextInputType.phone,
            ),

            Componentes_reutilizables.construirCampoFecha(
              controlador: fechaNacimientoControlador,
              context: context,
              etiqueta: 'FECHA DE NACIMIENTO',
              fechaMinima: DateTime(1900),
              fechaMaxima: DateTime.now(),
            ),

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

  // maneja el guardado de cambios del perfil
  void _guardarCambios() async {
    // sube imagen si se selecciono una nueva
    if (_nuevaImagenPerfil != null) {
      bool imagenSubida = await _controlador.actualizarImagenPerfil(context, _nuevaImagenPerfil!);
      if (imagenSubida) {
        setState(() => _nuevaImagenPerfil = null);
      } else {
        return;
      }
    }

    // actualiza el resto de datos del perfil
    _controlador.actualizarPerfil(
      context,
      dniControlador.text,
      nombreControlador.text,
      apellido1Controlador.text,
      apellido2Controlador.text,
      telefonoControlador.text,
      fechaNacimientoControlador.text,
    );
  }

  // avatar editable con icono de camara
  Widget _construirAvatarEditable() {
    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: Stack(
        children: [
          // muestra imagen nueva o la actual del usuario
          _nuevaImagenPerfil != null
              ? CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(_nuevaImagenPerfil!),
          )
              : Componentes_reutilizables.construirAvatar(
            urlImagen: _controlador.urlImagenPerfilActual,
            radio: 50,
          ),

          // icono de edicion sobre el avatar
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFF616281),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // muestra menu con opciones para cambiar imagen
  void _mostrarOpcionesImagen() {
    Componentes_reutilizables.mostrarMenuOpcionesImagen(
      context: context,
      onGaleria: () async {
        File? imagen = await _controlador.seleccionarImagenGaleria();
        if (imagen != null) {
          setState(() => _nuevaImagenPerfil = imagen);
        }
      },
      onCamara: () async {
        File? imagen = await _controlador.tomarFoto();
        if (imagen != null) {
          setState(() => _nuevaImagenPerfil = imagen);
        }
      },
      onEliminar: _nuevaImagenPerfil != null ? () {
        setState(() => _nuevaImagenPerfil = null);
      } : null,
      mostrarEliminar: _nuevaImagenPerfil != null,
    );
  }
}