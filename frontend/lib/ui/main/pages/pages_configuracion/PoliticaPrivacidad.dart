import 'package:flutter/material.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../../controllers/main/pages_configuracion/TerminoPoliticaController.dart';

class PoliticaPrivacidad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Politica de Privacidad',
          estilo: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              TerminoPoliticaController.construirSeccion(
                'Introduccion',
                'En HouseService, tu privacidad es importante para nosotros. Esta Politica de Privacidad explica como recopilamos, usamos, divulgamos y protegemos tu informacion cuando utilizas nuestra aplicacion movil y servicios relacionados.\n\nAl usar nuestra aplicacion, aceptas las practicas descritas en esta politica. Te recomendamos que la leas detenidamente para entender nuestros procedimientos con respecto a tus datos personales.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Informacion que recopilamos',
                'Podemos recopilar varios tipos de informacion, incluyendo:\n\n'
                    '• Informacion personal: nombre, direccion de correo electronico, numero de telefono, direccion postal y detalles de pago.\n\n'
                    '• Datos de ubicacion: con tu permiso, podemos recopilar y procesar informacion sobre tu ubicacion para proporcionar servicios basados en la ubicacion.\n\n'
                    '• Informacion de uso: recopilamos datos sobre como interactuas con nuestra aplicacion, incluyendo las paginas visitadas, tiempo de uso y acciones realizadas.\n\n'
                    '• Informacion del dispositivo: tipo de dispositivo, sistema operativo, identificadores unicos y datos de la red movil.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Como usamos la informacion',
                'Utilizamos la informacion recopilada para:\n\n'
                    '• Proporcionar, mantener y mejorar nuestros servicios.\n'
                    '• Procesar transacciones y enviar avisos relacionados.\n'
                    '• Enviar actualizaciones, alertas y mensajes de soporte.\n'
                    '• Responder a comentarios y preguntas.\n'
                    '• Personalizar tu experiencia y entregar contenido adaptado a tus intereses.\n'
                    '• Analizar tendencias de uso para mejorar nuestra aplicacion.\n'
                    '• Detectar, prevenir y abordar problemas tecnicos o de seguridad.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Compartir informacion',
                'Podemos compartir tu informacion personal con:\n\n'
                    '• Proveedores de servicios que nos ayudan en nuestras operaciones comerciales.\n'
                    '• Profesionales que prestan servicios solicitados por ti.\n'
                    '• Autoridades legales cuando sea requerido por ley.\n\n'
                    'No vendemos ni alquilamos tu informacion personal a terceros para fines de marketing.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Seguridad de datos',
                'Implementamos medidas de seguridad diseñadas para proteger tu informacion personal contra acceso no autorizado, alteracion, divulgacion o destruccion. Estas medidas incluyen cifrado de datos, cortafuegos y controles de acceso a nuestros sistemas.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Tus derechos',
                'Dependiendo de tu ubicacion, puedes tener ciertos derechos respecto a tus datos personales, como:\n\n'
                    '• Acceder a tus datos personales.\n'
                    '• Corregir informacion inexacta.\n'
                    '• Eliminar tus datos.\n'
                    '• Oponerte al procesamiento de tus datos.\n'
                    '• Retirar tu consentimiento en cualquier momento.\n\n'
                    'Para ejercer estos derechos, contacta con nosotros a traves de la informacion proporcionada al final de esta politica.',
              ),
              TerminoPoliticaController.construirSeccion(
                'Cambios a esta politica',
                'Podemos actualizar nuestra Politica de Privacidad periodicamente. Te notificaremos cualquier cambio publicando la nueva Politica de Privacidad en esta pagina y actualizando la fecha de "ultima actualizacion".',
              ),
              TerminoPoliticaController.construirSeccion(
                'Contacto',
                'Si tienes preguntas sobre esta Politica de Privacidad, contactanos en:\n\n'
                    'Email: soporte@house-services.es\n'
                    'Direccion: Calle Inventada 15 Localidad Provincia',
              ),
              SizedBox(height: 20),
              Center(
                child: TextoEscalable(
                  texto: 'Ultima actualizacion: 10 de mayo de 2025',
                  estilo: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}