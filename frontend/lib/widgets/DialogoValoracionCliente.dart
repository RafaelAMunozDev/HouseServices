import 'package:flutter/material.dart';
import '../services/UsuarioService.dart';
import '../services/ValoracionesService.dart';
import '../models/ServicioContratado.dart';

class DialogoValoracionCliente extends StatefulWidget {
  final ServicioContratado servicio;
  final VoidCallback? onValoracionCreada;

  const DialogoValoracionCliente({
    Key? key,
    required this.servicio,
    this.onValoracionCreada,
  }) : super(key: key);

  @override
  _DialogoValoracionClienteState createState() => _DialogoValoracionClienteState();
}

class _DialogoValoracionClienteState extends State<DialogoValoracionCliente> {
  final ValoracionesService _valoracionesService = ValoracionesService();
  final TextEditingController _comentarioController = TextEditingController();

  int _puntuacion = 5;
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFAAADFF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: Color(0xFF616281), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '¡Servicio Completado!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF616281)),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // descripcion del servicio completado
            Text(
              'El servicio de ${widget.servicio.servicioNombre ?? widget.servicio.nombreServicio ?? "servicio"} '
                  'ha sido completado por ${widget.servicio.trabajadorNombre ?? widget.servicio.nombreTrabajador ?? "el trabajador"}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const Text('¿Como calificas el trabajo realizado?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // estrellas para puntuacion
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _puntuacion = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.star,
                        size: 32,
                        color: index < _puntuacion ? Colors.amber : Colors.grey[300],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),

            // texto descriptivo de puntuacion
            Center(
              child: Text(
                _obtenerTextosPuntuacion(_puntuacion),
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),

            // campo de comentario
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Comentario (opcional)',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF616281), width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // boton cancelar
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: Text('Ahora no', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        // boton enviar
        TextButton(
          onPressed: _enviando ? null : _enviarValoracion,
          child: _enviando
              ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF616281)),
          )
              : const Text(
            'Enviar Valoracion',
            style: TextStyle(color: Color(0xFF616281), fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // obtiene texto descriptivo segun puntuacion
  String _obtenerTextosPuntuacion(int puntuacion) {
    switch (puntuacion) {
      case 1: return 'Muy mal trabajo';
      case 2: return 'Trabajo deficiente';
      case 3: return 'Trabajo regular';
      case 4: return 'Buen trabajo';
      case 5: return 'Excelente trabajo';
      default: return '';
    }
  }

  // envia valoracion al servidor
  Future<void> _enviarValoracion() async {
    setState(() => _enviando = true);

    try {
      // obtener cliente actual
      final usuarioService = UsuarioService();
      final usuario = await usuarioService.obtenerUsuarioActual();

      final clienteId = int.parse(usuario!.id!);

      // crear valoracion
      final valoracion = await _valoracionesService.crearValoracion(
        clienteId: clienteId,
        trabajadorId: widget.servicio.trabajadorId!,
        servicioContratadoId: widget.servicio.id!,
        puntuacion: _puntuacion,
        comentario: _comentarioController.text.trim().isEmpty ? null : _comentarioController.text.trim(),
      );

      if (valoracion != null) {
        // valoracion creada exitosamente
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Valoracion enviada correctamente!'),
              backgroundColor: Color(0xFF616281),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        widget.onValoracionCreada?.call();
        if (mounted) Navigator.of(context).pop();
      } else {
        // valoracion ya existia
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este servicio ya ha sido valorado'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        String mensajeError = e.toString();
        if (mensajeError.contains('ya ha sido valorado') ||
            mensajeError.contains('already rated') ||
            mensajeError.contains('duplicate')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este servicio ya ha sido valorado'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar valoracion'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}