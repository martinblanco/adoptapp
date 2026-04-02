import 'package:adoptapp/entity/mascota.dart';
import 'package:adoptapp/services/mascotas/mascotas_service.dart';
import 'package:adoptapp/services/services.dart';
import 'package:flutter/material.dart';

class MascotasNotifier extends ChangeNotifier {
  final MascotasService _service = services.get<MascotasService>();

  List<Mascota> _mascotas = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Mascota> get mascotas => _mascotas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Solo carga una vez
  bool _hasLoadedOnce = false;

  Future<void> loadMascotas({bool forceRefresh = false}) async {
    // Si ya cargó y no es refresh forzado, no hacer nada
    if (_hasLoadedOnce && !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final mascotas = await _service.getAllPets();
      _mascotas = mascotas;
      _hasLoadedOnce = true;
      _error = null;
    } catch (e) {
      _error = 'Error cargando mascotas: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadMascotas(forceRefresh: true);
  }
}
