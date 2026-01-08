import 'package:flutter/material.dart';
import '../../controllers/auth/InicioSesionController.dart';
import '../../widgets/Componentes_reutilizables.dart';
import 'CrearCuenta.dart';

// pantalla principal para iniciar sesion
class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  _InicioSesionState createState() => _InicioSesionState();
}

// controla la logica del inicio de sesion
class _InicioSesionState extends State<InicioSesion> {
  // controladores para los campos de entrada
  final TextEditingController _controladorCorreo = TextEditingController();
  final TextEditingController _controladorContrasena = TextEditingController();

  bool _recordarme = false; // estado de la opcion recordarme
  final InicioSesionController _controlador = InicioSesionController();

  @override
  void initState() {
    super.initState();
    // carga credenciales guardadas si existen
    _controlador.aplicarCredencialesGuardadas(
      _controladorCorreo,
      _controladorContrasena,
    ).then((recordarmeActivado) {
      setState(() {
        _recordarme = recordarmeActivado;
      });
    });
  }

  @override
  void dispose() {
    // libera recursos de los controladores
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // contenedor con formulario de login
          Expanded(
            child: CuadradoMorado(
              controladorCorreo: _controladorCorreo,
              controladorContrasena: _controladorContrasena,
            ),
          ),
        ],
      ),
    );
  }
}

// contenedor con campos y opciones de autenticacion
class CuadradoMorado extends StatefulWidget {
  final TextEditingController controladorCorreo;
  final TextEditingController controladorContrasena;

  const CuadradoMorado({
    Key? key,
    required this.controladorCorreo,
    required this.controladorContrasena,
  }) : super(key: key);

  @override
  _CuadradoMoradoState createState() => _CuadradoMoradoState();
}

class _CuadradoMoradoState extends State<CuadradoMorado> {
  bool _recordarme = true;
  final InicioSesionController _controlador = InicioSesionController();
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    // carga estado previo de recordarme
    _controlador.cargarEstadoRecordarme().then((valor) {
      setState(() {
        _recordarme = valor;
      });
    });
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

          // titulo de la pantalla
          TextoInicionSesion(),

          SizedBox(height: 5),

          // contenido scrollable con campos
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
                    // campo de correo
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Componentes_reutilizables.construirCampoTexto(
                        controlador: widget.controladorCorreo,
                        etiqueta: 'CORREO ELECTRONICO',
                        icono: Icons.email,
                        tipoTeclado: TextInputType.emailAddress,
                      ),
                    ),

                    // campo de contraseña con checkbox
                    Container(
                      width: 330,
                      margin: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Componentes_reutilizables.construirCampoContrasena(
                            controlador: widget.controladorContrasena,
                            etiqueta: 'CONTRASEÑA',
                            esOculto: _ocultarContrasena,
                            cambiarVisibilidad: (valor) {
                              setState(() {
                                _ocultarContrasena = valor;
                              });
                            },
                          ),

                          // checkbox recordarme
                          Padding(
                            padding: EdgeInsets.only(top: 5, left: 0),
                            child: Transform.translate(
                              offset: Offset(-4, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _recordarme,
                                    onChanged: (bool? valor) async {
                                      setState(() {
                                        _recordarme = valor ?? false;
                                      });
                                      await _controlador.guardarEstadoRecordarme(_recordarme);
                                    },
                                    activeColor: Color(0xFF484BA1),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Text(
                                    'Recordarme',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // boton de iniciar sesion
                    Componentes_reutilizables.construirBoton(
                      texto: 'Iniciar Sesion',
                      alPulsar: () async {
                        await _controlador.iniciarSesion(
                          context,
                          widget.controladorCorreo.text,
                          widget.controladorContrasena.text,
                          _recordarme,
                        );
                      },
                      ancho: 174,
                      alto: 52,
                    ),

                    // opciones de autenticacion social
                    Componentes_reutilizables.construirTextoOpcionAutenticacion(
                      texto: 'INICIAR CON',
                      ancho: 127,
                      alto: 26,
                      margen: EdgeInsets.only(top: 30),
                    ),

                    Componentes_reutilizables.construirGrupoIconosSociales(),

                    // enlace para crear cuenta
                    Componentes_reutilizables.construirEnlaceAutenticacion(
                      textoInfo: '¿No tienes cuenta?',
                      textoEnlace: 'Registrate aqui',
                      alPulsar: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => const CrearCuenta(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
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

// titulo de la pantalla
class TextoInicionSesion extends StatelessWidget {
  const TextoInicionSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 276,
      height: 52,
      child: Text(
        'INICIO SESION',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 40,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}