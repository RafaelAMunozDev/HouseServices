import 'package:flutter/material.dart';
import 'package:frontend/ui/main/PantallaHome.dart';
import '../../widgets/Componentes_reutilizables.dart';

// pantalla de explicaciones que se muestra al iniciar sesion por primera vez
class IniciarSesionExplicaciones extends StatelessWidget {
  const IniciarSesionExplicaciones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // evita retroceso durante las explicaciones
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: PresentadorPaginas(paginas: [
          // primera pagina sobre servicios disponibles
          ModeloPaginaExplicacion(
            titulo: 'Servicios disponibles a tu alcance',
            descripcion: 'Accede a profesionales para cualquier tarea para el hogar de forma rapida.',
            rutaImagen: 'assets/imagen_inicio_4.png',
            colorFondo: const Color(0xff1eb090),
          ),
          // segunda pagina sobre contacto con especialistas
          ModeloPaginaExplicacion(
            titulo: 'Contacta con especialistas',
            descripcion: 'Habla directamente con los operarios y acuerda los detalles del servicio facilmente.',
            rutaImagen: 'assets/imagen_inicio_1.png',
            colorFondo: Colors.indigo,
          ),
          // tercera pagina sobre gestion de pedidos
          ModeloPaginaExplicacion(
            titulo: 'Gestiona tus pedidos',
            descripcion: 'Consulta tus servicios contratados, revisa su estado y evalua la calidad del trabajo.',
            rutaImagen: 'assets/imagen_inicio_2.png',
            colorFondo: const Color(0xfffeae4f),
          ),
          // cuarta pagina sobre confianza en la app
          ModeloPaginaExplicacion(
            titulo: 'Confia en HouseService',
            descripcion: 'Tu plataforma segura para encontrar ayuda a domicilio cuando la necesites.',
            rutaImagen: 'assets/imagen_inicio_3.png',
            colorFondo: const Color(0xffD04F59),
          ),
        ]),
      ),
    );
  }
}

// widget para mostrar paginas de explicacion con desplazamiento horizontal
class PresentadorPaginas extends StatefulWidget {
  final List<ModeloPaginaExplicacion> paginas;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

  const PresentadorPaginas({
    Key? key,
    required this.paginas,
    this.onSkip,
    this.onFinish,
  }) : super(key: key);

  @override
  State<PresentadorPaginas> createState() => _EstadoPresentadorPaginas();
}

// controla la navegacion entre paginas de explicacion
class _EstadoPresentadorPaginas extends State<PresentadorPaginas> {
  int _paginaActual = 0;
  final PageController _controladorPagina = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.paginas[_paginaActual].colorFondo,
        child: SafeArea(
          child: Column(
            children: [
              // pageview principal con las explicaciones
              Expanded(
                child: PageView.builder(
                    controller: _controladorPagina,
                    itemCount: widget.paginas.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _paginaActual = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      final item = widget.paginas[idx];
                      final altoPantalla = MediaQuery.of(context).size.height;

                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // imagen adaptable al tamaño de pantalla
                                Image.asset(
                                  item.rutaImagen,
                                  fit: BoxFit.contain,
                                  height: altoPantalla * 0.4,
                                ),

                                const SizedBox(height: 24),

                                // titulo de la pagina
                                Text(
                                  item.titulo,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: item.colorTexto,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // descripcion explicativa
                                Text(
                                  item.descripcion,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 18,
                                    color: item.colorTexto,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                ),
              ),

              // indicadores de pagina en la parte inferior
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.paginas.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      _controladorPagina.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    // indicador animado para resaltar pagina actual
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _paginaActual == index ? 30 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                }),
              ),

              // botones de navegacion
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // boton saltar
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _controladorPagina.animateToPage(
                          widget.paginas.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        widget.onSkip?.call();
                      },
                      child: const Text("Saltar"),
                    ),

                    // boton siguiente/terminar
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (_paginaActual == widget.paginas.length - 1) {
                          // navega a pantalla principal al terminar
                          Future.delayed(const Duration(milliseconds: 150));
                          Componentes_reutilizables.navegarConTransicion(
                              context,
                              const PantallaHome()
                          );
                        } else {
                          // avanza a siguiente pagina
                          _controladorPagina.animateToPage(
                            _paginaActual + 1,
                            curve: Curves.easeInOutCubic,
                            duration: const Duration(milliseconds: 250),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _paginaActual == widget.paginas.length - 1
                                ? "Terminar"
                                : "Siguiente",
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _paginaActual == widget.paginas.length - 1
                                ? Icons.done
                                : Icons.arrow_forward,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// modelo de datos para cada pagina de explicacion
class ModeloPaginaExplicacion {
  final String titulo;
  final String descripcion;
  final String rutaImagen;
  final Color colorFondo;
  final Color colorTexto;

  ModeloPaginaExplicacion({
    required this.titulo,
    required this.descripcion,
    required this.rutaImagen,
    this.colorFondo = Colors.blue,
    this.colorTexto = Colors.white,
  });
}