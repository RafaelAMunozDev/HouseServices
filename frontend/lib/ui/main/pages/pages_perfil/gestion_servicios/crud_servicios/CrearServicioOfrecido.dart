import 'package:flutter/material.dart';
import '../../../../../../controllers/main/pages_perfil/gestion_servicios/crud_servicios/CrearServicioOfrecidoController.dart';
import '../../../../../../models/HorarioServicio.dart';
import '../../../../../../utils/Dialogos.dart';
import '../../../../../../utils/IconoHelper.dart';
import '../../../../../../utils/Validadores.dart';
import '../../../../../../widgets/Componentes_reutilizables.dart';
import 'GestionHorarioServicio.dart';

// pantalla para crear o editar servicios ofrecidos
class CrearServicioOfrecido extends StatefulWidget {
  final int? servicioId;

  const CrearServicioOfrecido({
    Key? key,
    this.servicioId,
  }) : super(key: key);

  @override
  _CrearServicioOfrecidoState createState() => _CrearServicioOfrecidoState();
}

class _CrearServicioOfrecidoState extends State<CrearServicioOfrecido> {
  final _formKey = GlobalKey<FormState>();
  late final CrearServicioOfrecidoController _controller;

  // controladores para los campos de texto
  final _descripcionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _precioHoraController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CrearServicioOfrecidoController();
    _controller.init(_actualizarEstado, widget.servicioId);

    _precioHoraController.text = '0.0';
    _cargarDatos();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _observacionesController.dispose();
    _precioHoraController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // actualiza la interfaz cuando hay cambios
  void _actualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  // carga los datos iniciales del servicio
  Future<void> _cargarDatos() async {
    try {
      await _controller.cargarDatos(widget.servicioId);

      // llena los campos si es edicion
      if (_controller.esEdicion && _controller.servicioOriginal != null) {
        final servicio = _controller.servicioOriginal!;
        _descripcionController.text = servicio.descripcion ?? '';
        _observacionesController.text = servicio.observaciones ?? '';
        _precioHoraController.text = servicio.precioHora.toString();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  // navega a la pantalla de configuracion de horario
  Future<void> _configurarHorario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestionHorarioServicio(
          horarioInicial: _controller.horarioServicio,
          nombreServicio: _controller.servicioSeleccionadoNombre ?? 'Nuevo servicio',
        ),
      ),
    );

    if (resultado != null && resultado is HorarioServicio) {
      _controller.actualizarHorario(resultado);
    }
  }

  // guarda el servicio en el servidor
  Future<void> _guardarServicio() async {
    try {
      final exito = await _controller.guardarServicio(
        context: context,
        descripcion: _descripcionController.text,
        observaciones: _observacionesController.text,
        precio: _precioHoraController.text,
      );

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _controller.esEdicion
                    ? 'Servicio actualizado correctamente'
                    : 'Servicio creado correctamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // los errores se manejan en el controlador
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      appBar: AppBar(
        title: Text(
          _controller.esEdicion ? 'Editar Servicio' : 'Crear Servicio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFAAADFF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _construirCuerpo(),
    );
  }

  // construye el contenido principal de la pantalla
  Widget _construirCuerpo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: ShapeDecoration(
        color: const Color(0xFFD2D4F1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 25),

          // encabezado con titulo y descripcion
          Container(
            width: MediaQuery.of(context).size.width - 40,
            child: Componentes_reutilizables.construirEncabezado(
              titulo: _controller.esEdicion ? 'EDITAR SERVICIO' : 'CREAR SERVICIO',
              subtitulo: _controller.esEdicion
                  ? 'Modifica los datos de tu servicio para ajustar la informacion nueva a las correspondencias que necesite.'
                  : 'Completa la información de tu nuevo servicio a crear, estableciendo los datos mas detalladamente posible.',
              anchoTitulo: MediaQuery.of(context).size.width - 40,
            ),
          ),

          // contenido desplazable con el formulario
          Expanded(
            child: _controller.estaCargando
                ? Center(child: CirculoCargarPersonalizado())
                : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),

                    _construirSelectorServicio(),
                    SizedBox(height: 20),

                    // campo de descripcion con titulo
                    _construirCampoDescripcion(),
                    SizedBox(height: 20),

                    // campo de observaciones con titulo
                    _construirCampoObservaciones(),
                    SizedBox(height: 20),

                    // campo de precio por hora
                    Componentes_reutilizables.construirCampoTexto(
                      controlador: _precioHoraController,
                      etiqueta: 'Precio por hora (€)',
                      icono: Icons.euro,
                      tipoTeclado: TextInputType.numberWithOptions(decimal: true),
                    ),

                    SizedBox(height: 10),
                    _construirSeccionHorario(),
                    SizedBox(height: 20),
                    _construirSeccionImagenes(),
                    SizedBox(height: 30),

                    // boton para guardar el servicio
                    Componentes_reutilizables.construirBoton(
                      texto: _controller.esEdicion ? 'Actualizar Servicio' : 'Crear Servicio',
                      alPulsar: _guardarServicio,
                      ancho: 200,
                      alto: 52,
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // construye el selector de tipo de servicio
  Widget _construirSelectorServicio() {
    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIPO DE SERVICIO',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.work, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      Text(
                        'Seleccione un tipo de servicio',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                value: _controller.servicioSeleccionadoId,
                onChanged: (value) => _controller.seleccionarTipoServicio(value),
                menuMaxHeight: 200,
                items: _controller.servicios.map<DropdownMenuItem<int>>((Map<String, dynamic> servicio) {
                  return DropdownMenuItem<int>(
                    value: servicio['id'],
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // icono dinamico segun el tipo de servicio
                          IconoHelper.crearIcono(
                            servicio['icono'],
                            size: 24,
                            color: const Color(0xFF616281),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              servicio['nombre'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // construye el campo de descripcion del servicio
  Widget _construirCampoDescripcion() {
    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPCIÓN DEL SERVICIO',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _descripcionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe tu servicio en detalle.',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.description, color: Color(0xFF616281)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF49454F)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFAAADFF), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // construye el campo de observaciones adicionales
  Widget _construirCampoObservaciones() {
    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OBSERVACIONES',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _observacionesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe las observaciones adicionales (opcional).',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.note, color: Color(0xFF616281)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF49454F)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFAAADFF), width: 2),
              ),
            ),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // construye la seccion de configuracion de horario
  Widget _construirSeccionHorario() {
    // cuenta dias con horarios configurados
    int diasConfigurados = 0;
    _controller.horarioServicio.horarioRegular.forEach((dia, rangos) {
      if (rangos.isNotEmpty) diasConfigurados++;
    });

    int numExcepciones = _controller.horarioServicio.excepciones.length;

    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HORARIO DE SERVICIO',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: _configurarHorario,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: const Color(0xFF616281)),
                          SizedBox(width: 8),
                          Text(
                            'Configurar horario',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                    ],
                  ),
                  SizedBox(height: 8),
                  // resumen del horario configurado
                  if (_controller.horarioServicio.horarioRegular.isEmpty &&
                      _controller.horarioServicio.excepciones.isEmpty)
                    Text(
                      'Pulsa aquí para configurar el horario',
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horario regular: $diasConfigurados ${diasConfigurados == 1 ? 'día' : 'días'} configurados',
                          style: TextStyle(color: Colors.grey[800], fontSize: 14),
                        ),
                        if (numExcepciones > 0)
                          Text(
                            'Excepciones: $numExcepciones ${numExcepciones == 1 ? 'fecha' : 'fechas'} especiales',
                            style: TextStyle(color: Colors.grey[800], fontSize: 14),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // construye la seccion de gestion de imagenes
  Widget _construirSeccionImagenes() {
    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IMÁGENES DEL SERVICIO',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),

          // boton para anadir imagenes
          InkWell(
            onTap: () => _controller.mostrarOpcionesImagen(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_photo_alternate, color: const Color(0xFF616281)),
                      SizedBox(width: 8),
                      Text(
                        'Añadir imágenes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                ],
              ),
            ),
          ),

          // muestra imagenes existentes y nuevas
          if (_controller.imagenesExistentes.isNotEmpty || _controller.imagenesNuevas.isNotEmpty) ...[
            SizedBox(height: 12),

            // imagenes existentes solo en edicion
            if (_controller.esEdicion && _controller.imagenesExistentes.isNotEmpty) ...[
              Text(
                'Imágenes actuales:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[800]),
              ),
              SizedBox(height: 8),
              _construirListaImagenesExistentes(),
            ],

            // imagenes nuevas a anadir
            if (_controller.imagenesNuevas.isNotEmpty) ...[
              if (_controller.esEdicion && _controller.imagenesExistentes.isNotEmpty) SizedBox(height: 12),
              Text(
                _controller.esEdicion ? 'Imágenes nuevas a añadir:' : 'Imágenes seleccionadas:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[800]),
              ),
              SizedBox(height: 8),
              _construirListaImagenesNuevas(),
            ],
          ],
        ],
      ),
    );
  }

  // construye lista horizontal de imagenes existentes
  Widget _construirListaImagenesExistentes() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.imagenesExistentes.length,
        itemBuilder: (context, index) {
          final url = _controller.imagenesExistentes[index];
          return Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    url,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                // boton de eliminar imagen
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _controller.eliminarImagenExistente(index),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // construye lista horizontal de imagenes nuevas
  Widget _construirListaImagenesNuevas() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controller.imagenesNuevas.length,
        itemBuilder: (context, index) {
          final file = _controller.imagenesNuevas[index];
          return Container(
            width: 80,
            height: 80,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                ),
                // boton de eliminar imagen nueva
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _controller.eliminarImagenNueva(index),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}