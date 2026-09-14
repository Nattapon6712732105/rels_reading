import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/novel_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'novel_detail_screen.dart';

class CreateNovelScreen extends StatefulWidget {
  const CreateNovelScreen({super.key});

  @override
  State<CreateNovelScreen> createState() => _CreateNovelScreenState();
}

class _CreateNovelScreenState extends State<CreateNovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _coverUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final novelProvider = context.read<NovelProvider>();
      final created = await novelProvider.createNovel(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        coverUrl: _coverUrlController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างนิยายสำเร็จเรียบร้อย!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NovelDetailScreen(novelId: created.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('แต่งนิยายเรื่องใหม่'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!auth.isLoggedIn)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'คุณยังไม่ได้เข้าสู่ระบบ เข้าสู่ระบบเพื่อบันทึกผลงานลงในบัญชีของคุณ',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text('เข้าสู่ระบบ'),
                        ),
                      ],
                    ),
                  ),

                // Title
                const Text(
                  'ชื่อเรื่อง *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'เช่น ข้ามภพมาเป็นยอดคหบดี',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'กรุณาระบุชื่อเรื่อง';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'เรื่องย่อ / คำโปรย',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'บรรยายเรื่องย่อที่น่าสนใจเพื่อดึงดูดนักอ่าน...',
                  ),
                ),
                const SizedBox(height: 20),

                // Cover URL
                const Text(
                  'ลิงก์ภาพปก (Image URL)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _coverUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://images.unsplash.com/...',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('เผยแพร่นิยาย'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
