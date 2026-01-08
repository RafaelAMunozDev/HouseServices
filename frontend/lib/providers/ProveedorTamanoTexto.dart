// lib/providers/text_size_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TamanoTexto { pequeno, medio, grande }

class ProveedorTamanoTexto extends ChangeNotifier {
  // Factor de escala para cada tamaño
  static const Map<TamanoTexto, double> _factores = {
    TamanoTexto.pequeno: 0.85,
    TamanoTexto.medio: 1.0,
    TamanoTexto.grande: 1.2,
  };

  // Nombres para la UI
  static const Map<TamanoTexto, String> _nombres = {
    TamanoTexto.pequeno: 'Pequeño',
    TamanoTexto.medio: 'Medio',
    TamanoTexto.grande: 'Grande',
  };

  // Valor por defecto
  TamanoTexto _tamanoActual = TamanoTexto.medio;

  TamanoTexto get tamanoActual => _tamanoActual;
  double get factorEscala => _factores[_tamanoActual]!;
  String get nombreTamano => _nombres[_tamanoActual]!;

  // Lista de nombres para el dropdown
  List<String> get listaNombres => _nombres.values.toList();

  ProveedorTamanoTexto() {
    _cargarPreferencia();
  }

  // Carga la preferencia guardada
  Future<void> _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final valorGuardado = prefs.getString('tamano_texto');

    if (valorGuardado != null) {
      switch (valorGuardado) {
        case 'pequeno':
          _tamanoActual = TamanoTexto.pequeno;
          break;
        case 'medio':
          _tamanoActual = TamanoTexto.medio;
          break;
        case 'grande':
          _tamanoActual = TamanoTexto.grande;
          break;
      }
      notifyListeners();
    }
  }

  // Cambia el tamaño del texto
  Future<void> cambiarTamano(String nombre) async {
    TamanoTexto? nuevoTamano;

    _nombres.forEach((key, value) {
      if (value == nombre) nuevoTamano = key;
    });

    if (nuevoTamano != null && nuevoTamano != _tamanoActual) {
      _tamanoActual = nuevoTamano!;

      // Guardar la preferencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tamano_texto', _tamanoActual.toString().split('.').last);

      notifyListeners();
    }
  }
}