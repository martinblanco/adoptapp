import 'dart:convert';
import 'package:adoptapp/entity/provincia.dart';
import 'package:flutter/material.dart';

class FiltroNotifier extends ChangeNotifier {
  late Provincia _selectedProvincia;
  bool _isSelectedPerros = true;
  bool _isSelectedGatos = true;
  List<Provincia> _provincias = [];
  bool _isLoading = false;
  bool _initialized = false;

  // Getters
  Provincia get selectedProvincia => _selectedProvincia;
  bool get isSelectedPerros => _isSelectedPerros;
  bool get isSelectedGatos => _isSelectedGatos;
  List<Provincia> get provincias => _provincias;
  bool get isLoading => _isLoading;

  // Estado actual de filtros
  Map<String, dynamic> get currentFilters => {
        'perros': _isSelectedPerros,
        'gatos': _isSelectedGatos,
        'provincia': _selectedProvincia,
      };

  FiltroNotifier();

  // Cargar provincias desde JSON
  Future<void> cargarProvincias(BuildContext context) async {
    if (_initialized) return; // Ya cargó

    try {
      _isLoading = true;
      notifyListeners();

      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/jsons/provincias.json');

      final List<dynamic> jsonList = json.decode(jsonString);
      _provincias = jsonList.map((json) => Provincia.fromJson(json)).toList();

      if (_provincias.isNotEmpty) {
        _selectedProvincia = _provincias.first;
      }
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando provincias: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar provincia
  void setProvincia(Provincia provincia) {
    _selectedProvincia = provincia;
    notifyListeners();
  }

  // Toggle perros
  void togglePerros() {
    _isSelectedPerros = !_isSelectedPerros;
    notifyListeners();
  }

  // Toggle gatos
  void toggleGatos() {
    _isSelectedGatos = !_isSelectedGatos;
    notifyListeners();
  }

  // Reset filtros a default
  void resetFiltros() {
    _isSelectedPerros = true;
    _isSelectedGatos = true;
    if (_provincias.isNotEmpty) {
      _selectedProvincia = _provincias.first;
    }
    notifyListeners();
  }
}
