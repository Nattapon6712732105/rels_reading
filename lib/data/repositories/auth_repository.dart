import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../core/api/api_client.dart';
import '../../models/auth_response.dart';
import '../../models/user.dart';

class AuthRepository {
  Future<AuthResponse> login(String email, String password) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (res.data['success'] == true) {
        return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }

  /// Request a 6-digit OTP sent to the user's email for registration
  Future<String> sendOtp(String email) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/send-otp',
        data: {
          'email': email.trim(),
        },
      );

      if (res.data['success'] == true) {
        return res.data['message'] as String? ?? 'ส่งรหัส OTP สำเร็จแล้ว';
      }
      throw Exception(res.data['message'] ?? 'ส่งรหัส OTP ไม่สำเร็จ');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('อีเมลนี้ถูกใช้งานแล้ว กรุณาเข้าสู่ระบบแทน');
      }
      if (e.response?.statusCode == 500) {
        throw Exception('เซิร์ฟเวอร์บน Vercel ยังไม่ได้ใส่ SMTP_PASS ใน Environment Variables (กรุณานำรหัสผ่าน 16 หลักไปใส่ใน Vercel Dashboard แล้ว Redeploy)');
      }
      final serverMsg = e.response?.data?['message'];
      final msg = serverMsg ?? e.message ?? 'เกิดข้อผิดพลาดในการส่งรหัส OTP';
      throw Exception(msg);
    }
  }

  /// Register a new account with email, username, password and the verified 6-digit OTP
  Future<User> register(String email, String username, String password, String otp) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'username': username.trim(),
          'password': password,
          'otp': otp.trim(),
        },
      );

      if (res.data['success'] == true) {
        return User.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ลงทะเบียนไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }

  /// Sign in with Google ID token credential
  Future<AuthResponse> loginWithGoogle(String credential) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/google',
        data: {
          'credential': credential.trim(),
        },
      );

      if (res.data['success'] == true) {
        return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ Google';
      throw Exception(msg);
    }
  }

  /// Sign in with LINE (Authorization code, Token, or Profile)
  Future<AuthResponse> loginWithLine({
    String? code,
    String? redirectUri,
    String? accessToken,
    String? idToken,
    String? lineUserId,
    String? displayName,
    String? pictureUrl,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (code != null && code.isNotEmpty) payload['code'] = code.trim();
      if (redirectUri != null && redirectUri.isNotEmpty) payload['redirectUri'] = redirectUri.trim();
      if (accessToken != null && accessToken.isNotEmpty) payload['accessToken'] = accessToken.trim();
      if (idToken != null && idToken.isNotEmpty) payload['idToken'] = idToken.trim();
      if (lineUserId != null && lineUserId.isNotEmpty) payload['lineUserId'] = lineUserId.trim();
      if (displayName != null && displayName.isNotEmpty) payload['displayName'] = displayName.trim();
      if (pictureUrl != null && pictureUrl.isNotEmpty) payload['pictureUrl'] = pictureUrl.trim();

      final res = await ApiClient.dio.post(
        '/auth/line',
        data: payload,
      );

      if (res.data['success'] == true) {
        return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'เข้าสู่ระบบด้วย LINE ไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ LINE';
      throw Exception(msg);
    }
  }

  /// Get LINE Login Authorization URL
  Future<String> getLineLoginUrl({String? redirectUri}) async {
    try {
      final res = await ApiClient.dio.get(
        '/auth/line/url',
        queryParameters: redirectUri != null ? {'redirectUri': redirectUri} : null,
      );
      if (res.data['success'] == true && res.data['data']?['url'] != null) {
        return res.data['data']['url'] as String;
      }
      throw Exception('ไม่สามารถดึง URL เข้าสู่ระบบด้วย LINE ได้');
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อระบบ LINE Login: ');
    }
  }

  Future<User> getProfile() async {
    try {
      final res = await ApiClient.dio.get('/user/profile');
      if (res.data['success'] == true) {
        return User.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'ดึงข้อมูลโปรไฟล์ไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }

  Future<User> updateProfile({String? username, String? email}) async {
    try {
      final payload = <String, dynamic>{};
      if (username != null && username.isNotEmpty) payload['username'] = username.trim();
      if (email != null && email.isNotEmpty) payload['email'] = email.trim();

      final res = await ApiClient.dio.put('/user/profile', data: payload);
      if (res.data['success'] == true) {
        return User.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      throw Exception(res.data['message'] ?? 'แก้ไขโปรไฟล์ไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
      throw Exception(msg);
    }
  }

  /// Check LINE Account Linking Status
  Future<Map<String, dynamic>> getLineStatus() async {
    try {
      final res = await ApiClient.dio.get('/line/status');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return res.data['data'] as Map<String, dynamic>;
      }
      return {'isLinked': false, 'lineUserId': null};
    } on DioException catch (_) {
      return {'isLinked': false, 'lineUserId': null};
    } catch (_) {
      return {'isLinked': false, 'lineUserId': null};
    }
  }

  /// Link LINE User ID to current user account
  Future<bool> linkLine(String lineUserId) async {
    try {
      final res = await ApiClient.dio.post(
        '/line/link',
        data: {'lineUserId': lineUserId.trim()},
      );
      if (res.data['success'] == true) {
        return true;
      }
      throw Exception(res.data['message'] ?? 'ผูกบัญชี LINE ไม่สำเร็จ');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการผูกบัญชี LINE';
      throw Exception(msg);
    }
  }

  /// Unlink LINE Account from current user account
  Future<bool> unlinkLine() async {
    try {
      final res = await ApiClient.dio.post('/line/unlink');
      return res.data['success'] == true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'ยกเลิกการผูกบัญชี LINE ไม่สำเร็จ';
      throw Exception(msg);
    }
  }

  /// Get LINE OA info (QR code, Basic ID, Add-friend URL)
  Future<Map<String, dynamic>> getLineOaInfo() async {
    try {
      final res = await ApiClient.dio.get('/line/oa-info');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return res.data['data'] as Map<String, dynamic>;
      }
      return {
        'botBasicId': AppConfig.lineOaBasicId,
        'displayName': 'rels reading',
        'addFriendUrl': AppConfig.lineOaUrl,
        'qrCodeUrl': 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://line.me/R/ti/p/@855szpwc',
      };
    } catch (_) {
      return {
        'botBasicId': AppConfig.lineOaBasicId,
        'displayName': 'rels reading',
        'addFriendUrl': AppConfig.lineOaUrl,
        'qrCodeUrl': 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=https://line.me/R/ti/p/@855szpwc',
      };
    }
  }

  /// Create a 6-digit Link Code for linking via LINE chat
  Future<Map<String, dynamic>> createLineLinkCode() async {
    try {
      final res = await ApiClient.dio.post('/line/link-code');
      if (res.data['success'] == true && res.data['data'] is Map<String, dynamic>) {
        return res.data['data'] as Map<String, dynamic>;
      }
      throw Exception(res.data['message'] ?? 'ไม่สามารถสร้างรหัสเชื่อมต่อได้');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'เกิดข้อผิดพลาดในการสร้างรหัสเชื่อมต่อ';
      throw Exception(msg);
    }
  }

  /// Send test notification to user's linked LINE OA account
  Future<bool> sendTestLineNotification() async {
    try {
      final res = await ApiClient.dio.post('/line/test-notification');
      return res.data['success'] == true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'ไม่สามารถส่งการแจ้งเตือนทดสอบได้';
      throw Exception(msg);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการส่งแจ้งเตือนทดสอบ: $e');
    }
  }
}

