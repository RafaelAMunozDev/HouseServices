import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/main/pages/pages_perfil/EditarDireccion.dart';
import 'package:frontend/ui/main/pages/pages_perfil/EditarPerfil.dart';
import 'package:frontend/ui/main/pages/pages_perfil/HistorialServiciosContratados.dart';
import 'package:frontend/ui/main/pages/pages_perfil/gestion_servicios/GestionServicios.dart';
import 'package:frontend/ui/main/pages/pages_perfil/ValoracionesTrabajador.dart';
import 'package:provider/provider.dart';
import '../../../providers/ProveedorTamanoTexto.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../services/ImagenService.dart';
import '../../../widgets/Componentes_reutilizables.dart';
import '../../../controllers/main/pages_perfil/PerfilController.dart';

class PaginaPerfil extends StatefulWidget {
  @override
  _PaginaPerfilState createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  final PerfilController _perfilController = PerfilController();
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  // cargar datos del perfil
  Future<void> _cargarDatosPerfil() async {
    setState(() => _estaCargando = true);
    await _perfilController.cargarDatosPerfil();
    setState(() => _estaCargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final proveedorTamano = Provider.of<ProveedorTamanoTexto>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Perfil',
          estilo: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
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
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: _estaCargando
              ? Center(child: CircularProgressIndicator())
              : ListView(
            padding: EdgeInsets.all(20),
            children: [
              SizedBox(height: 20),
              Center(child: _construirAvatar()),
              SizedBox(height: 16),
              Center(
                child: TextoEscalable(
                  texto: _perfilController.nombreMostrar,
                  estilo: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: TextoEscalable(
                  texto: _perfilController.correoUsuario,
                  estilo: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 16),

              // informacion personal
              Componentes_reutilizables.construirSeccionConIcono('Informacion Personal', Icons.person),
              Componentes_reutilizables.construirElemento(
                'Editar perfil',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => Componentes_reutilizables.navegarConTransicion(context, const EditarPerfil()),
              ),
              Componentes_reutilizables.construirElemento(
                'Mi direccion',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => Componentes_reutilizables.navegarConTransicion(context, const EditarDireccion()),
              ),
              Componentes_reutilizables.construirElemento(
                'Metodos de pago',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {
                  // funcionalidad por implementar
                },
              ),

              // mis servicios
              Componentes_reutilizables.construirSeccionConIcono('Mis Servicios', Icons.home_repair_service),
              Componentes_reutilizables.construirElemento(
                'Gestion de servicios ofrecidos',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () async {
                  bool puedeAcceder = await _perfilController.comprobarYSolicitarRolTrabajador(context);
                  if (puedeAcceder) {
                    Componentes_reutilizables.navegarConTransicion(context, const GestionServicios());
                  }
                },
              ),
              Componentes_reutilizables.construirElemento(
                'Valoraciones',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => Componentes_reutilizables.navegarConTransicion(context, const ValoracionesTrabajador()),
              ),

              // servicios contratados
              Componentes_reutilizables.construirSeccionConIcono('Servicios Contratados', Icons.assignment),
              Componentes_reutilizables.construirElemento(
                'Historial de servicios',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => Componentes_reutilizables.navegarConTransicion(context, const HistorialServiciosContratados()),
              ),

              // cuenta
              Componentes_reutilizables.construirSeccionConIcono('Cuenta', Icons.account_circle),
              Componentes_reutilizables.construirElemento(
                'Cerrar sesion',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => _perfilController.cerrarSesion(context),
              ),
              Componentes_reutilizables.construirElemento(
                'Eliminar cuenta',
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => _perfilController.eliminarCuenta(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // construye avatar del usuario
  Widget _construirAvatar() {
    return FutureBuilder<String?>(
      future: ImagenService().obtenerUrlImagenPerfil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFAAADFF),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          );
        }

        if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
          return CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFAAADFF),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                errorWidget: (context, url, error) => Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
          );
        }

        return const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFAAADFF),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        );
      },
    );
  }
}