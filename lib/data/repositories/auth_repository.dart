import 'package:dio/dio.dart';
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

  Future<User> register(String email, String username, String password) async {
    try {
      final res = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'username': username.trim(),
          'password': password,
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
}
