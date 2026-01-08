import 'package:flutter/material.dart';
import '../widgets/TextoEscalable.dart';
import '../utils/Dialogos.dart';

// operaciones relacionadas con servicios
class OperacionesServicios {
  // convierte codigo de color hexadecimal a color
  static Color convertirColor(String codigoColor) {
    try {
      String codigo = codigoColor.startsWith('#') ? codigoColor : '#$codigoColor';
      String valorHex = codigo.substring(1);
      int valorColor = int.parse(valorHex, radix: 16);
      if (valorHex.length == 6) {
        valorColor = valorColor + 0xFF000000;
      }
      return Color(valorColor);
    } catch (e) {
      return const Color(0xFFAAADFF);
    }
  }

  // genera estrellas basado en valoracion
  static Widget generarEstrellas(double valoracion, {double tamanio = 18.0}) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < valoracion.floor()
              ? Icons.star
              : index < valoracion
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: tamanio,
        );
      }),
    );
  }

  // construye widget de error
  static Widget construirVistaError(String? mensajeError, Function cargarDatos) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          TextoEscalable(
            texto: 'Error al cargar servicios',
            estilo: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (mensajeError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextoEscalable(
                texto: mensajeError,
                estilo: TextStyle(fontSize: 14, color: Colors.red),
                alineacion: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => cargarDatos(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF616281),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // vista vacia para servicios pendientes
  static Widget construirVistaVaciaPendientes() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_actions, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          TextoEscalable(
            texto: 'No hay servicios pendientes',
            estilo: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextoEscalable(
            texto: 'Cuando recibas solicitudes apareceran aqui',
            estilo: TextStyle(fontSize: 16, color: Colors.grey[600]),
            alineacion: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // obtiene color por estado del servicio
  static Color obtenerColorPorEstado(String? estadoNombre) {
    switch (estadoNombre?.toLowerCase()) {
      case 'confirmado':
        return Colors.blue;
      case 'en_progreso':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'cancelado':
      case 'cancelado_cliente':
        return Colors.grey;
      case 'pendiente':
      case 'solicitado':
        return const Color(0xFFAAADFF);
      default:
        return Colors.grey;
    }
  }

  // obtiene icono por estado del servicio
  static IconData obtenerIconoPorEstado(String? estadoNombre) {
    switch (estadoNombre?.toLowerCase()) {
      case 'confirmado':
        return Icons.check_circle;
      case 'en_progreso':
        return Icons.play_circle_filled;
      case 'completado':
        return Icons.task_alt;
      case 'rechazado':
        return Icons.cancel;
      case 'cancelado':
      case 'cancelado_cliente':
        return Icons.block;
      case 'pendiente':
      case 'solicitado':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  // formatea precio con simbolo de moneda
  static String formatearPrecio(double? precio) {
    if (precio == null) return 'Precio no especificado';
    return '${precio.toStringAsFixed(2)}€/hora';
  }

  // muestra dialogo de confirmacion estilizado
  static Future<bool> mostrarDialogoConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    required String textoBoton,
    required Color colorBoton,
    String textoCancelar = 'Cancelar',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: TextoEscalable(
          texto: titulo,
          estilo: TextStyle(fontWeight: FontWeight.bold, color: colorBoton, fontSize: 18),
        ),
        content: TextoEscalable(texto: mensaje, estilo: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: TextoEscalable(
              texto: textoCancelar,
              estilo: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorBoton,
              foregroundColor: Colors.white,
            ),
            child: TextoEscalable(texto: textoBoton, estilo: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ) ?? false;
  }

  // y tambien mantener (version simplificada):
  static Widget construirVistaVaciaGestion() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_accounts, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          TextoEscalable(
            texto: 'No hay servicios en gestion',
            estilo: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextoEscalable(
            texto: 'Los servicios confirmados apareceran aqui',
            estilo: TextStyle(fontSize: 16, color: Colors.grey[600]),
            alineacion: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construir widget de indicador de carga
  static Widget construirIndicadorCarga() {
    return Center(child: CirculoCargarPersonalizado());
  }
}