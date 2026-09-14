import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../data/mock_data.dart';
import '../../data/repositories/auth_repository.dart';
import '../../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  bool _backendOnline = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get backendOnline => _backendOnline;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Check backend health
    try {
      final health = await ApiClient.checkHealth();
      _backendOnline = health != null && health['success'] == true;
    } catch (_) {
      _backendOnline = false;
    }

    // Check local tokens
    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      // Try to load cached user first
      _user = await TokenStorage.getUser();

      // Attempt to refresh profile from API if possible
      try {
        final profile = await _repo.getProfile();
        _user = profile;
        await TokenStorage.saveUser(profile);
      } catch (_) {
        // If offline or profile fetch fails, keep cached user
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repo.login(email, password);
      await TokenStorage.saveTokens(
        accessToken: res.tokens.accessToken,
        refreshToken: res.tokens.refreshToken,
      );
      _user = res.user;
      await TokenStorage.saveUser(res.user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.register(email, username, password);
      // Automatically login after register
      final success = await login(email, password);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> useDemoAccount() async {
    _user = MockData.demoUser;
    await TokenStorage.saveUser(MockData.demoUser);
    notifyListeners();
  }

  Future<bool> updateProfile({String? username, String? email}) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _repo.updateProfile(username: username, email: email);
      _user = updated;
      await TokenStorage.saveUser(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // If offline/error, apply locally
      _user = _user!.copyWith(username: username, email: email);
      await TokenStorage.saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _user = null;
    notifyListeners();
  }
}
