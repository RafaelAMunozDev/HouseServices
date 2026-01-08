import 'package:flutter/material.dart';
import '../../../../widgets/TextoEscalable.dart';

class CentroAyuda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size tamanoPantalla = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Centro de Ayuda',
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
          onPressed: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            Navigator.of(context).pop();
          },
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
              _construirPreguntaFrecuente(
                '¿Como puedo contratar un servicio?',
                'Para contratar un servicio, simplemente navega a la seccion de '
                    'Servicios, selecciona el que necesitas y pulsa el boton "Haz tu reserva". '
                    'Completa los detalles requeridos y confirma tu solicitud.',
              ),
              _construirPreguntaFrecuente(
                '¿Como puedo cancelar un servicio?',
                'Puedes cancelar un servicio desde la seccion "Servicios Contratados" en tu '
                    'perfil. Selecciona el servicio que deseas cancelar y pulsa el boton '
                    '"Cancelar". Ten en cuenta que pueden aplicarse cargos por cancelacion '
                    'dependiendo de cuando se realice.',
              ),
              _construirPreguntaFrecuente(
                '¿Como funcionan los pagos?',
                'Aceptamos pagos con tarjeta de credito/debito y PayPal. Los pagos '
                    'se procesan de forma segura a traves de nuestra plataforma. Para '
                    'servicios recurrentes, puedes configurar pagos automaticos.',
              ),
              _construirPreguntaFrecuente(
                '¿Como puedo valorar un servicio?',
                'Una vez completado el servicio, recibiras una notificacion para '
                    'valorar tu experiencia. Tambien puedes hacerlo manualmente desde '
                    'la seccion "Servicios Contratados" en tu perfil.',
              ),
              _construirPreguntaFrecuente(
                '¿Los profesionales estan verificados?',
                'Si, todos los profesionales en nuestra plataforma pasan por un '
                    'proceso de verificacion de antecedentes y revision de credenciales '
                    'antes de ser aceptados.',
              ),
              _construirPreguntaFrecuente(
                '¿Que hago si tengo un problema con el servicio?',
                'Si experimentas algun problema, puedes reportarlo inmediatamente '
                    'desde la seccion "Mis Servicios". Tambien puedes contactar con nuestro '
                    'soporte desde la aplicacion o enviando un correo a ejemplo@hejemplo.com',
              ),

              SizedBox(height: tamanoPantalla.height * 0.02),

              // logotipo centrado
              Center(
                child: Container(
                  width: tamanoPantalla.width * 0.65,
                  height: tamanoPantalla.width * 0.35,
                  child: Image.asset('assets/logotipo.png'),
                ),
              ),

              SizedBox(height: tamanoPantalla.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPreguntaFrecuente(String pregunta, String respuesta) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: TextoEscalable(
          texto: pregunta,
          estilo: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              child: TextoEscalable(
                texto: respuesta,
                estilo: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
                alineacion: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}