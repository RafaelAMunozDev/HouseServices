import 'package:flutter/material.dart';
import '../utils/OperacionesServicios.dart';
import 'Dialogos.dart';

// operaciones para reservas de servicios
class ReservasOperaciones {

  // procesa reserva completa
  static Future<bool> procesarReserva({
    required BuildContext context,
    required Future<bool> Function() funcionReserva,
    required String nombreServicio,
  }) async {
    try {
      // muestra loading personalizado
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CirculoCargarPersonalizado()),
      );

      final exito = await funcionReserva();
      Navigator.of(context).pop();

      if (exito) {
        mostrarReservaExitosa(context, nombreServicio);
        return true;
      } else {
        mostrarErrorReserva(context, 'No se pudo completar la reserva');
        return false;
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      mostrarErrorReserva(context, e.toString());
      return false;
    }
  }

  // muestra confirmacion de reserva
  static Future<bool> mostrarConfirmacionReserva({
    required BuildContext context,
    required String nombreServicio,
    required String nombreProveedor,
    required double precio,
  }) async {
    return await OperacionesServicios.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Confirmar Reserva',
      mensaje: '¿Deseas reservar el servicio "$nombreServicio" de $nombreProveedor por ${precio.toStringAsFixed(2)}€/hora?',
      textoBoton: 'Reservar',
      colorBoton: const Color(0xFF616281),
    );
  }

  // muestra mensaje de reserva exitosa
  static void mostrarReservaExitosa(BuildContext context, String nombreServicio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Reserva de "$nombreServicio" realizada correctamente')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // muestra mensaje de error en reserva
  static void mostrarErrorReserva(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Error en la reserva: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  // valida datos para reserva
  static String? validarDatosReserva({
    DateTime? fechaSeleccionada,
    String? horaSeleccionada,
  }) {
    if (fechaSeleccionada == null) return 'Debes seleccionar una fecha';

    if (fechaSeleccionada.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return 'No puedes reservar en fechas pasadas';
    }

    if (horaSeleccionada?.isEmpty ?? true) return 'Debes seleccionar un horario';

    return null;
  }

  // calcula precio total de la reserva
  static double calcularPrecioTotal({
    required double precioHora,
    int duracionHoras = 1,
  }) {
    return precioHora * duracionHoras;
  }

  // formatea duracion de la reserva
  static String formatearDuracion(String horaInicio) {
    try {
      final partes = horaInicio.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);

      final horaFin = '${(hora + 1).toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
      return '$horaInicio - $horaFin (1h)';
    } catch (e) {
      return '$horaInicio - ? (1h)';
    }
  }
}