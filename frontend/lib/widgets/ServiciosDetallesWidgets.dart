import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/ServicioDisponible.dart';
import '../utils/OperacionesServicios.dart';
import '../widgets/ServiciosWidgets.dart';
import '../utils/IconoHelper.dart';

// widgets reutilizables para pantallas de detalles de servicios
class ServiciosDetallesWidgets {

  // construye appbar expandible con gradiente
  static Widget construirAppBarExpandible({
    required String titulo,
    required Color colorServicio,
    required VoidCallback onBack,
    String? iconoServicio,
    List<Widget>? acciones,
  }) {
    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      backgroundColor: const Color(0xFFAAADFF),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoHelper.crearIcono(iconoServicio, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                titulo,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4.0, color: Colors.black.withOpacity(0.5), offset: Offset(0, 2))],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colorServicio, const Color(0xFFAAADFF)],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
        child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: onBack),
      ),
      actions: acciones?.map((accion) => Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
        child: accion,
      )).toList(),
    );
  }

  // construye seccion de informacion del proveedor
  static Widget construirSeccionProveedor(ServicioDisponible servicio) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _construirAvatarTrabajador(servicio),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio.nombreTrabajador, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    OperacionesServicios.generarEstrellas(servicio.valoracionPromedio),
                    SizedBox(width: 8),
                    Text('(${servicio.totalValoraciones} valoraciones)', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // construye avatar del trabajador
  static Widget _construirAvatarTrabajador(ServicioDisponible servicio) {
    if (servicio.urlImagenPerfilTrabajador?.isNotEmpty ?? false) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xFFAAADFF),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: servicio.urlImagenPerfilTrabajador!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
            errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.white, size: 36),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFFAAADFF),
      child: Icon(Icons.person, color: Colors.white, size: 36),
    );
  }

  // construye seccion de descripcion
  static Widget construirSeccionDescripcion(String descripcion) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descripcion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(descripcion, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  // construye seccion de galeria
  static Widget construirSeccionGaleria(int servicioId) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Galeria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ServiciosWidgets.construirGaleriaDetalle(servicioId),
        ],
      ),
    );
  }

  // construye seccion de observaciones
  static Widget? construirSeccionObservaciones(String? observaciones) {
    if (observaciones?.isEmpty ?? true) return null;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Observaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(observaciones!, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  // construye banner informativo para servicios propios
  static Widget construirBannerInformativo() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este servicio es proporcionado por ti. Puedes editarlo o eliminarlo usando el menu de opciones.',
              style: TextStyle(fontSize: 14, color: Colors.blue[800]),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // construye boton de mensaje para servicios de otros
  static Widget construirBotonMensaje(VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.message),
        label: Text('Enviar un mensaje'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF616281),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // construye barra inferior con precio y boton
  static Widget construirBarraInferior({
    required double precio,
    required String textoBoton,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFAAADFF),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${precio.toStringAsFixed(2)}€/h', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF616281),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(textoBoton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // construye barra inferior solo con precio
  static Widget construirBarraInferiorSoloprecio({required double precio}) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFAAADFF),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Center(
          child: Text('${precio.toStringAsFixed(2)}€/h', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ),
    );
  }

  // construye pantalla de error
  static Widget construirPantallaError({
    required String? mensajeError,
    required VoidCallback onVolver,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            SizedBox(height: 16),
            Text('No se pudo cargar el servicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(mensajeError ?? 'Servicio no encontrado o no disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]), textAlign: TextAlign.center),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onVolver,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF616281),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Volver', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}