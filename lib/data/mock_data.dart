import '../models/user.dart';

class MockData {
  static final User demoUser = User(
    id: 'demo-user-1',
    email: 'reader@relsreading.com',
    username: 'นักอ่านแดนสวรรค์',
    role: 'user',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );
}
