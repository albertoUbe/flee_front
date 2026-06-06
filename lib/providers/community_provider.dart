import 'package:flutter/foundation.dart';
import '../models/community_model.dart';
import '../services/community_service.dart';
import '../services/api_client.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _service;

  CommunityProvider(this._service);

  List<CommunityModel> _allCommunities = [];
  List<CommunityModel> _myCommunities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityModel> get allCommunities => _allCommunities;
  List<CommunityModel> get myCommunities => _myCommunities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CommunityModel? communityById(int id) {
    final combined = [..._allCommunities, ..._myCommunities];
    try {
      return combined.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAllCommunities() async {
    _setLoading(true);
    try {
      _allCommunities = await _service.getAllCommunities();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar comunidades: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyCommunities(int userId) async {
    _setLoading(true);
    try {
      _myCommunities = await _service.getCommunitiesByUser(userId);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = 'Error al cargar tus comunidades: ${e.statusCode}';
    } catch (_) {
      _errorMessage = 'Error de conexión';
    } finally {
      _setLoading(false);
    }
  }

  Future<CommunityModel?> createCommunity(
    int creatorId,
    String name,
    String description,
    int durationWeeks,
  ) async {
    _setLoading(true);
    try {
      final community = await _service.createCommunity(
        creatorId,
        name,
        description,
        durationWeeks,
      );
      _myCommunities = [community, ..._myCommunities];
      _allCommunities = [community, ..._allCommunities];
      _errorMessage = null;
      return community;
    } on ApiException catch (e) {
      _errorMessage = 'Error al crear comunidad: ${e.message}';
      return null;
    } catch (_) {
      _errorMessage = 'Error de conexión';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> editCommunity(int id, String name, String description) async {
    _setLoading(true);
    try {
      final updated = await _service.editCommunity(id, name, description);
      _allCommunities = _allCommunities
          .map((c) => c.id == id ? updated : c)
          .toList();
      _myCommunities = _myCommunities
          .map((c) => c.id == id ? updated : c)
          .toList();
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = 'Error al editar: ${e.message}';
      return false;
    } catch (_) {
      _errorMessage = 'Error de conexión';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCommunity(int id) async {
    _setLoading(true);
    try {
      await _service.deleteCommunity(id);
      _allCommunities = _allCommunities.where((c) => c.id != id).toList();
      _myCommunities = _myCommunities.where((c) => c.id != id).toList();
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = 'Error al eliminar: ${e.message}';
      return false;
    } catch (_) {
      _errorMessage = 'Error de conexión';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> followUnfollow(int communityId, int userId) async {
    try {
      await _service.followUnfollow(communityId, userId);
      await Future.wait([
        loadAllCommunities(),
        loadMyCommunities(userId),
      ]);
    } catch (_) {
      _errorMessage = 'Error al actualizar membresía';
      notifyListeners();
    }
  }

  Future<void> manageAdmin(int communityId, int ownerId, int userId) async {
    try {
      await _service.manageAdmin(communityId, ownerId, userId);
    } on ApiException catch (e) {
      _errorMessage = 'Error: ${e.message}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
