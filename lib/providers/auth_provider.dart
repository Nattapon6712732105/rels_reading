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
  bool _isSendingOtp = false;
  String? _errorMessage;
  String? _otpSuccessMessage;
  bool _backendOnline = false;

  // LINE Official Account state
  bool _isLineLinked = false;
  String? _lineUserId;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSendingOtp => _isSendingOtp;
  String? get errorMessage => _errorMessage;
  String? get otpSuccessMessage => _otpSuccessMessage;
  bool get isLoggedIn => _user != null;
  bool get backendOnline => _backendOnline;
  bool get isLineLinked => _isLineLinked || (_user?.isLineLinked ?? false);
  String? get lineUserId => _lineUserId ?? _user?.lineUserId;

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
        _isLineLinked = profile.isLineLinked;
        _lineUserId = profile.lineUserId;
        await TokenStorage.saveUser(profile);
      } catch (_) {
        // If offline or profile fetch fails, keep cached user
        if (_user != null) {
          _isLineLinked = _user!.isLineLinked;
          _lineUserId = _user!.lineUserId;
        }
      }

      // Refresh LINE status
      await fetchLineStatus();
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
      _isLineLinked = res.user.isLineLinked;
      _lineUserId = res.user.lineUserId;
      await TokenStorage.saveUser(res.user);

      await fetchLineStatus();

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

  /// Request 6-digit OTP to be sent to the email
  Future<bool> sendOtp(String email) async {
    _isSendingOtp = true;
    _errorMessage = null;
    _otpSuccessMessage = null;
    notifyListeners();

    try {
      final msg = await _repo.sendOtp(email);
      _otpSuccessMessage = msg;
      _isSendingOtp = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSendingOtp = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user with Email, Username, Password, and 6-digit OTP
  Future<bool> register(String email, String username, String password, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.register(email, username, password, otp);
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

  /// Login with Google Credential
  Future<bool> loginWithGoogle(String credential) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repo.loginWithGoogle(credential);
      await TokenStorage.saveTokens(
        accessToken: res.tokens.accessToken,
        refreshToken: res.tokens.refreshToken,
      );
      _user = res.user;
      _isLineLinked = res.user.isLineLinked;
      _lineUserId = res.user.lineUserId;
      await TokenStorage.saveUser(res.user);

      await fetchLineStatus();

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

  /// Fetch LINE linking status from backend
  Future<void> fetchLineStatus() async {
    try {
      final status = await _repo.getLineStatus();
      _isLineLinked = status['isLinked'] == true;
      _lineUserId = status['lineUserId'] as String?;
      notifyListeners();
    } catch (_) {
      // Keep previous status
    }
  }

  /// Get LINE Official Account details (QR Code & basic ID)
  Future<Map<String, dynamic>> getLineOaInfo() async {
    return await _repo.getLineOaInfo();
  }

  /// Generate a 6-digit Link Code for linking via LINE chat
  Future<Map<String, dynamic>> createLineLinkCode() async {
    return await _repo.createLineLinkCode();
  }

  /// Link LINE User ID to current user account
  Future<bool> linkLineAccount(String lineUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await _repo.linkLine(lineUserId);
      if (ok) {
        _isLineLinked = true;
        _lineUserId = lineUserId;
        if (_user != null) {
          _user = _user!.copyWith(lineUserId: lineUserId);
          await TokenStorage.saveUser(_user!);
        }
      }
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Unlink LINE Account
  Future<bool> unlinkLineAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await _repo.unlinkLine();
      if (ok) {
        _isLineLinked = false;
        _lineUserId = null;
        if (_user != null) {
          _user = _user!.copyWith(lineUserId: '');
          await TokenStorage.saveUser(_user!);
        }
      }
      _isLoading = false;
      notifyListeners();
      return ok;
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
    _isLineLinked = false;
    _lineUserId = null;
    _errorMessage = null;
    _otpSuccessMessage = null;
    notifyListeners();
  }
}
