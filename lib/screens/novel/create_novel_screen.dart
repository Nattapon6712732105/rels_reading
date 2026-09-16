import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploadingImage = false;
  bool _showManualUrlInput = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 2400,
        imageQuality: 88,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเลือกรูปภาพได้: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเข้าสู่ระบบก่อนสร้างนิยาย'),
          backgroundColor: AppTheme.warning,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final novelProvider = context.read<NovelProvider>();
      String finalCoverUrl = _coverUrlController.text.trim();

      // If user selected an image file from their device, upload it first
      if (_selectedImageBytes != null) {
        setState(() => _isUploadingImage = true);
        try {
          final uploadedUrl = await novelProvider.uploadCoverImage(
            imageBytes: _selectedImageBytes!,
            filename: _selectedImageName ?? 'novel_cover.jpg',
          );
          finalCoverUrl = uploadedUrl;
        } catch (uploadError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('อัปโหลดภาพไม่สำเร็จ: $uploadError'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        } finally {
          if (mounted) setState(() => _isUploadingImage = false);
        }
      }

      final created = await novelProvider.createNovel(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        coverUrl: finalCoverUrl.isNotEmpty ? finalCoverUrl : null,
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
            content: Text('เกิดข้อผิดพลาด: ${e.toString().replaceAll("Exception: ", "")}'),
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
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'คุณยังไม่ได้เข้าสู่ระบบ เข้าสู่ระบบเพื่อบันทึกผลงานลงในบัญชีของคุณ',
                                style: TextStyle(fontSize: 13, height: 1.4),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('เข้าสู่ระบบ'),
                            ),
                          ],
                        ),
                      ),

                    // Cover Image Section
                    const Text(
                      'ภาพปกนิยาย',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Cover Picker Container
                    Center(
                      child: _selectedImageBytes != null
                          ? Column(
                              children: [
                                Container(
                                  width: 160,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.memory(
                                          _selectedImageBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                        if (_isUploadingImage)
                                          Container(
                                            color: Colors.black54,
                                            child: const Center(
                                              child: CircularProgressIndicator(color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _isSubmitting ? null : _pickImage,
                                      icon: const Icon(Icons.sync_rounded, size: 16),
                                      label: const Text('เปลี่ยนรูปภาพ', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: _isSubmitting ? null : _clearSelectedImage,
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.error),
                                      label: const Text('ลบรูป', style: TextStyle(color: AppTheme.error, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: _isSubmitting ? null : _pickImage,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_photo_alternate_rounded,
                                        size: 36,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'แตะเพื่อเลือกรูปภาพปกจากอุปกรณ์',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'รองรับไฟล์ JPG, PNG, WEBP (สูงสุด 10MB)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),
                    // Optional Manual URL Expandable
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() => _showManualUrlInput = !_showManualUrlInput);
                        },
                        icon: Icon(
                          _showManualUrlInput ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _showManualUrlInput ? 'ซ่อนการระบุ URL รูปภาพ' : 'หรือระบุเป็นลิงก์ URL ของรูปภาพ',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                    if (_showManualUrlInput) ...[
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _coverUrlController,
                        decoration: const InputDecoration(
                          hintText: 'https://images.unsplash.com/...',
                          prefixIcon: Icon(Icons.link_rounded),
                          labelText: 'ลิงก์ภาพปก (Image URL)',
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Title Field
                    const Text(
                      'ชื่อเรื่อง *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'เช่น ข้ามภพมาเป็นยอดคหบดี',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'กรุณาระบุชื่อเรื่อง';
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    // Description Field
                    const Text(
                      'เรื่องย่อ / คำโปรย',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'บรรยายเรื่องย่อที่น่าสนใจเพื่อดึงดูดใจนักอ่าน...',
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Text(_isUploadingImage ? 'กำลังอัปโหลดรูปภาพ...' : 'กำลังเผยแพร่นิยาย...'),
                              ],
                            )
                          : const Text('เผยแพร่นิยาย', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
