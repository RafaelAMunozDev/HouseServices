import 'package:flutter/material.dart';
import '../../../../widgets/TextoEscalable.dart';
import '../../../../controllers/main/pages_configuracion/ContactarSoporteController.dart';

class ContactarSoporte extends StatefulWidget {
  @override
  _ContactarSoporteState createState() => _ContactarSoporteState();
}

class _ContactarSoporteState extends State<ContactarSoporte> {
  final _formKey = GlobalKey<FormState>();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();
  String _categoriaSeleccionada = 'Problema tecnico';

  ContactarSoporteController? _controller;

  @override
  void initState() {
    super.initState();
    // inicializa el controlador con los parametros necesarios
    _controller = ContactarSoporteController(
      asuntoController: _asuntoController,
      mensajeController: _mensajeController,
      formKey: _formKey,
      categoriaSeleccionada: _categoriaSeleccionada,
      context: context,
    );
  }

  @override
  void dispose() {
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: TextoEscalable(
          texto: 'Contactar con Soporte',
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: const Color(0xFFAAADFF),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFD2D4F1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoEscalable(
                    texto: 'Estamos aqui para ayudarte. Por favor, cuentanos como podemos asistirte.',
                    estilo: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24),

                  // categoria del problema
                  TextoEscalable(
                    texto: 'Categoria',
                    estilo: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoriaSeleccionada,
                        isExpanded: true,
                        items: ContactarSoporteController.categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoriaSeleccionada = value!;
                            _controller?.actualizarCategoria(value);
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // campo de asunto
                  TextoEscalable(
                    texto: 'Asunto',
                    estilo: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _asuntoController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Escribe un asunto breve',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un asunto';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // campo de mensaje
                  TextoEscalable(
                    texto: 'Mensaje',
                    estilo: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Detalla tu consulta o problema...',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor escribe un mensaje';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // boton de enviar
                  Center(
                    child: GestureDetector(
                      onTap: () => _controller?.enviarMensaje(),
                      child: Container(
                        width: 200,
                        height: 52,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF616281),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Enviar mensaje',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // informacion de contacto alternativo
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextoEscalable(
                          texto: 'Tambien puedes contactarnos a traves de la siguiente informacion. Pulsa en el correo para copiarlo o en el numero de telefono para llamar directamente.',
                          estilo: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          alineacion: TextAlign.justify,
                        ),
                        SizedBox(height: 8),

                        // email clickeable
                        GestureDetector(
                          onTap: () => _controller?.copiarEmail(),
                          child: TextoEscalable(
                            texto: 'Email: ${ContactarSoporteController.emailSoporte}',
                            estilo: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),

                        // telefono clickeable
                        GestureDetector(
                          onTap: () => _controller?.llamarTelefono(),
                          child: TextoEscalable(
                            texto: 'Telefono: ${ContactarSoporteController.telefonoSoporte}',
                            estilo: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}