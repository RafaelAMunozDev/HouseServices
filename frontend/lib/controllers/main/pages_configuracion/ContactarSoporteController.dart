import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactarSoporteController {
  final TextEditingController asuntoController;
  final TextEditingController mensajeController;
  final GlobalKey<FormState> formKey;
  String categoriaSeleccionada;
  final BuildContext context;

  // categorias disponibles para soporte
  static const List<String> categorias = [
    'Problema tecnico',
    'Facturacion',
    'Consulta sobre un servicio',
    'Sugerencia',
    'Incidencia',
    'Pagos y subscripciones',
    'Otro',
  ];

  // datos de contacto del soporte
  static const String emailSoporte = 'ejemplo@ejemplo.com';
  static const String telefonoSoporte = '981981981';

  ContactarSoporteController({
    required this.asuntoController,
    required this.mensajeController,
    required this.formKey,
    required this.categoriaSeleccionada,
    required this.context,
  });

  // actualiza la categoria seleccionada
  void actualizarCategoria(String? nuevaCategoria) {
    if (nuevaCategoria != null) {
      categoriaSeleccionada = nuevaCategoria;
    }
  }

  // copia el email al portapapeles
  void copiarEmail() {
    Clipboard.setData(ClipboardData(text: emailSoporte));
    _mostrarSnackBar('Email copiado al portapapeles', Colors.blue);
  }

  // copia el mensaje completo formatado
  void copiarMensajeCompleto() {
    final String asunto = '${categoriaSeleccionada}: ${asuntoController.text}';
    final String mensaje = mensajeController.text;

    final String mensajeCompleto = """
Destinatario: $emailSoporte
Asunto: $asunto

$mensaje
    """;

    Clipboard.setData(ClipboardData(text: mensajeCompleto));
    _mostrarSnackBar('Mensaje copiado al portapapeles', Colors.blue);

    // limpia los campos
    asuntoController.clear();
    mensajeController.clear();
  }

  // inicia llamada telefonica
  Future<void> llamarTelefono() async {
    final Uri telUri = Uri(scheme: 'tel', path: telefonoSoporte);

    try {
      await launchUrl(telUri);
    } catch (e) {
      _mostrarSnackBar('No se puede realizar la llamada', Colors.red);
    }
  }

  // envia mensaje por email
  Future<void> enviarMensaje() async {
    FocusScope.of(context).unfocus();

    final String asuntoFormateado = '${categoriaSeleccionada}: ${asuntoController.text}';

    // crea uri de email con codificacion correcta
    String emailUriString = 'mailto:$emailSoporte?subject=${Uri.encodeComponent(asuntoFormateado)}&body=${Uri.encodeComponent(mensajeController.text)}';
    Uri emailUri = Uri.parse(emailUriString);

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    _mostrarSnackBar('Abriendo aplicacion de correos.', Colors.green);
    asuntoController.clear();
    mensajeController.clear();
  }

  // muestra mensaje al usuario
  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }
}