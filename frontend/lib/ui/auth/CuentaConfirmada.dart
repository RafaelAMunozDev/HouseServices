import 'package:flutter/material.dart';
import 'InicioSesion.dart';
import '../../widgets/Componentes_reutilizables.dart';

// pantalla que muestra confirmacion de cuenta creada correctamente
class CuentaConfirmada extends StatelessWidget {
  const CuentaConfirmada({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFAAADFF),
      body: ImagenConfirmacion(),
    );
  }
}

// widget con imagen y textos animados para confirmar la creacion
class ImagenConfirmacion extends StatefulWidget {
  const ImagenConfirmacion({super.key});

  @override
  State<ImagenConfirmacion> createState() => _ImagenConfirmacionState();
}

// controla las animaciones de confirmacion
class _ImagenConfirmacionState extends State<ImagenConfirmacion> {
  double _tamano = 100.0; // tamaño inicial del icono
  double _tamanoTexto = 14.0; // tamaño inicial del texto
  bool _verTextoYBoton = false; // controla visibilidad del texto
  bool _verBoton = false; // controla visibilidad del boton

  @override
  void initState() {
    super.initState();

    // inicia animaciones con retrasos secuenciales
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _tamano = 200.0;
        _tamanoTexto = 35.0;
        _verTextoYBoton = true;
      });

      // muestra boton al final
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _verBoton = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // texto con animacion de opacidad
          AnimatedOpacity(
            opacity: _verTextoYBoton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: TextoCuentaCreada(tamanoTexto: _tamanoTexto),
          ),
          const SizedBox(height: 0),

          // icono con animacion de tamaño
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: _tamano,
            height: _tamano,
            child: Image.asset('assets/icono_confirmacion.png'),
          ),
          const SizedBox(height: 0),

          // boton que aparece al final
          AnimatedOpacity(
            opacity: _verBoton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: const Boton(),
          ),
        ],
      ),
    );
  }
}

// boton para navegar a inicio de sesion
class Boton extends StatelessWidget {
  const Boton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // feedback visual antes de navegar
        await Future.delayed(const Duration(milliseconds: 150));

        Componentes_reutilizables.navegarConTransicion(
            context,
            const InicioSesion()
        );
      },
      // diseño del boton
      child: Container(
        width: 174,
        height: 52,
        decoration: ShapeDecoration(
          color: const Color(0xFF616281),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: const Center(
          child: Text(
            'Iniciar Sesion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// texto de confirmacion con tamaño animado
class TextoCuentaCreada extends StatelessWidget {
  final double tamanoTexto;
  const TextoCuentaCreada({super.key, required this.tamanoTexto});

  @override
  Widget build(BuildContext context) {
    return Text(
      'CUENTA CREADA CORRECTAMENTE',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFF2D307F),
        fontSize: tamanoTexto,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w700,
      ),
    );
  }
}