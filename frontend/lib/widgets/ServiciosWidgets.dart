import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ServicioContratado.dart';
import '../models/ServicioDisponible.dart';
import '../services/ImagenService.dart';
import '../utils/OperacionesServicios.dart';
import 'Componentes_reutilizables.dart';
import 'TextoEscalable.dart';
import '../utils/IconoHelper.dart';

// widgets reutilizables para servicios
class ServiciosWidgets {

  // construye tarjeta para servicios de gestion
  static Widget construirTarjetaServicioGestion({
    required BuildContext context,
    required ServicioContratado servicio,
    required Function actualizarEstado,
    required String estadoTexto,
    required Color colorEstado,
    List<Widget>? botonesAccion,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cabecera con titulo y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextoEscalable(
                    texto: servicio.nombreServicio ?? 'Servicio',
                    estilo: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEstado.withOpacity(0.2),
                    border: Border.all(color: colorEstado.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(estadoTexto, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // informacion del cliente
            TextoEscalable(
              texto: 'Cliente: ${servicio.nombreCompletoCliente}',
              estilo: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // precio y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (servicio.precioHora != null)
                  Text('${servicio.precioHora!.toStringAsFixed(2)}€/h',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFAAADFF))),
                Text('Solicitado: ${DateFormat('dd/MM/yyyy').format(servicio.fechaSolicitudSegura)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),

            // fechas adicionales para servicios en gestion
            if (servicio.fechaConfirmada != null || servicio.fechaRealizada != null) ...[
              const SizedBox(height: 8),
              _construirInformacionFechasGestion(servicio),
            ],

            // horario solicitado
            if (servicio.fechaSeleccionada.isNotEmpty || servicio.horaInicioSeleccionada.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD2D4F1).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horario solicitado:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF616281))),
                    const SizedBox(height: 6),
                    if (servicio.fechaSeleccionada.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            _formatearFecha(servicio.fechaSeleccionada),
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    if (servicio.horaInicioSeleccionada.isNotEmpty && servicio.horaFinSeleccionada.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text('${servicio.horaInicioSeleccionada} - ${servicio.horaFinSeleccionada}',
                              style: const TextStyle(fontSize: 13, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // observaciones del cliente
            if (servicio.observaciones?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Observaciones del cliente:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF616281))),
                  const SizedBox(height: 4),
                  Text(servicio.observaciones!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ],

            // botones de accion
            if (botonesAccion?.isNotEmpty ?? false) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  for (int i = 0; i < botonesAccion!.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: botonesAccion[i]),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // construye informacion de fechas para servicios en gestion
  static Widget _construirInformacionFechasGestion(ServicioContratado servicio) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (servicio.fechaConfirmada != null)
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                TextoEscalable(
                  texto: 'Confirmado: ${DateFormat('dd/MM/yyyy HH:mm').format(servicio.fechaConfirmada!)}',
                  estilo: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          if (servicio.fechaRealizada != null) ...[
            if (servicio.fechaConfirmada != null) const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.task_alt, color: Colors.blue, size: 16),
                const SizedBox(width: 8),
                TextoEscalable(
                  texto: 'Completado: ${DateFormat('dd/MM/yyyy HH:mm').format(servicio.fechaRealizada!)}',
                  estilo: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // obtiene color segun estado del servicio
  static Color obtenerColorPorEstado(String? estadoNombre) {
    switch (estadoNombre?.toLowerCase()) {
      case 'solicitado':
      case 'pendiente':
        return const Color(0xFFAAADFF);
      case 'confirmado':
        return const Color(0xFF616281);
      case 'en_progreso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'cancelado_cliente':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // construye tarjeta de servicio disponible
  static Widget construirTarjetaServicio(BuildContext context, ServicioDisponible servicio, {Function()? onTap}) {
    final Color colorServicio = servicio.obtenerColorServicio();
    final colorEtiqueta = colorServicio.withOpacity(0.2);
    final colorBorde = colorServicio.withOpacity(0.5);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vista detalle en desarrollo para: ${servicio.nombreServicio}')));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cabecera con foto y datos
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  _construirAvatarTrabajador(servicio),
                  SizedBox(width: 12),

                  // datos del trabajador
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(servicio.nombreTrabajador, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Row(
                          children: [
                            OperacionesServicios.generarEstrellas(servicio.valoracionPromedio),
                            SizedBox(width: 4),
                            Text('(${servicio.totalValoraciones})', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        Text('${servicio.precioHora.toStringAsFixed(2)}€/h',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFFAAADFF))),
                      ],
                    ),
                  ),

                  // etiqueta del tipo de servicio
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEtiqueta,
                      border: Border.all(color: colorBorde),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconoHelper.crearIcono(servicio.iconoServicio, size: 16, color: colorServicio.withOpacity(1.0)),
                        SizedBox(width: 4),
                        Text(servicio.nombreServicio, style: TextStyle(color: colorServicio.withOpacity(1.0), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // descripcion
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(servicio.descripcion ?? 'Sin descripcion', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
            ),
            SizedBox(height: 12),

            // miniaturas de imagenes
            _construirGaleriaMiniaturas(servicio.id),

            // informacion de fechas
            _construirInformacionFechas(servicio),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // construye informacion de fechas
  static Widget _construirInformacionFechas(ServicioDisponible servicio) {
    if (servicio.fechaCreacion == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text('Fecha publicacion: ${DateFormat('dd/MM/yyyy').format(servicio.fechaCreacion!)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    );
  }

  // construye avatar del trabajador
  static Widget _construirAvatarTrabajador(ServicioDisponible servicio) {
    if (servicio.urlImagenPerfilTrabajador?.isNotEmpty ?? false) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFFAAADFF),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: servicio.urlImagenPerfilTrabajador!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
            errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: ImagenService().obtenerUrlImagenPerfilPorUsuarioId(servicio.trabajadorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFAAADFF),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
          );
        }

        if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
          return CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFAAADFF),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: snapshot.data!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2.0),
                errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ),
          );
        }

        return CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFAAADFF),
          child: Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }

  // construye galeria de miniaturas
  static Widget _construirGaleriaMiniaturas(int servicioId) {
    return FutureBuilder<List<String>>(
      future: ImagenService().obtenerImagenesServicioDisponible(servicioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAAADFF)))),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 80,
            child: Center(child: Text('Error al cargar imagenes', style: TextStyle(color: Colors.red, fontSize: 12))),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final imageUrl = snapshot.data![index];
                return Padding(
                  padding: EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade300,
                        child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade700), strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 20),
                            Text('Error', style: TextStyle(fontSize: 10, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Container(
          height: 80,
          child: Center(child: Text('Sin imagenes', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontStyle: FontStyle.italic))),
        );
      },
    );
  }

  // construye galeria para pantallas de detalle
  static Widget construirGaleriaDetalle(int servicioId) {
    return FutureBuilder<List<String>>(
      future: ImagenService().obtenerImagenesServicioDisponible(servicioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAAADFF)))),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text('Error al cargar imagenes', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final imagenes = snapshot.data!;
          return Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => mostrarGaleriaCompleta(context, imagenes, index),
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imagenes[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade700))),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(height: 4),
                              Text('Error', style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text('Sin imagenes disponibles', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  // muestra galeria completa en pantalla
  static void mostrarGaleriaCompleta(BuildContext context, List<String> imagenes, int indiceInicial) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black87,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: indiceInicial),
              itemCount: imagenes.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: CachedNetworkImage(
                      imageUrl: imagenes[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 48),
                            SizedBox(height: 8),
                            Text('Error al cargar imagen', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                style: IconButton.styleFrom(backgroundColor: Colors.black54, padding: EdgeInsets.all(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // construye vista vacia
  static Widget construirVistaVacia({
    String? mensaje,
    String? subtitulo,
    String? mensajeError,
    IconData icono = Icons.work_off,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: Colors.grey[600]),
          SizedBox(height: 16),
          Text(mensaje ?? 'Aun no hay servicios disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(subtitulo ?? 'Pulsa el boton + para anadir un nuevo servicio',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          if (mensajeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(mensajeError, style: TextStyle(fontSize: 14, color: Colors.red), textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  // construye lista de servicios
  static Widget construirListaServicios(BuildContext context, List<ServicioDisponible> servicios,
      {Function(ServicioDisponible)? onTapServicio}) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        final servicio = servicios[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: construirTarjetaServicio(context, servicio, onTap: () => onTapServicio!(servicio)),
        );
      },
    );
  }

  // construye contenedor principal con estilo de la aplicacion
  static Widget construirContenedorPrincipal({
    required Widget child,
    Color colorFondo = const Color(0xFFAAADFF),
    Color colorContenido = const Color(0xFFD2D4F1),
    double radioBorde = 30,
  }) {
    return Container(
      color: colorFondo,
      child: Container(
        decoration: BoxDecoration(
          color: colorContenido,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radioBorde),
            topRight: Radius.circular(radioBorde),
          ),
        ),
        child: child,
      ),
    );
  }

  // crea botones para servicios pendientes
  static List<Widget> crearBotonesPendientes({
    required BuildContext context,
    required int servicioId,
    required Function(int, Function, BuildContext) confirmarServicio,
    required Function(int, Function, BuildContext) rechazarServicio,
    required Function actualizarEstado,
  }) {
    return [
      Componentes_reutilizables.construirBoton(
        texto: 'Rechazar',
        alPulsar: () => rechazarServicio(servicioId, actualizarEstado, context),
        colorFondo: Colors.red,
        colorTexto: Colors.white,
        ancho: double.infinity,
        alto: 38,
        tamanoFuente: 14,
        grosorFuente: FontWeight.w600,
      ),
      Componentes_reutilizables.construirBoton(
        texto: 'Confirmar',
        alPulsar: () => confirmarServicio(servicioId, actualizarEstado, context),
        colorFondo: const Color(0xFF616281),
        colorTexto: Colors.white,
        ancho: double.infinity,
        alto: 38,
        tamanoFuente: 14,
        grosorFuente: FontWeight.w600,
      ),
    ];
  }

  // crea botones para servicios en gestion
  static List<Widget> crearBotonesGestion({
    required BuildContext context,
    required ServicioContratado servicio,
    required Function(int, Function, BuildContext) iniciarServicio,
    required Function(int, Function, BuildContext) completarServicio,
    required Function actualizarEstado,
  }) {
    final estado = servicio.estadoNombre?.toLowerCase();

    switch (estado) {
      case 'confirmado':
        return [
          Componentes_reutilizables.construirBoton(
            texto: 'Iniciar Servicio',
            alPulsar: () => iniciarServicio(servicio.id ?? 0, actualizarEstado, context),
            colorFondo: const Color(0xFF616281),
            colorTexto: Colors.white,
            ancho: double.infinity,
            alto: 38,
            tamanoFuente: 14,
            grosorFuente: FontWeight.w600,
          ),
        ];

      case 'en_progreso':
        return [
          Componentes_reutilizables.construirBoton(
            texto: 'Marcar como Completado',
            alPulsar: () => completarServicio(servicio.id ?? 0, actualizarEstado, context),
            colorFondo: const Color(0xFF616281),
            colorTexto: Colors.white,
            ancho: double.infinity,
            alto: 38,
            tamanoFuente: 14,
            grosorFuente: FontWeight.w600,
          ),
        ];

      case 'completado':
        return [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, color: Colors.green, size: 20),
                SizedBox(width: 8),
                TextoEscalable(texto: 'COMPLETADO', estilo: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ];

      case 'rechazado':
        return [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 20),
                SizedBox(width: 8),
                TextoEscalable(texto: 'RECHAZADO', estilo: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ];
      case 'cancelado':
      case 'cancelado_cliente':
        return [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                TextoEscalable(
                  texto: 'CANCELADO POR EL CLIENTE',
                  estilo: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ];
      default:
        return [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help, color: Colors.grey[600], size: 18),
                SizedBox(width: 8),
                TextoEscalable(
                    texto: servicio.estadoNombre?.toUpperCase() ?? 'DESCONOCIDO',
                    estilo: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ];
    }
  }

  static String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // si viene algo raro, mostramos lo que haya sin romper
      return fecha;
    }
  }

}