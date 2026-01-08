// importaciones necesarias para construir la interfaz y registrar usuarios
import 'package:flutter/material.dart';
import 'InicioSesion.dart';
import '../../controllers/auth/CrearCuentaController.dart';
import '../../widgets/Componentes_reutilizables.dart';

// pantalla para crear una cuenta nueva
class CrearCuenta extends StatelessWidget {
  const CrearCuenta({super.key});

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

          // contenedor principal con el formulario
          Expanded(
            child: CuadradoMorado(),
          ),
        ],
      ),
    );
  }
}

// contenedor con todos los campos del formulario
class CuadradoMorado extends StatefulWidget {
  @override
  _CuadradoMoradoState createState() => _CuadradoMoradoState();
}

class _CuadradoMoradoState extends State<CuadradoMorado> {
  // controladores de los campos
  final TextEditingController dniControlador = TextEditingController();
  final TextEditingController nombreControlador = TextEditingController();
  final TextEditingController apellido1Controlador = TextEditingController();
  final TextEditingController apellido2Controlador = TextEditingController();
  final TextEditingController correoControlador = TextEditingController();
  final TextEditingController contrasenaControlador = TextEditingController();
  final TextEditingController confirmarContrasenaControlador = TextEditingController();
  final TextEditingController telefonoControlador = TextEditingController();
  final TextEditingController fechaNacimientoControlador = TextEditingController();

  final CrearCuentaController _controlador = CrearCuentaController();

  bool _ocultarContrasena = true;
  bool _ocultarConfirmarContrasena = true;

  @override
  void dispose() {
    dniControlador.dispose();
    nombreControlador.dispose();
    apellido1Controlador.dispose();
    apellido2Controlador.dispose();
    correoControlador.dispose();
    contrasenaControlador.dispose();
    confirmarContrasenaControlador.dispose();
    telefonoControlador.dispose();
    fechaNacimientoControlador.dispose();
    super.dispose();
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 25),

          // titulo de la pantalla
          TextoCrearCuenta(),

          SizedBox(height: 5),

          // formulario desplazable
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Componentes_reutilizables.construirEnlaceAutenticacion(
                      textoInfo: '¿Ya tienes cuenta?',
                      textoEnlace: 'Iniciar sesión aquí',
                      alPulsar: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 400),
                            pageBuilder: (context, animation, secondaryAnimation) => const InicioSesion(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    Componentes_reutilizables.construirTextoOpcionAutenticacion(
                      texto: 'CREAR CUENTA CON',
                    ),

                    Componentes_reutilizables.construirGrupoIconosSociales(),

                    Componentes_reutilizables.construirTextoOpcionAutenticacion(
                      texto: 'CREAR MANUALMENTE',
                    ),

                    SizedBox(height: 10),

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
                      controlador: correoControlador,
                      etiqueta: 'CORREO ELECTRÓNICO',
                      icono: Icons.email,
                      tipoTeclado: TextInputType.emailAddress,
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Componentes_reutilizables.construirCampoContrasena(
                        controlador: contrasenaControlador,
                        etiqueta: 'CONTRASEÑA',
                        esOculto: _ocultarContrasena,
                        cambiarVisibilidad: (valor) {
                          setState(() {
                            _ocultarContrasena = valor;
                          });
                        },
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Componentes_reutilizables.construirCampoContrasena(
                        controlador: confirmarContrasenaControlador,
                        etiqueta: 'CONFIRMAR CONTRASEÑA',
                        esOculto: _ocultarConfirmarContrasena,
                        cambiarVisibilidad: (valor) {
                          setState(() {
                            _ocultarConfirmarContrasena = valor;
                          });
                        },
                      ),
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

                    SizedBox(height: 10),

                    Componentes_reutilizables.construirBoton(
                      texto: 'Continuar',
                      alPulsar: () => _controlador.registrarUsuario(
                        context,
                        dniControlador.text,
                        nombreControlador.text,
                        apellido1Controlador.text,
                        apellido2Controlador.text,
                        correoControlador.text,
                        contrasenaControlador.text,
                        confirmarContrasenaControlador.text,
                        telefonoControlador.text,
                        fechaNacimientoControlador.text,
                      ),
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

// titulo principal de la pantalla
class TextoCrearCuenta extends StatelessWidget {
  const TextoCrearCuenta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 276,
      height: 52,
      child: Text(
        'CREAR CUENTA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 37,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}