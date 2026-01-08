import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/ProveedorTamanoTexto.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../widgets/Componentes_reutilizables.dart';
import '../pages/pages_configuracion/CentroAyuda.dart';
import '../pages/pages_configuracion/ContactarSoporte.dart';
import '../pages/pages_configuracion/PoliticaPrivacidad.dart';
import '../pages/pages_configuracion/TerminosServicio.dart';

class PaginaConfiguracion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Acceder al proveedor de tamaño de texto
    final proveedorTamano = Provider.of<ProveedorTamanoTexto>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Configuración',
          estilo: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              // Notificaciones - Solo las dos primeras opciones
              Componentes_reutilizables.construirSeccion('Notificaciones'),
              Componentes_reutilizables.construirElemento(
                'Notificaciones push',
                trailing: Componentes_reutilizables.crearInterruptor(
                  valor: true,
                  onChanged: (value) {
                    // Implementar la lógica para cambiar el estado de las notificaciones push
                  },
                ),
              ),
              Componentes_reutilizables.construirElemento(
                'Ofertas y promociones',
                trailing: Componentes_reutilizables.crearInterruptor(
                  valor: false,
                  onChanged: (value) {
                    // Implementar la lógica para cambiar el estado de las notificaciones de ofertas
                  },
                ),
              ),

              // Personalización - Tamaño de texto e idioma
              Componentes_reutilizables.construirSeccion('Personalización'),
              Componentes_reutilizables.construirElemento(
                'Tamaño de texto',
                trailing: DropdownButton<String>(
                  value: proveedorTamano.nombreTamano,
                  items: proveedorTamano.listaNombres
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      // Actualizar el tamaño cuando cambia la selección
                      proveedorTamano.cambiarTamano(value);
                    }
                  },
                  underline: Container(), // Sin línea bajo el dropdown
                ),
              ),
              Componentes_reutilizables.construirElemento(
                'Idioma',
                trailing: DropdownButton<String>(
                  value: 'Español',
                  items: ['Español', 'English']
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  onChanged: (value) {
                    // Aquí iría la lógica para cambiar el idioma si decides implementarla
                  },
                  underline: Container(),
                ),
              ),

              // Soporte - Navegación a páginas internas
              Componentes_reutilizables.construirSeccion('Soporte'),
              Componentes_reutilizables.construirElemento(
                'Centro de ayuda',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  // pequena espera para dar feedback visual
                  await Future.delayed(const Duration(milliseconds: 150));
                  // navegamos con animacion de transicion
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => CentroAyuda(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // se aplica una transición fade para mejor efecto visual
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              Componentes_reutilizables.construirElemento(
                'Contactar con soporte',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  // pequena espera para dar feedback visual
                  await Future.delayed(const Duration(milliseconds: 150));
                  // navegamos con animacion de transicion
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => ContactarSoporte(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // se aplica una transición fade para mejor efecto visual
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              Componentes_reutilizables.construirElemento(
                'Valorar la aplicación',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  // pequena espera para dar feedback visual
                  await Future.delayed(const Duration(milliseconds: 150));
                  // Abrir la tienda de aplicaciones para valorar
                  final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.houseservices.app');
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      print('No se pudo abrir la URL: $url');
                    }
                  } catch (e) {
                    print('Error al abrir URL: $e');
                  }
                },
              ),

              // Legal - Navegación a páginas internas
              Componentes_reutilizables.construirSeccion('Legal'),
              Componentes_reutilizables.construirElemento(
                'Política de privacidad',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  // pequena espera para dar feedback visual
                  await Future.delayed(const Duration(milliseconds: 150));
                  // navegamos con animacion de transicion
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => PoliticaPrivacidad(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // se aplica una transición fade para mejor efecto visual
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              Componentes_reutilizables.construirElemento(
                'Términos de servicio',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  // pequena espera para dar feedback visual
                  await Future.delayed(const Duration(milliseconds: 150));
                  // navegamos con animacion de transicion
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (context, animation, secondaryAnimation) => TerminosServicio(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        // se aplica una transición fade para mejor efecto visual
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),

              SizedBox(height: 30),
              Center(
                child: TextoEscalable(
                  texto: 'HouseService v1.0.0',
                  estilo: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}