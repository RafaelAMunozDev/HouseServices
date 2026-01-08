import 'package:flutter/material.dart';
import '../controllers/main/pages_inicio/ServicioDisponibleDetallesController.dart';
import '../models/ServicioDisponible.dart';
import '../models/HorarioServicio.dart';
import '../services/ServicioDisponibleService.dart';
import '../utils/IconoHelper.dart';
import '../utils/ReservasOperaciones.dart';
import 'Componentes_reutilizables.dart';

class ReservarServicioBottomSheet extends StatefulWidget {
  final ServicioDisponible servicio;

  const ReservarServicioBottomSheet({Key? key, required this.servicio}) : super(key: key);

  @override
  _ReservarServicioBottomSheetState createState() => _ReservarServicioBottomSheetState();
}

class _ReservarServicioBottomSheetState extends State<ReservarServicioBottomSheet>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final ServicioDisponibleDetallesController _controller = ServicioDisponibleDetallesController();
  final ServicioDisponibleService _servicioService = ServicioDisponibleService();

  bool _estaCargando = true;
  HorarioServicio? _horarioServicio;
  DateTime _fechaSeleccionada = DateTime.now();
  String? _horaSeleccionada;
  List<String> _horariosDisponibles = [];
  final TextEditingController _observacionesController = TextEditingController();
  bool _procesandoReserva = false;

  @override
  void initState() {
    super.initState();

    // configurar animacion
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    // inicializar controller
    _controller.init(_actualizarEstado, servicio: widget.servicio);
    _animationController.forward();
    _cargarHorarios();
  }

  // actualizar estado de la ui
  void _actualizarEstado() {
    if (mounted) setState(() {});
  }

  // cargar horarios disponibles del servicio
  Future<void> _cargarHorarios() async {
    try {
      setState(() => _estaCargando = true);

      final horario = await _servicioService.obtenerHorarioServicio(widget.servicio.id);
      setState(() {
        _horarioServicio = horario;
        _estaCargando = false;
      });

      await _actualizarHorariosDisponibles();
    } catch (e) {
      setState(() => _estaCargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horarios disponibles'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // actualizar horarios segun fecha seleccionada
  Future<void> _actualizarHorariosDisponibles() async {
    if (_horarioServicio == null) return;

    // horarios teoricos segun horario_json
    final horarios = _controller.obtenerHorariosDisponiblesPorFecha(
      horarioServicio: _horarioServicio!,
      fechaSeleccionada: _fechaSeleccionada,
    );

    // horas ya ocupadas en back
    final horasOcupadas = await _servicioService.obtenerHorasOcupadas(
      servicioDisponibleId: widget.servicio.id,
      fecha: _fechaSeleccionada,
    );

    // restamos ocupadas
    final horariosFiltrados =
    horarios.where((h) => !horasOcupadas.contains(h)).toList();

    if (!mounted) return;

    setState(() {
      _horariosDisponibles = horariosFiltrados;
      _horaSeleccionada = null;
    });
  }


  // mostrar selector de fecha
  Future<void> _seleccionarFecha() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF616281),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() => _fechaSeleccionada = fechaSeleccionada);
      await _actualizarHorariosDisponibles();
    }
  }

  // confirmar y procesar reserva
  Future<void> _confirmarReserva() async {
    if (_procesandoReserva) return;

    // confirmar reserva
    final confirmar = await ReservasOperaciones.mostrarConfirmacionReserva(
      context: context,
      nombreServicio: widget.servicio.nombreServicio,
      nombreProveedor: widget.servicio.nombreTrabajador,
      precio: widget.servicio.precioHora,
    );

    if (!confirmar) return;

    setState(() => _procesandoReserva = true);

    try {
      final resultado = await _controller.contratarServicio(
        fechaSeleccionada: _fechaSeleccionada,
        horaSeleccionada: _horaSeleccionada!,
        observaciones: _observacionesController.text,
      );

      if (resultado) {
        await _animationController.reverse();
        Navigator.of(context).pop();
        ReservasOperaciones.mostrarReservaExitosa(context, widget.servicio.nombreServicio);
      }
    } catch (e) {
      ReservasOperaciones.mostrarErrorReserva(context, 'Error al procesar la reserva');
    } finally {
      setState(() => _procesandoReserva = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Color(0xFFD2D4F1),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // indicador de arrastre
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                ),

                // encabezado
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RESERVAR SERVICIO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto')),
                      IconButton(
                        onPressed: _procesandoReserva ? null : () async {
                          await _animationController.reverse();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // contenido scrollable
                Expanded(
                  child: _estaCargando
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirInfoServicio(),
                        SizedBox(height: 20),
                        _construirSelectorFecha(),
                        SizedBox(height: 20),
                        _construirHorariosDisponibles(),
                        SizedBox(height: 20),
                        if (_horaSeleccionada != null) _construirResumenReserva(),
                        _construirCampoObservaciones(),
                        SizedBox(height: 20),
                        _construirBotonReservar(),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // construye info del servicio
  Widget _construirInfoServicio() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: widget.servicio.obtenerColorServicio(),
            child: IconoHelper.crearIcono(widget.servicio.iconoServicio, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.servicio.nombreServicio, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                Text(widget.servicio.nombreTrabajador, style: TextStyle(color: Colors.grey[600], fontFamily: 'Roboto')),
                Text('${widget.servicio.precioHora.toStringAsFixed(2)}€/hora',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF616281), fontFamily: 'Roboto')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // construye selector de fecha
  Widget _construirSelectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FECHA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Poppins')),
        SizedBox(height: 8),
        InkWell(
          onTap: _procesandoReserva ? null : _seleccionarFecha,
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
                    Icon(Icons.calendar_today, color: Color(0xFF616281)),
                    SizedBox(width: 12),
                    Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                        style: TextStyle(fontSize: 16, fontFamily: 'Roboto')),
                  ],
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // construye lista de horarios disponibles
  Widget _construirHorariosDisponibles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HORARIOS DISPONIBLES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Poppins')),
        SizedBox(height: 8),
        if (_horariosDisponibles.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.schedule, color: Colors.grey[400], size: 48),
                SizedBox(height: 8),
                Text('No hay horarios disponibles para esta fecha',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontFamily: 'Roboto')),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _horariosDisponibles.map((hora) {
              final isSelected = _horaSeleccionada == hora;
              return GestureDetector(
                onTap: _procesandoReserva ? null : () => setState(() => _horaSeleccionada = hora),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF616281) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Color(0xFF616281) : Colors.grey.shade300),
                  ),
                  child: Text(
                    hora,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // construye resumen de la reserva
  Widget _construirResumenReserva() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF616281).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF616281), size: 20),
              SizedBox(width: 8),
              Text('RESUMEN DE LA RESERVA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF616281), fontFamily: 'Poppins')),
            ],
          ),
          SizedBox(height: 12),
          _construirDetalleResumen('Duracion:', ReservasOperaciones.formatearDuracion(_horaSeleccionada!)),
          SizedBox(height: 4),
          _construirDetalleResumen('Precio total:',
              '${ReservasOperaciones.calcularPrecioTotal(precioHora: widget.servicio.precioHora).toStringAsFixed(2)}€'),
        ],
      ),
    );
  }

  // construye detalle del resumen
  Widget _construirDetalleResumen(String titulo, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontFamily: 'Roboto')),
        Text(valor, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF616281), fontFamily: 'Roboto')),
      ],
    );
  }

  // construye campo de observaciones
  Widget _construirCampoObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OBSERVACIONES (OPCIONAL)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Poppins')),
        SizedBox(height: 8),
        TextFormField(
          controller: _observacionesController,
          enabled: !_procesandoReserva,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Anade cualquier detalle importante...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF616281))),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  // construye boton de reservar
  Widget _construirBotonReservar() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Componentes_reutilizables.construirBoton(
            texto: _procesandoReserva ? 'Procesando...' : 'Enviar Solicitud',
            habilitado: !_procesandoReserva,
            alPulsar: _procesandoReserva
                ? () {}
                : () async {
              // si no hay hora, mostramos dialogo y fuera
              if (_horaSeleccionada == null || _horaSeleccionada!.isEmpty) {
                await _mostrarDialogoSeleccionarHora();
                return;
              }

              // si hay hora, ya si confirmamos
              await _confirmarReserva();
            },
            ancho: double.infinity,
            alto: 52,
          ),

          if (_procesandoReserva)
            const Positioned(
              right: 16,
              top: 16,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoSeleccionarHora() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.schedule, color: Color(0xFF616281)),
              SizedBox(width: 10),
              Text('Selecciona una hora'),
            ],
          ),
          content: const Text(
            'Antes de enviar la solicitud tienes que elegir un horario disponible.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF616281),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    _observacionesController.dispose();
    _controller.dispose();
    super.dispose();
  }
}