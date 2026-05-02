import 'package:adoptapp/entity/usuario.dart';
import 'package:adoptapp/services/services.dart';
import 'package:adoptapp/services/user/user_service.dart';
import 'package:flutter/material.dart';

class RefugiosNotifier extends ChangeNotifier {
  final UserService _service = services.get<UserService>();

  List<Usuario> _refugios = <Usuario>[];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  List<Usuario> get refugios => _refugios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRefugios({bool forceRefresh = false}) async {
    if (_hasLoadedOnce && !forceRefresh) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final List<Usuario> users = await _service.getAllUsers();
      _refugios = users.where((user) => user.isRefugio).toList();
      _hasLoadedOnce = true;
      _error = null;
    } catch (e) {
      _error = 'Error cargando refugios: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadRefugios(forceRefresh: true);
  }
}
