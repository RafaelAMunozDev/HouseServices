// lib/widgets/texto_escalable.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ProveedorTamanoTexto.dart';

class TextoEscalable extends StatelessWidget {
  final String texto;
  final TextStyle? estilo;
  final TextAlign? alineacion;
  final int? maxLineas;
  final TextOverflow? desbordamiento;

  const TextoEscalable({
    Key? key,
    required this.texto,
    this.estilo,
    this.alineacion,
    this.maxLineas,
    this.desbordamiento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final proveedorTamano = Provider.of<ProveedorTamanoTexto>(context);

    return Text(
      texto,
      style: estilo?.copyWith(
        fontSize: (estilo?.fontSize ?? 14.0) * proveedorTamano.factorEscala,
      ),
      textAlign: alineacion,
      maxLines: maxLineas,
      overflow: desbordamiento,
    );
  }
}