import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

// importacion de paginas
import 'pages/PaginaInicio.dart';
import 'pages/PaginaServicios.dart';
import 'pages/PaginaFavoritos.dart';
import 'pages/PaginaPerfil.dart';
import 'pages/PaginaConfiguracion.dart';

// pantalla principal con navegacion inferior
class PantallaHome extends StatefulWidget {
  const PantallaHome({Key? key}) : super(key: key);

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  int _indiceSeleccionado = 0; // pagina actual seleccionada

  // lista de paginas disponibles
  final List<Widget> _paginas = [
    PaginaInicio(),
    PaginaServicios(),
    PaginaFavoritos(),
    PaginaPerfil(),
    PaginaConfiguracion(),
  ];

  // cambia la pagina al tocar un icono
  void _cambiarPagina(int indice) {
    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD2D4F1),
      body: _paginas[_indiceSeleccionado],
      bottomNavigationBar: BarraNavegacionSalomon(
        indiceSeleccionado: _indiceSeleccionado,
        alCambiar: _cambiarPagina,
      ),
    );
  }
}

// barra de navegacion inferior personalizada
class BarraNavegacionSalomon extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) alCambiar;

  const BarraNavegacionSalomon({
    Key? key,
    required this.indiceSeleccionado,
    required this.alCambiar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFAAADFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: SalomonBottomBar(
        currentIndex: indiceSeleccionado,
        onTap: alCambiar,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,

        // ajusta padding segun tamaño de pantalla
        itemPadding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: screenWidth < 380 ? 6.0 : (screenWidth < 420 ? 10.0 : 16.0)
        ),

        margin: EdgeInsets.only(bottom: 8),

        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home, size: 30),
            title: Text("Inicio",
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 12 : 14,
                )
            ),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.store, size: 30),
            title: Text("Servicios",
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 12 : 14,
                )
            ),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite, size: 30),
            title: Text("Favoritos",
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 12 : 14,
                )
            ),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person, size: 30),
            title: Text("Perfil",
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 12 : 14,
                )
            ),
            selectedColor: Colors.white,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.settings, size: 30),
            title: Text("Ajustes",
                style: TextStyle(
                  fontSize: screenWidth < 380 ? 12 : 14,
                )
            ),
            selectedColor: Colors.white,
          ),
        ],
      ),
    );
  }
}