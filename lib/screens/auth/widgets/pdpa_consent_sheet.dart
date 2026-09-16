import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/local_novel_storage.dart';

class PdpaConsentSheet extends StatefulWidget {
  final VoidCallback onAccepted;

  const PdpaConsentSheet({super.key, required this.onAccepted});

  static Future<bool> show(BuildContext context, {required VoidCallback onAccepted}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PdpaConsentSheet(onAccepted: onAccepted),
    );
    return result ?? false;
  }

  @override
  State<PdpaConsentSheet> createState() => _PdpaConsentSheetState();
}

class _PdpaConsentSheetState extends State<PdpaConsentSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _pdpaChecked = false;
  bool _copyrightChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    await LocalNovelStorage.setConsentAccepted(true);
    widget.onAccepted();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag pill
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อกำหนดและความเป็นส่วนตัว',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'พ.ร.บ. คุ้มครองข้อมูลส่วนบุคคล และกฎหมายลิขสิทธิ์',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.privacy_tip_outlined, size: 18),
                    text: 'นโยบาย PDPA',
                  ),
                  Tab(
                    icon: Icon(Icons.copyright_rounded, size: 18),
                    text: 'ลิขสิทธิ์เนื้อหา',
                  ),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPdpaContent(scrollController),
                    _buildCopyrightContent(scrollController),
                  ],
                ),
              ),

              // Acceptance controls bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor.withOpacity(0.15),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _pdpaChecked && _copyrightChecked,
                          activeColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            setState(() {
                              _pdpaChecked = val ?? true;
                              _copyrightChecked = val ?? true;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                final newVal = !(_pdpaChecked && _copyrightChecked);
                                _pdpaChecked = newVal;
                                _copyrightChecked = newVal;
                              });
                            },
                            child: const Text(
                              'ฉันได้อ่าน ทำความเข้าใจ และยอมรับข้อกำหนด PDPA และกฎหมายลิขสิทธิ์ข้างต้นทุกประการ',
                              style: TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('ปฏิเสธ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: (_pdpaChecked && _copyrightChecked) ? _handleAccept : null,
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('ยอมรับและดำเนินการต่อ'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdpaContent(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegalHeader(
            title: 'นโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
            subtitle: 'ตามพระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562',
          ),
          const SizedBox(height: 16),
          _buildClause(
            number: '1. ข้อมูลส่วนบุคคลที่เราจัดเก็บ',
            text:
                'เพื่อให้บริการแอปพลิเคชันอย่างเต็มประสิทธิภาพ แพลตฟอร์มอาจจัดเก็บข้อมูล ได้แก่ บัญชีผู้ใช้งาน (อีเมล, ชื่อผู้ใช้, รูปโปรไฟล์), รหัสประจำตัว Google/LINE (เมื่อเลือกผูกบัญชี), บันทึกการเข้าอ่านนิยาย, ประวัติการจัดเก็บชั้นหนังสือ และความคิดเห็นที่เผยแพร่',
          ),
          _buildClause(
            number: '2. วัตถุประสงค์ในการประมวลผลข้อมูล',
            text:
                '• ยืนยันตัวตนและรักษาความปลอดภัยของบัญชีผู้ใช้\n• ซิงก์ประวัติการอ่านและชั้นหนังสือข้ามอุปกรณ์\n• จัดส่งการแจ้งเตือนตอนใหม่ผ่านระบบ หรือ LINE Official Account ตามที่ท่านยินยอม\n• พัฒนาและปรับปรุงประสบการณ์การอ่านให้ตรงความสนใจ',
          ),
          _buildClause(
            number: '3. สิทธิของเจ้าของข้อมูลส่วนบุคคล',
            text:
                'ท่านมีสิทธิในการขอเข้าถึง ขอสำเนา ขอแก้ไขข้อมูลให้ถูกต้อง ขอโอนย้าย หรือขอให้ลบ/ทำลายข้อมูลส่วนบุคคลของท่านได้ทุกเมื่อ โดยสามารถส่งคำขอผ่านหน้าโปรไฟล์หรือติดต่อทีมงานผู้ดูแลระบบ',
          ),
          _buildClause(
            number: '4. มาตรการรักษาความปลอดภัย',
            text:
                'เราใช้การเข้ารหัสข้อมูลมาตรฐานอุตสาหกรรม (Encryption in transit & at rest) และโทเค็น JWT เพื่อป้องกันการเข้าถึงข้อมูลส่วนบุคคลของท่านโดยมิชอบอย่างเข้มงวด',
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightContent(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegalHeader(
            title: 'ข้อตกลงและกฎหมายลิขสิทธิ์เนื้อหา',
            subtitle: 'ตามพระราชบัญญัติลิขสิทธิ์ พ.ศ. 2537 และที่แก้ไขเพิ่มเติม',
          ),
          const SizedBox(height: 16),
          _buildClause(
            number: '1. ความเป็นเจ้าของลิขสิทธิ์',
            text:
                'งานเขียน นวนิยาย เรื่องสั้น บทประพันธ์ ภาพประกอบ และเนื้อหาทั้งหมดที่เผยแพร่บน Rels Reading ถือเป็นทรัพย์สินทางปัญญาและลิขสิทธิ์ของนักเขียนหรือผู้สร้างสรรค์แต่เพียงผู้เดียว การเผยแพร่บนแพลตฟอร์มนี้มิใช่การสละสิทธิในความเป็นเจ้าของ',
          ),
          _buildClause(
            number: '2. ข้อห้ามในการละเมิดลิขสิทธิ์',
            text:
                '• ห้ามคัดลอก (Copy) ทำซ้ำ ดัดแปลง ปรับแก้ หรือแปลเนื้อหาโดยไม่ได้รับอนุญาตเป็นลายลักษณ์อักษร\n• ห้ามนำเนื้อหาหรือภาพปกไปเผยแพร่ต่อบนเว็บไซต์ แอปพลิเคชัน โซเชียลมีเดีย หรือสื่อสิ่งพิมพ์อื่นใด\n• ห้ามนำเนื้อหาไปใช้ในการฝึกฝนโมเดล AI (Machine Learning) เชิงพาณิชย์โดยมิได้รับอนุญาต',
          ),
          _buildClause(
            number: '3. ความรับผิดชอบของนักเขียน',
            text:
                'ผู้แต่งต้องรับรองว่าผลงานที่ลงเผยแพร่เป็นผลงานที่สร้างสรรค์ขึ้นด้วยตนเอง ไม่ลอกเลียนแบบ หรือละเมิดลิขสิทธิ์ของบุคคลภายนอก หากเกิดข้อพิพาท ผู้แต่งต้องเป็นผู้รับผิดชอบตามกฎหมาย',
          ),
          _buildClause(
            number: '4. มาตรการลงโทษเมื่อตรวจพบการละเมิด',
            text:
                'หากพบการละเมิดลิขสิทธิ์ แพลตฟอร์มจะดำเนินการลบเนื้อหาทันทีโดยมิต้องแจ้งล่วงหน้า และขอสงวนสิทธิ์ในการระงับบัญชีผู้ใช้งานถาวร พร้อมสนับสนุนข้อมูลแก่เจ้าของลิขสิทธิ์ในการดำเนินคดีตามกฎหมาย',
          ),
        ],
      ),
    );
  }

  Widget _buildLegalHeader({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel_rounded, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClause({required String number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
