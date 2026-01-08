// modelo para rango horario con inicio y fin
class RangoHorario {
  final String inicio;
  final String fin;

  RangoHorario({
    required this.inicio,
    required this.fin,
  });

  factory RangoHorario.fromJson(Map<String, dynamic> json) {
    return RangoHorario(
      inicio: json['inicio'] ?? '00:00',
      fin: json['fin'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inicio': inicio,
      'fin': fin,
    };
  }
}

// modelo para excepcion de horario en fechas especificas
class ExcepcionHorario {
  final String fecha;       // formato yyyy mm dd
  final bool disponible;
  final String? inicio;     // solo si disponible es true
  final String? fin;        // solo si disponible es true

  ExcepcionHorario({
    required this.fecha,
    required this.disponible,
    this.inicio,
    this.fin,
  });

  factory ExcepcionHorario.fromJson(Map<String, dynamic> json) {
    return ExcepcionHorario(
      fecha: json['fecha'] ?? '',
      disponible: json['disponible'] ?? false,
      inicio: json['inicio'],
      fin: json['fin'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'fecha': fecha,
      'disponible': disponible,
    };

    if (disponible && inicio != null) {
      json['inicio'] = inicio;
    }

    if (disponible && fin != null) {
      json['fin'] = fin;
    }

    return json;
  }
}

// modelo principal para horarios de servicios
class HorarioServicio {
  final Map<String, List<RangoHorario>> horarioRegular;
  final List<ExcepcionHorario> excepciones;

  HorarioServicio({
    required this.horarioRegular,
    required this.excepciones,
  });

  // crea horario vacio con dias de la semana
  factory HorarioServicio.empty() {
    return HorarioServicio(
      horarioRegular: {
        'lunes': [],
        'martes': [],
        'miercoles': [],
        'jueves': [],
        'viernes': [],
        'sabado': [],
        'domingo': [],
      },
      excepciones: [],
    );
  }

  factory HorarioServicio.fromJson(Map<String, dynamic> json) {
    // procesa horario regular
    Map<String, List<RangoHorario>> horarioRegular = {};

    if (json.containsKey('horario_regular')) {
      Map<String, dynamic> horarioRegularJson = json['horario_regular'];

      horarioRegularJson.forEach((dia, rangos) {
        horarioRegular[dia] = (rangos as List)
            .map((rango) => RangoHorario.fromJson(rango))
            .toList();
      });
    } else {
      // si no hay datos inicializa con dias vacios
      horarioRegular = {
        'lunes': [],
        'martes': [],
        'miercoles': [],
        'jueves': [],
        'viernes': [],
        'sabado': [],
        'domingo': [],
      };
    }

    // procesa excepciones
    List<ExcepcionHorario> excepciones = [];

    if (json.containsKey('excepciones')) {
      List excepcionesJson = json['excepciones'];

      excepciones = excepcionesJson
          .map((excepcion) => ExcepcionHorario.fromJson(excepcion))
          .toList();
    }

    return HorarioServicio(
      horarioRegular: horarioRegular,
      excepciones: excepciones,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> horarioRegularJson = {};

    horarioRegular.forEach((dia, rangos) {
      horarioRegularJson[dia] = rangos.map((rango) => rango.toJson()).toList();
    });

    return {
      'horario_regular': horarioRegularJson,
      'excepciones': excepciones.map((excepcion) => excepcion.toJson()).toList(),
    };
  }

  // verifica si hay horarios disponibles para un dia de la semana
  bool tieneDiaDisponible(String dia) {
    return horarioRegular.containsKey(dia) &&
        horarioRegular[dia] != null &&
        horarioRegular[dia]!.isNotEmpty;
  }

  // anade un rango horario a un dia especifico
  void agregarRangoHorario(String dia, String inicio, String fin) {
    if (!horarioRegular.containsKey(dia)) {
      horarioRegular[dia] = [];
    }

    horarioRegular[dia]!.add(RangoHorario(
      inicio: inicio,
      fin: fin,
    ));
  }

  // elimina un rango horario de un dia especifico
  void eliminarRangoHorario(String dia, int indice) {
    if (horarioRegular.containsKey(dia) &&
        horarioRegular[dia]!.length > indice) {
      horarioRegular[dia]!.removeAt(indice);
    }
  }

  // anade una excepcion de horario para fecha especifica
  void agregarExcepcion(String fecha, bool disponible, {String? inicio, String? fin}) {
    // comprueba si ya existe una excepcion para esta fecha
    int indiceExistente = excepciones.indexWhere((e) => e.fecha == fecha);

    if (indiceExistente >= 0) {
      // actualiza la excepcion existente
      excepciones[indiceExistente] = ExcepcionHorario(
        fecha: fecha,
        disponible: disponible,
        inicio: disponible ? inicio : null,
        fin: disponible ? fin : null,
      );
    } else {
      // anade nueva excepcion
      excepciones.add(ExcepcionHorario(
        fecha: fecha,
        disponible: disponible,
        inicio: disponible ? inicio : null,
        fin: disponible ? fin : null,
      ));
    }
  }

  // elimina una excepcion de horario
  void eliminarExcepcion(int indice) {
    if (excepciones.length > indice) {
      excepciones.removeAt(indice);
    }
  }
}