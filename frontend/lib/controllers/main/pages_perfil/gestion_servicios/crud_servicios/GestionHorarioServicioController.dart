import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../models/HorarioServicio.dart';
import '../../../../../../../utils/Dialogos.dart';

// controla la logica de gestion de horarios de servicios
class GestionHorarioServicioController {
  // variables del controlador
  late HorarioServicio _horario;
  late Function _actualizarEstado;
  int _currentTabIndex = 0;

  // acceso al estado actual
  HorarioServicio get horario => _horario;
  int get currentTabIndex => _currentTabIndex;

  // inicializa el controlador con horario base
  void init(HorarioServicio horarioInicial, Function actualizarEstado) {
    // clona el horario inicial para no modificar el original
    _horario = HorarioServicio.fromJson(horarioInicial.toJson());
    _actualizarEstado = actualizarEstado;
  }

  // cambia la pestana actual
  void cambiarTab(int index) {
    _currentTabIndex = index;
    _actualizarEstado();
  }

  // agrega rango horario a un dia especifico
  void agregarRangoHorario(String dia) {
    // valida maximo 2 horarios por dia
    if (_horario.horarioRegular[dia]!.length >= 2) {
      return;
    }

    _horario.agregarRangoHorario(dia, '09:00', '18:00');
    _actualizarEstado();
  }

  // elimina rango horario de un dia especifico
  void eliminarRangoHorario(String dia, int indice) {
    _horario.eliminarRangoHorario(dia, indice);
    _actualizarEstado();
  }

  // selecciona hora de inicio para un rango especifico
  Future<void> seleccionarHorarioInicio(BuildContext context, String dia, int indice) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_horario.horarioRegular[dia]![indice].inicio),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF616281)),
          ),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final horaFormateada = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
      final fin = _horario.horarioRegular[dia]![indice].fin;

      // crea un nuevo rango con la hora actualizada
      final nuevoRango = RangoHorario(inicio: horaFormateada, fin: fin);

      // reemplaza el rango en el horario
      _horario.horarioRegular[dia]![indice] = nuevoRango;
      _actualizarEstado();
    }
  }

  // selecciona hora de fin para un rango especifico
  Future<void> seleccionarHorarioFin(BuildContext context, String dia, int indice) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_horario.horarioRegular[dia]![indice].fin),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF616281)),
          ),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final horaFormateada = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
      final inicio = _horario.horarioRegular[dia]![indice].inicio;

      // crea un nuevo rango con la hora actualizada
      final nuevoRango = RangoHorario(inicio: inicio, fin: horaFormateada);

      // reemplaza el rango en el horario
      _horario.horarioRegular[dia]![indice] = nuevoRango;
      _actualizarEstado();
    }
  }

  // convierte string de tiempo a timeofday
  TimeOfDay _parseTimeOfDay(String horario) {
    final partes = horario.split(':');
    return TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  // agrega excepcion de horario para fecha especifica
  Future<void> agregarExcepcion(BuildContext context) async {
    // fecha actual como punto de partida
    DateTime fechaSeleccionada = DateTime.now();
    bool disponible = true;
    String horaInicio = '09:00';
    String horaFin = '18:00';

    // muestra dialogo para seleccionar fecha
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: const Color(0xFF616281)),
          ),
          child: child!,
        );
      },
    );

    if (fechaElegida == null) {
      return; // usuario cancelo la seleccion
    }

    fechaSeleccionada = fechaElegida;

    // formatea la fecha en el formato requerido
    final fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);

    // muestra dialogo para configurar la disponibilidad
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Configurar excepción'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha: ${DateFormat('dd/MM/yyyy').format(fechaSeleccionada)}'),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Disponible este día'),
                    value: disponible,
                    onChanged: (value) {
                      setDialogState(() {
                        disponible = value;
                      });
                    },
                  ),
                  if (disponible) ...[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final TimeOfDay? timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(horaInicio),
                              );
                              if (timeOfDay != null) {
                                setDialogState(() {
                                  horaInicio = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Text('Desde: $horaInicio'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final TimeOfDay? timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: _parseTimeOfDay(horaFin),
                              );
                              if (timeOfDay != null) {
                                setDialogState(() {
                                  horaFin = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Text('Hasta: $horaFin'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // guarda la excepcion y cierra el dialogo
                    _horario.agregarExcepcion(
                      fechaFormateada,
                      disponible,
                      inicio: disponible ? horaInicio : null,
                      fin: disponible ? horaFin : null,
                    );
                    Navigator.of(context).pop();
                    _actualizarEstado();
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // elimina excepcion de horario
  void eliminarExcepcion(int indice) {
    _horario.eliminarExcepcion(indice);
    _actualizarEstado();
  }

  // obtiene nombre del dia en español
  String getNombreDia(String clave) {
    switch (clave) {
      case 'lunes': return 'Lunes';
      case 'martes': return 'Martes';
      case 'miercoles': return 'Miércoles';
      case 'jueves': return 'Jueves';
      case 'viernes': return 'Viernes';
      case 'sabado': return 'Sábado';
      case 'domingo': return 'Domingo';
      default: return clave;
    }
  }

  // obtiene la lista de dias de la semana
  List<String> get diasSemana => [
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'
  ];

  // libera recursos del controlador
  void dispose() {
    // limpia recursos si es necesario
  }

  // valida horarios al guardar con manejo de errores backend
  Future<bool> validarHorarios(BuildContext context) async {
    // valida que hay al menos un horario configurado
    bool tieneAlgunHorario = false;

    for (String dia in diasSemana) {
      if (_horario.horarioRegular[dia]!.isNotEmpty) {
        tieneAlgunHorario = true;
        break;
      }
    }

    if (!tieneAlgunHorario) {
      _mostrarErrorSolapamiento(context,
          'Debes configurar al menos un horario para poder guardar');
      return false;
    }

    // valida horarios basicos frontend
    for (String dia in diasSemana) {
      final horariosDelDia = _horario.horarioRegular[dia]!;

      // valida cada horario del dia
      for (int i = 0; i < horariosDelDia.length; i++) {
        final horario = horariosDelDia[i];
        final inicioMinutos = _convertirHoraAMinutos(horario.inicio);
        final finMinutos = _convertirHoraAMinutos(horario.fin);

        // valida que inicio sea menor que fin
        if (inicioMinutos >= finMinutos) {
          _mostrarErrorSolapamiento(context,
              'En ${getNombreDia(dia)}: La hora de inicio (${horario.inicio}) debe ser anterior a la hora de fin (${horario.fin})');
          return false;
        }

        // valida solapamiento dentro del mismo dia
        for (int j = i + 1; j < horariosDelDia.length; j++) {
          final otroHorario = horariosDelDia[j];
          final otroInicioMinutos = _convertirHoraAMinutos(otroHorario.inicio);
          final otroFinMinutos = _convertirHoraAMinutos(otroHorario.fin);

          // verifica solapamiento
          if ((inicioMinutos < otroFinMinutos) && (finMinutos > otroInicioMinutos)) {
            _mostrarErrorSolapamiento(context,
                'En ${getNombreDia(dia)}: Los horarios ${horario.inicio}-${horario.fin} y ${otroHorario.inicio}-${otroHorario.fin} se solapan');
            return false;
          }
        }
      }
    }

    // el backend validara solapamiento entre servicios
    return true; // frontend valido el backend hara su validacion
  }

  // muestra mensaje de error cuando hay solapamiento
  void _mostrarErrorSolapamiento(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Horario no válido'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // convierte hora formato hh mm a minutos desde medianoche
  int _convertirHoraAMinutos(String hora) {
    final partes = hora.split(':');
    final horas = int.parse(partes[0]);
    final minutos = int.parse(partes[1]);
    return (horas * 60) + minutos;
  }
}