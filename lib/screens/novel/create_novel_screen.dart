import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/novel_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../main_nav_screen.dart';
import 'novel_detail_screen.dart';

class CreateNovelScreen extends StatefulWidget {
  final VoidCallback? onCancel;

  const CreateNovelScreen({super.key, this.onCancel});

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
  String? _selectedPresetUrl;

  final List<Map<String, String>> _presetCovers = [
    {
      'title': 'กำลังภายใน/แฟนตาซี',
      'url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'รักโรแมนติก',
      'url': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'ไซไฟ/โลกอนาคต',
      'url': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'ชีวิตอบอุ่น/คาเฟ่',
      'url': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'เวทมนตร์/ผจญภัย',
      'url': 'https://images.unsplash.com/photo-1514533450685-4493e01d1fdc?w=600&auto=format&fit=crop&q=80',
    },
    {
      'title': 'ลึกลับ/สืบสวน',
      'url': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  void _handleExit(BuildContext context) {
    final hasContent = _titleController.text.trim().isNotEmpty ||
        _descController.text.trim().isNotEmpty ||
        _selectedImageBytes != null ||
        _coverUrlController.text.trim().isNotEmpty;

    if (hasContent) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
              SizedBox(width: 10),
              Text('ละทิ้งการเปลี่ยนแปลง?'),
            ],
          ),
          content: const Text(
            'คุณมีข้อมูลนิยายที่ยังไม่ได้เผยแพร่ หากออกจากหน้านี้ข้อมูลที่กรอกไว้จะสูญหาย',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('แต่งนิยายต่อ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doExit();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('ละทิ้งและออก'),
            ),
          ],
        ),
      );
    } else {
      _doExit();
    }
  }

  void _doExit() {
    _titleController.clear();
    _descController.clear();
    _coverUrlController.clear();
    _clearSelectedImage();

    if (widget.onCancel != null) {
      widget.onCancel!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen(initialIndex: 0)),
      );
    }
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
          _selectedPresetUrl = null;
          _coverUrlController.clear();
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
      _selectedPresetUrl = null;
    });
  }

  void _selectPresetCover(String url) {
    setState(() {
      _selectedPresetUrl = url;
      _coverUrlController.text = url;
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
          content: Text('กรุณาเข้าสู่ระบบก่อนสร้างนิยาย เพื่อบันทึกผลงานลงในบัญชีของคุณ'),
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

      // If user selected an image file from their device, upload or convert to Data URI
      if (_selectedImageBytes != null) {
        setState(() => _isUploadingImage = true);
        try {
          final uploadedUrl = await novelProvider.uploadCoverImage(
            imageBytes: _selectedImageBytes!,
            filename: _selectedImageName ?? 'novel_cover.jpg',
          );
          finalCoverUrl = uploadedUrl;
        } catch (_) {
          // Fallback handled in repo
        } finally {
          if (mounted) setState(() => _isUploadingImage = false);
        }
      } else if (_selectedPresetUrl != null) {
        finalCoverUrl = _selectedPresetUrl!;
      }

      if (!mounted) return;

      final auth = context.read<AuthProvider>();
      final currentUser = auth.user;

      final created = await novelProvider.createNovel(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        coverUrl: finalCoverUrl.isNotEmpty ? finalCoverUrl : null,
        authorId: currentUser?.id,
        authorName: currentUser?.username,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างและบันทึกนิยายสำเร็จเรียบร้อย!'),
            backgroundColor: AppTheme.success,
          ),
        );

        // Reset inputs
        _titleController.clear();
        _descController.clear();
        _coverUrlController.clear();
        _clearSelectedImage();

        // Safely push to novel detail without destroying main nav
        Navigator.push(
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
            content: Text('เกิดข้อผิดพลาดในการบันทึก: ${e.toString().replaceAll("Exception: ", "")}'),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleExit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'กลับไปหน้าสำรวจ',
            onPressed: () => _handleExit(context),
          ),
          title: const Text('แต่งนิยายเรื่องใหม่'),
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('เผยแพร่', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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

                      // Cover Image Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ภาพปกนิยาย',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          if (_selectedImageBytes != null || _selectedPresetUrl != null || _coverUrlController.text.isNotEmpty)
                            TextButton.icon(
                              onPressed: _clearSelectedImage,
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.error),
                              label: const Text('ล้างรูปภาพ', style: TextStyle(color: AppTheme.error, fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Active Cover Preview or Upload Box
                      Center(
                        child: _buildCoverPreviewOrPicker(),
                      ),

                      const SizedBox(height: 16),

                      // Preset Covers Grid (ใช้ Grid View อย่างคุ้มค่า)
                      const Text(
                        'หรือเลือกภาพปกสำเร็จรูปจากคลัง (Cover Presets)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 135,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: _presetCovers.length,
                          itemBuilder: (context, index) {
                            final preset = _presetCovers[index];
                            final isSelected = _selectedPresetUrl == preset['url'];
                            return GestureDetector(
                              onTap: () => _selectPresetCover(preset['url']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primary : Colors.transparent,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isSelected ? 0.25 : 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        preset['url']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.image, color: Colors.white54),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.75),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            preset['title']!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          color: AppTheme.primary.withOpacity(0.3),
                                          child: const Center(
                                            child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Manual URL Expandable
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
                          onChanged: (val) {
                            setState(() {
                              _selectedPresetUrl = null;
                              _selectedImageBytes = null;
                            });
                          },
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
                                  Text(_isUploadingImage ? 'กำลังเตรียมภาพปก...' : 'กำลังเผยแพร่นิยาย...'),
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
      ),
    );
  }

  Widget _buildCoverPreviewOrPicker() {
    if (_selectedImageBytes != null) {
      return Column(
        children: [
          Container(
            width: 150,
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _pickImage,
            icon: const Icon(Icons.sync_rounded, size: 16),
            label: const Text('เปลี่ยนรูปภาพ', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    if (_selectedPresetUrl != null || _coverUrlController.text.isNotEmpty) {
      final url = _selectedPresetUrl ?? _coverUrlController.text.trim();
      return Column(
        children: [
          Container(
            width: 150,
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSubmitting ? null : _pickImage,
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: const Text('อัปโหลดภาพจากเครื่องแทน', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _isSubmitting ? null : _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 170,
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
            const SizedBox(height: 10),
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
              'หรือเลือกจากภาพปกสำเร็จรูปด้านล่าง',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
