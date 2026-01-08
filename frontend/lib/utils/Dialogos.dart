import 'package:flutter/material.dart';

class Dialogos {

  // muestra dialogo de error
  static void mostrarDialogoError(BuildContext contexto, String mensaje) {
    showDialog(
      context: contexto,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hubo un problema'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // muestra dialogo de carga
  static void mostrarDialogoCarga(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CirculoCargarPersonalizado(),
    );
  }

  // muestra dialogo de confirmacion
  static Future<bool> mostrarDialogoConfirmacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoAceptar = 'Aceptar',
    String textoCancelar = 'Cancelar',
    Color? colorBotonAceptar,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Container(
            width: double.maxFinite,
            child: Text(
              mensaje,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(textoCancelar),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                textoAceptar,
                style: TextStyle(color: colorBotonAceptar),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    ) ?? false;
  }

  // dialogo para solicitar contraseña
  static Future<Map<String, dynamic>> mostrarDialogoSolicitarContrasena({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoAceptar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    Color? colorBotonAceptar = Colors.red,
  }) async {
    final controladorContrasena = TextEditingController();

    bool confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                child: Text(
                  mensaje,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controladorContrasena,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(textoCancelar),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                textoAceptar,
                style: TextStyle(color: colorBotonAceptar),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    ) ?? false;

    return {
      'confirmado': confirmar,
      'contrasena': controladorContrasena.text,
    };
  }

  // dialogo para convertirse en trabajador
  static Future<bool> mostrarDialogoSolicitarRolTrabajador({
    required BuildContext context,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Convertirse en trabajador'),
          content: Container(
            width: double.maxFinite,
            child: Text(
              'No eres un usuario certificado para ser trabajador. ¿Quieres convertirte en trabajador y ofrecer tus servicios?',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No ahora'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Si, quiero'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    ) ?? false;
  }
}

// widget personalizado para dialogo de carga
class CirculoCargarPersonalizado extends StatefulWidget {
  const CirculoCargarPersonalizado({Key? key}) : super(key: key);

  @override
  State<CirculoCargarPersonalizado> createState() => _EstadoCirculoCargarPersonalizado();
}

class _EstadoCirculoCargarPersonalizado extends State<CirculoCargarPersonalizado> with SingleTickerProviderStateMixin {
  late AnimationController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controlador,
              child: Image.asset(
                'assets/logo_sin_fondo.png',
                width: 80,
                height: 80,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}