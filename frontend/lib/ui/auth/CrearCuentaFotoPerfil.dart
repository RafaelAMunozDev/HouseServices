import 'dart:io';
import 'package:flutter/material.dart';
import '../../controllers/auth/CrearCuentaFotoPerfilController.dart';
import '../../widgets/Componentes_reutilizables.dart';

// pantalla para añadir foto de perfil durante el registro
class CrearCuentaFotoPerfil extends StatefulWidget {
  const CrearCuentaFotoPerfil({Key? key}) : super(key: key);

  @override
  State<CrearCuentaFotoPerfil> createState() => _CrearCuentaFotoPerfilState();
}

class _CrearCuentaFotoPerfilState extends State<CrearCuentaFotoPerfil> {
  final CrearCuentaFotoPerfilController _controlador = CrearCuentaFotoPerfilController();
  File? _imagenSeleccionada;

  @override
  Widget build(BuildContext context) {
    // evitamos retroceso durante el registro
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFAAADFF),
        body: Column(
          children: [
            const SizedBox(height: 70),

            // logotipo de la aplicacion
            SizedBox(
              width: 320,
              height: 200,
              child: Image.asset('assets/logotipo.png', fit: BoxFit.contain),
            ),

            // contenedor principal
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const ShapeDecoration(
                  color: Color(0xFFD2D4F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // titulo principal
                    Componentes_reutilizables.construirEncabezado(
                      titulo: 'CREAR CUENTA',
                      subtitulo: null,
                    ),

                    const SizedBox(height: 10),

                    // contenido con scroll
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            // titulo y descripcion de la seccion
                            Container(
                              margin: const EdgeInsets.only(top: 0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    width: 280,
                                    height: 28,
                                    child: Text(
                                      'AÑADE TU FOTO DE PERFIL',
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

                                  // descripcion opcional del paso
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Text(
                                      'Añade una foto para personalizar tu perfil. Puedes omitir este paso si lo prefieres.',
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

                            const SizedBox(height: 20),

                            // visor circular para la imagen
                            GestureDetector(
                              onTap: _mostrarOpcionesImagen,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFAAADFF).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFAAADFF),
                                    width: 3,
                                  ),
                                  image: _imagenSeleccionada != null
                                      ? DecorationImage(
                                    image: FileImage(_imagenSeleccionada!),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: _imagenSeleccionada == null
                                    ? const Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Color(0xFF616281),
                                )
                                    : null,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // instrucciones para el usuario
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Toca el circulo para seleccionar o tomar una foto.',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Color(0xFF49454F),
                                  fontSize: 15,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // boton para finalizar registro
                            Componentes_reutilizables.construirBoton(
                              texto: 'Crear Cuenta',
                              alPulsar: () async {
                                if (_imagenSeleccionada != null) {
                                  bool exito = await _controlador.subirImagenPerfil(
                                    context,
                                    _imagenSeleccionada!,
                                  );

                                  if (exito) {
                                    _controlador.navegarAPantallaPrincipal(context);
                                  }
                                } else {
                                  // continua sin foto si no hay imagen
                                  _controlador.omitirFotoPerfil(context);
                                }
                              },
                              ancho: 174,
                              alto: 52,
                            ),

                            const SizedBox(height: 10),

                            // enlace para saltar este paso
                            TextButton(
                              onPressed: () {
                                _controlador.omitirFotoPerfil(context);
                              },
                              child: const Text(
                                'Omitir este paso',
                                style: TextStyle(
                                  color: Color(0xFF616281),
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // muestra opciones para seleccionar imagen (galeria, camara, eliminar)
  void _mostrarOpcionesImagen() {
    Componentes_reutilizables.mostrarMenuOpcionesImagen(
      context: context,
      onGaleria: () async {
        File? imagen = await _controlador.seleccionarImagenGaleria();
        if (imagen != null) {
          setState(() {
            _imagenSeleccionada = imagen;
          });
        }
      },
      onCamara: () async {
        File? imagen = await _controlador.tomarFoto();
        if (imagen != null) {
          setState(() {
            _imagenSeleccionada = imagen;
          });
        }
      },
      onEliminar: _imagenSeleccionada != null ? () {
        setState(() {
          _imagenSeleccionada = null;
        });
      } : null,
      mostrarEliminar: _imagenSeleccionada != null,
    );
  }
}