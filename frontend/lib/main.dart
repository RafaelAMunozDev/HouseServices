import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/ProveedorTamanoTexto.dart';
import 'ui/auth/InicioSesion.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'widgets/Componentes_reutilizables.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  _configurarFirebaseMessaging();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProveedorTamanoTexto(),
      child: const MyApp(),
    ),
  );
}

void _configurarFirebaseMessaging() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// widget principal de la aplicacion
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const ImagenLogotipo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// widget del logotipo con animaciones
class ImagenLogotipo extends StatefulWidget {
  const ImagenLogotipo({super.key});

  @override
  State<ImagenLogotipo> createState() => _ImagenLogotipoState();
}

// maneja las animaciones de la imagen y elementos
class _ImagenLogotipoState extends State<ImagenLogotipo> {
  double _tamano = 180.0;
  Alignment _alineamiento = Alignment.center;
  bool _poderPulsar = false;
  bool _verTextoyBoton = false;

  @override
  void initState() {
    super.initState();
    // agranda el logo despues de 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _tamano = 350.0;
        _poderPulsar = true;
      });
    });
  }

  // funcion que se ejecuta al pulsar la imagen
  void _pantallaPulsada() {
    if (!_poderPulsar) return;

    setState(() {
      // mueve el logo hacia arriba
      _alineamiento = const Alignment(0, -0.3);
      _poderPulsar = false;
    });

    // muestra texto y boton despues de 1s
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _verTextoyBoton = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // obtiene tamaño de pantalla para espaciados dinamicos
    final Size tamanoPantalla = MediaQuery.of(context).size;
    final double logoPadding = tamanoPantalla.height * 0.15;

    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      body: GestureDetector(
        onTap: _pantallaPulsada,
        child: Stack(
          children: [
            // animacion de posicion y tamaño del logo
            AnimatedAlign(
              alignment: _alineamiento,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                width: _tamano,
                height: _tamano,
                child: Image.asset('assets/logotipo.png'),
              ),
            ),

            // texto y boton animados
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: logoPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // animacion del texto
                    AnimatedSlide(
                      offset: _verTextoyBoton ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _verTextoyBoton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        child: TextoElServicio(tamanoPantalla: tamanoPantalla),
                      ),
                    ),

                    SizedBox(height: tamanoPantalla.height * 0.03),

                    // animacion del boton
                    AnimatedSlide(
                      offset: _verTextoyBoton ? Offset.zero : const Offset(0, 0.5),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _verTextoyBoton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        child: const Boton(),
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
}

// widget del texto principal
class TextoElServicio extends StatelessWidget {
  final Size tamanoPantalla;

  const TextoElServicio({super.key, required this.tamanoPantalla});

  @override
  Widget build(BuildContext context) {
    // calcula tamaño del texto basado en ancho de pantalla
    final double fontSize = tamanoPantalla.width * 0.07;

    return Padding(
      padding: EdgeInsets.only(top: tamanoPantalla.height * 0.04),
      child: SizedBox(
        width: tamanoPantalla.width * 0.85,
        child: Text(
          'El servicio que necesitas, cuando lo necesitas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF484BA1),
            fontSize: fontSize,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// boton para navegar a inicio de sesion
class Boton extends StatelessWidget {
  const Boton({super.key});

  @override
  Widget build(BuildContext context) {
    // obtiene tamaño de pantalla para boton adaptable
    final Size tamanoPantalla = MediaQuery.of(context).size;
    final double buttonWidth = tamanoPantalla.width * 0.5;
    final double buttonHeight = tamanoPantalla.height * 0.075;
    final double fontSize = tamanoPantalla.width * 0.06;

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
        width: buttonWidth,
        height: buttonHeight,
        decoration: ShapeDecoration(
          color: const Color(0xFF616281),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Center(
          child: Text(
            'Comenzar',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}