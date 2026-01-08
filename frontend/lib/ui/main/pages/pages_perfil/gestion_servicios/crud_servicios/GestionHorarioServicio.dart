import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../../../../models/HorarioServicio.dart';
import '../../../../../../../controllers/main/pages_perfil/gestion_servicios/crud_servicios/GestionHorarioServicioController.dart';
import '../../../../../../../widgets/Componentes_reutilizables.dart';
// pantalla para configurar horarios de servicios
class GestionHorarioServicio extends StatefulWidget {
  final HorarioServicio horarioInicial;
  final String nombreServicio;

  const GestionHorarioServicio({
    Key? key,
    required this.horarioInicial,
    required this.nombreServicio,
  }) : super(key: key);

  @override
  _GestionHorarioServicioState createState() => _GestionHorarioServicioState();
}

class _GestionHorarioServicioState extends State<GestionHorarioServicio> with SingleTickerProviderStateMixin {
  late GestionHorarioServicioController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // inicializa locales en español
    initializeDateFormatting('es', null);

    _controller = GestionHorarioServicioController();
    _controller.init(widget.horarioInicial, _actualizarEstado);
    _tabController = TabController(length: 2, vsync: this);

    // escucha cambios en el tabcontroller
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _controller.cambiarTab(_tabController.index);
      }
    });
  }

  // actualiza la interfaz cuando hay cambios
  void _actualizarEstado() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAADFF),
      appBar: AppBar(
        title: Text(
          'Horario del Servicio',
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
      floatingActionButton: _controller.currentTabIndex == 1
          ? FloatingActionButton(
        onPressed: () => _controller.agregarExcepcion(context),
        backgroundColor: const Color(0xFF616281),
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

          // encabezado con texto explicativo
          Container(
            width: MediaQuery.of(context).size.width - 40,
            child: Componentes_reutilizables.construirEncabezado(
              titulo: 'CONFIGURAR HORARIO',
              subtitulo: 'Establece los días y horas en los que ofreces ${widget.nombreServicio}. Puedes configurar un horario regular semanal y añadir excepciones para fechas específicas.',
              anchoTitulo: MediaQuery.of(context).size.width - 40,
            ),
          ),

          SizedBox(height: 12),

          // barra de pestanas estilo gestionservicios
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF616281),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              indicator: BoxDecoration(
                color: const Color(0xFF616281),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(icon: Icon(Icons.access_time, size: 18), text: 'Horario Regular'),
                Tab(icon: Icon(Icons.event_busy, size: 18), text: 'Excepciones'),
              ],
            ),
          ),

          SizedBox(height: 16),

          // contenido de las pestanas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _construirPantallaHorarioRegular(),
                _construirPantallaExcepciones(),
              ],
            ),
          ),

          // boton guardar centrado con validacion
          Container(
            padding: EdgeInsets.all(20),
            child: Componentes_reutilizables.construirBoton(
              texto: 'Guardar Horario',
              alPulsar: () async {
                // valida horarios frontend primero
                if (await _controller.validarHorarios(context)) {
                  Navigator.of(context).pop(_controller.horario);
                }
                // si el backend detecta solapamiento se mostrara automaticamente el error
              },
              ancho: 200,
              alto: 52,
            ),
          ),
        ],
      ),
    );
  }

  // construye la pestana de horario regular semanal
  Widget _construirPantallaHorarioRegular() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: _controller.diasSemana.map((dia) {
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Row(
                children: [
                  Text(
                    _controller.getNombreDia(dia),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  if (_controller.horario.horarioRegular[dia]!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFAAADFF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_controller.horario.horarioRegular[dia]!.length} ${_controller.horario.horarioRegular[dia]!.length == 1 ? 'horario' : 'horarios'}',
                        style: TextStyle(fontSize: 12, color: const Color(0xFF616281)),
                      ),
                    ),
                ],
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // muestra los rangos de horario para este dia
                        if (_controller.horario.horarioRegular[dia]!.isEmpty)
                          Text(
                            'No hay horarios configurados para este día',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          )
                        else
                          ..._controller.horario.horarioRegular[dia]!.asMap().entries.map(
                                (entry) {
                              final indice = entry.key;
                              final rango = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => _controller.seleccionarHorarioInicio(context, dia, indice),
                                            child: Text(rango.inicio),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8),
                                            child: Text('a'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => _controller.seleccionarHorarioFin(context, dia, indice),
                                            child: Text(rango.fin),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _controller.eliminarRangoHorario(dia, indice),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),

                        // boton para anadir nuevo rango maximo 2 por dia
                        SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _controller.horario.horarioRegular[dia]!.length < 2
                              ? () => _controller.agregarRangoHorario(dia)
                              : null,
                          icon: Icon(Icons.add, size: 18),
                          label: Text(_controller.horario.horarioRegular[dia]!.length < 2
                              ? 'Añadir horario'
                              : 'Máximo 2 horarios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _controller.horario.horarioRegular[dia]!.length < 2
                                ? const Color(0xFF616281)
                                : Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // construye la pestana de excepciones de horario
  Widget _construirPantallaExcepciones() {
    if (_controller.horario.excepciones.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[600]),
              SizedBox(height: 16),
              Text(
                'No hay excepciones configuradas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Pulsa el botón + para añadir una excepción de horario para fechas específicas',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: _controller.horario.excepciones.asMap().entries.map((entry) {
          final index = entry.key;
          final excepcion = entry.value;
          final fecha = DateTime.parse(excepcion.fecha);

          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAADFF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(fecha),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMM', 'es').format(fecha).toUpperCase(),
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                DateFormat('EEEE dd/MM/yyyy', 'es').format(fecha),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: excepcion.disponible
                  ? Text(
                'Disponible: ${excepcion.inicio} - ${excepcion.fin}',
                style: TextStyle(fontSize: 14, color: Colors.green[700]),
              )
                  : Text(
                'No disponible',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _controller.eliminarExcepcion(index),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}