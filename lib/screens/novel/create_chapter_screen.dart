import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/novel_provider.dart';

class CreateChapterScreen extends StatefulWidget {
  final String novelId;
  final int nextChapterNumber;

  const CreateChapterScreen({
    super.key,
    required this.novelId,
    required this.nextChapterNumber,
  });

  @override
  State<CreateChapterScreen> createState() => _CreateChapterScreenState();
}

class _CreateChapterScreenState extends State<CreateChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.nextChapterNumber.toString());
  }

  @override
  void dispose() {
    _numberController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final novelProvider = context.read<NovelProvider>();
      final chapterNum = int.tryParse(_numberController.text) ?? widget.nextChapterNumber;

      await novelProvider.saveChapter(
        novelId: widget.novelId,
        chapterNumber: chapterNum,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เผยแพร่ตอนใหม่สำเร็จ!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('บันทึกตอนไม่สำเร็จ: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('แต่งตอนใหม่'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('เผยแพร่', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ตอนที่ *',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _numberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '1'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'ใส่เลขตอน';
                              if (int.tryParse(v) == null) return 'ตัวเลข';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ชื่อตอน *',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'เช่น จุดเริ่มต้นของการเดินทาง',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'กรุณาระบุชื่อตอน';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'เนื้อหาประจำตอน *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 18,
                  decoration: const InputDecoration(
                    hintText: 'พิมพ์เนื้อเรื่องนิยายของคุณที่นี่...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'กรุณาใส่เนื้อหานิยาย';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: const Text('เผยแพร่ตอนนี้เลย'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
