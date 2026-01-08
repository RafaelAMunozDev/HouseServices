import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../widgets/TextoEscalable.dart';

class TerminoPoliticaController {
  static Widget construirSeccion(String titulo, String contenido) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextoEscalable(
            texto: titulo,
            estilo: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A4B8F),
            ),
          ),
          SizedBox(height: 10),
          TextoEscalable(
            texto: contenido,
            estilo: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
            alineacion: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}