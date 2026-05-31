import 'package:flutter/foundation.dart';
import '../models/plan_model.dart';
import '../services/plan_service.dart';

class PlanProvider extends ChangeNotifier {
  final PlanService _service;

  PlanProvider(this._service);

  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlanModel? planById(int id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();
    try {
      _plans = await _service.getAllPlans();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Error al cargar planes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
