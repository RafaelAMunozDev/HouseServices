import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../widgets/TextoEscalable.dart';
import '../../../../../providers/ProveedorTamanoTexto.dart';
import 'ServiciosOfrecidos.dart';
import 'ServiciosPendientes.dart';
import 'ServiciosEnGestion.dart';

// pantalla principal para gestionar servicios ofrecidos
class GestionServicios extends StatefulWidget {
  final int pestanaInicial;

  const GestionServicios({
    Key? key,
    this.pestanaInicial = 0, // 0 = pendientes, 1 = en gestion
  }) : super(key: key);

  @override
  State<GestionServicios> createState() => _GestionServiciosState();
}

class _GestionServiciosState extends State<GestionServicios> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.pestanaInicial,
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proveedorTamano = Provider.of<ProveedorTamanoTexto>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      appBar: AppBar(
        title: Text(
          'Gestión de Servicios',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // contenedor principal con pestanas
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xFFD2D4F1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // titulo principal de la seccion
                  TextoEscalable(
                    texto: 'GESTIÓN DE SERVICIOS',
                    estilo: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    alineacion: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // descripcion de la funcionalidad
                  Container(
                    width: 300,
                    child: TextoEscalable(
                      texto: 'Administra tus servicios ofrecidos y gestiona las solicitudes recibidas',
                      estilo: const TextStyle(
                        color: Color(0xFF49454F),
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                      alineacion: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // barra de pestanas con estilo personalizado
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF616281),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                      indicator: BoxDecoration(
                        color: const Color(0xFF616281),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(icon: Icon(Icons.work_outline, size: 18), text: 'Ofrecidos'),
                        Tab(icon: Icon(Icons.pending_actions, size: 18), text: 'Pendientes'),
                        Tab(icon: Icon(Icons.manage_accounts, size: 18), text: 'En Gestión'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // contenido de cada pestana
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        ServiciosOfrecidos(),
                        ServiciosPendientes(),
                        ServiciosEnGestion(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}