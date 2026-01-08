import 'package:flutter/material.dart';
import '../widgets/Componentes_reutilizables.dart';
import 'Dialogos.dart';

// operaciones para pantallas de detalles de servicios
class ServiciosDetallesOperaciones {

  // muestra menu de opciones para servicios propios
  static void mostrarMenuOpciones({
    required BuildContext context,
    required VoidCallback onEditar,
    required VoidCallback onEliminar,
  }) {
    Componentes_reutilizables.mostrarMenuOpcionesServicio(
      context: context,
      onEditar: onEditar,
      onEliminar: onEliminar,
    );
  }

  // confirma eliminacion de servicio
  static Future<bool> mostrarConfirmacionEliminar(BuildContext context) async {
    return await Dialogos.mostrarDialogoConfirmacion(
      context: context,
      titulo: 'Eliminar servicio',
      mensaje: '¿Estas seguro de que deseas eliminar este servicio? '
          'Esta accion no se puede deshacer.',
      textoAceptar: 'Eliminar',
      textoCancelar: 'Cancelar',
      colorBotonAceptar: Colors.red,
    );
  }

  // muestra snackbar de exito
  static void mostrarMensajeExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // muestra snackbar de error
  static void mostrarMensajeError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // y restaurar el parametro servicioId en navegarAEdicion
  static Future<bool?> navegarAEdicion({
    required BuildContext context,
    required int servicioId,
    required Widget pantalla,
  }) async {
    return await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
  }

  // valida descripcion del servicio
  static String validarDescripcion(String? descripcion) {
    if (descripcion?.isEmpty ?? true) return 'Sin descripcion disponible.';
    return descripcion!;
  }

  // genera mensaje de error personalizado
  static String generarMensajeError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network')) return 'Error de conexion. Verifica tu internet.';
    if (errorStr.contains('404')) return 'Servicio no encontrado.';
    if (errorStr.contains('unauthorized')) return 'No tienes permisos para ver este servicio.';

    return 'Error inesperado. Intentalo de nuevo.';
  }

}