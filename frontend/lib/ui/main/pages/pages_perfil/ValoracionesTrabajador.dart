import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../controllers/main/pages_perfil/ValoracionesTrabajadorController.dart';
import '../../../../../widgets/TextoEscalable.dart';
import '../../../../../services/ImagenService.dart';

class ValoracionesTrabajador extends StatefulWidget {
  const ValoracionesTrabajador({Key? key}) : super(key: key);

  @override
  _ValoracionesTrabajadorState createState() => _ValoracionesTrabajadorState();
}

class _ValoracionesTrabajadorState extends State<ValoracionesTrabajador> {
  final ValoracionesTrabajadorController _controller = ValoracionesTrabajadorController();

  @override
  void initState() {
    super.initState();
    _cargarValoraciones();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar valoraciones
  Future<void> _cargarValoraciones() async {
    await _controller.cargarValoraciones(_actualizarEstado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Mis Valoraciones',
          estilo: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: _construirContenido(),
        ),
      ),
    );
  }

  // construye contenido principal
  Widget _construirContenido() {
    if (_controller.estaCargando) {
      return _controller.construirIndicadorCarga();
    }

    if (_controller.mensajeError != null) {
      return _controller.construirVistaError(_cargarValoraciones);
    }

    if (!_controller.tieneValoraciones) {
      return _construirVistaVacia();
    }

    return RefreshIndicator(
      onRefresh: _cargarValoraciones,
      color: const Color(0xFF616281),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _construirResumenEstadisticas(),
          const SizedBox(height: 20),
          TextoEscalable(
            texto: 'Valoraciones Recibidas (${_controller.valoraciones.length})',
            estilo: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF616281)),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _controller.valoraciones.length,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _construirTarjetaValoracion(_controller.valoraciones[index]),
            ),
          ),
        ],
      ),
    );
  }

  // construye resumen de estadisticas
  Widget _construirResumenEstadisticas() {
    final estadisticas = _controller.estadisticas;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // promedio general
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoEscalable(
                    texto: '${estadisticas['promedio']}',
                    estilo: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF616281)),
                  ),
                  TextoEscalable(texto: 'de 5 estrellas', estilo: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextoEscalable(
            texto: 'Basado en ${estadisticas['total']} valoracion${estadisticas['total'] == 1 ? '' : 'es'}',
            estilo: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          // distribucion de estrellas
          if (estadisticas['total'] > 0) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            TextoEscalable(
              texto: 'Distribucion de calificaciones',
              estilo: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF616281)),
            ),
            const SizedBox(height: 12),
            ..._construirDistribucionEstrellas(estadisticas['distribucion']),
          ],
        ],
      ),
    );
  }

  // construye distribucion de estrellas
  List<Widget> _construirDistribucionEstrellas(Map<int, int> distribucion) {
    final total = distribucion.values.fold<int>(0, (sum, count) => sum + count);

    return List.generate(5, (index) {
      final estrellas = 5 - index;
      final cantidad = distribucion[estrellas] ?? 0;
      final porcentaje = total > 0 ? (cantidad / total) : 0.0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            TextoEscalable(texto: '$estrellas', estilo: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: porcentaje,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF616281), borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 30,
              child: TextoEscalable(texto: '$cantidad', estilo: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
          ],
        ),
      );
    });
  }

  // construye tarjeta de valoracion con foto del cliente
  Widget _construirTarjetaValoracion(dynamic valoracion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // encabezado con foto del cliente, nombre y estrellas
          Row(
            children: [
              _construirAvatarCliente(valoracion.clienteId),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextoEscalable(
                      texto: valoracion.nombreCompletoCliente,
                      estilo: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    TextoEscalable(texto: valoracion.fechaFormateada, estilo: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < valoracion.puntuacion ? Colors.amber : Colors.grey[300],
                    size: 18,
                  );
                }),
              ),
            ],
          ),

          // servicio
          if (valoracion.nombreServicio?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFAAADFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextoEscalable(
                texto: valoracion.nombreServicio!,
                estilo: const TextStyle(fontSize: 12, color: Color(0xFF616281), fontWeight: FontWeight.w500),
              ),
            ),
          ],

          // comentario
          if (valoracion.comentario?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextoEscalable(
                texto: _limpiarComentario(valoracion.comentario!),
                estilo: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // construye avatar del cliente
  Widget _construirAvatarCliente(int clienteId) {
    return FutureBuilder<String?>(
      future: ImagenService().obtenerUrlImagenPerfilPorUsuarioId(clienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFAAADFF),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
          );
        }

        if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
          return CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFAAADFF),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
                errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          );
        }

        return CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFAAADFF),
          child: Icon(Icons.person, color: Colors.white, size: 24),
        );
      },
    );
  }

  // limpia comentarios de comillas
  String _limpiarComentario(String comentario) {
    String comentarioLimpio = comentario.trim();

    if (comentarioLimpio.startsWith('"') && comentarioLimpio.endsWith('"')) {
      comentarioLimpio = comentarioLimpio.substring(1, comentarioLimpio.length - 1);
    }

    if (comentarioLimpio.startsWith("'") && comentarioLimpio.endsWith("'")) {
      comentarioLimpio = comentarioLimpio.substring(1, comentarioLimpio.length - 1);
    }

    return comentarioLimpio.trim();
  }

  // construye vista vacia
  Widget _construirVistaVacia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFAAADFF).withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.star_border, size: 64, color: Color(0xFF616281)),
            ),
            const SizedBox(height: 24),
            TextoEscalable(
              texto: 'Sin valoraciones aun',
              estilo: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF616281)),
            ),
            const SizedBox(height: 12),
            TextoEscalable(
              texto: 'Cuando completes servicios, los clientes podran valorar tu trabajo.',
              estilo: TextStyle(fontSize: 16, color: Colors.grey[600]),
              alineacion: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}