import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['ทั้งหมด', 'ตอนใหม่', 'ความคิดเห็น', 'ระบบ'];
  bool _isBannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBannerDismissedState();
  }

  Future<void> _loadBannerDismissedState() async {
    try {
      final auth = context.read<AuthProvider>();
      final key = 'line_oa_banner_dismissed_${auth.user?.id ?? "guest"}';
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isBannerDismissed = prefs.getBool(key) ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _dismissBanner() async {
    try {
      final auth = context.read<AuthProvider>();
      final key = 'line_oa_banner_dismissed_${auth.user?.id ?? "guest"}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
    if (mounted) {
      setState(() => _isBannerDismissed = true);
    }
  }

  void _showLineConnectDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF161722),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06C755).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF06C755), size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รับแจ้งเตือนผ่าน LINE OA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'สแกนเพียง 1 ครั้งต่อผู้ใช้',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AppConfig.lineOaQrAsset,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 180,
                        height: 180,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'แจ้งเตือนตอนใหม่จะส่งเข้า LINE โดยตรง ไม่รบกวนหน้าเว็บ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: () => launchUrlString(AppConfig.lineOaUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('เปิดแอป LINE เพื่อเพิ่มเพื่อน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06C755),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),

                OutlinedButton.icon(
                  onPressed: () async {
                    await auth.fetchLineStatus();
                    if (ctx.mounted) {
                      if (auth.isLineLinked) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ผูกบัญชี LINE เรียบร้อยแล้ว!'),
                            backgroundColor: Color(0xFF06C755),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('แอดเพื่อนแล้วสามารถเปิดอ่านและรับแจ้งเตือนได้เลย'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16, color: Color(0xFF94A3B8)),
                  label: const Text('ตรวจสอบสถานะ', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    side: const BorderSide(color: Color(0xFF2E3147)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การแจ้งเตือนและคอมมูนิตี้',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'การแจ้งเตือน'),
            Tab(text: 'ห้องพูดคุยนักอ่าน'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildCommunityTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    final auth = context.watch<AuthProvider>();
    final bool isLinked = auth.isLineLinked;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If already linked: show a subtle status pill so it doesn't annoy the user
          if (isLinked)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF06C755).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06C755).withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF06C755), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ผูก LINE OA แล้ว • ระบบจะส่งแจ้งเตือนตอนใหม่ผ่าน LINE โดยตรง',
                      style: TextStyle(color: Color(0xFF06C755), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          // If not linked and not dismissed: show LINE OA card (1 scan per user, dismissible)
          else if (!_isBannerDismissed)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3A22), Color(0xFF161822)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF06C755).withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF06C755),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'รับแจ้งเตือนผ่าน LINE OA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'สแกน 1 ครั้งเพื่อรับการแจ้งเตือนตอนใหม่ผ่านแชท LINE โดยตรง ไม่รบกวนหน้าเว็บ',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => _showLineConnectDialog(context),
                          icon: const Icon(Icons.qr_code_rounded, size: 16),
                          label: const Text('เชื่อมต่อ LINE Official Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06C755),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    tooltip: 'ซ่อนการแจ้งเตือนนี้',
                    onPressed: _dismissBanner,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Filter Chips (Matching Screenshot 3)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) {
                final isSelected = _selectedFilterIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filters[i]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilterIndex = i);
                    },
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    backgroundColor: const Color(0xFF1B1C26),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : const Color(0xFF27293A),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 40),

          // Empty state with Bell (Matching Screenshot 3)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1B24),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2B2D3C)),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'ไม่มีการแจ้งเตือนใหม่',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'การแจ้งเตือนจะปรากฏที่นี่และส่งตรงไปยัง LINE OA',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    final discussions = [
      {'title': 'ห้องพูดคุยนักอ่าน: หวนคืนสู่บัลลังก์จอมราชันย์', 'author': 'หลินเฟิงแฟนคลับ', 'replies': '28'},
      {'title': 'แชร์เทคนิคการเปิดเรื่องนิยายให้น่าติดตาม', 'author': 'พยัคฆ์ทมิฬคำราม', 'replies': '45'},
      {'title': 'แนะนำนิยายสายไซไฟ-โลกอนาคต ประจำสัปดาห์', 'author': 'NeonGhost', 'replies': '19'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: discussions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final d = discussions[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161722),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF262838)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: const Icon(Icons.forum_rounded, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'โดย ${d['author']} • ${d['replies']} ความคิดเห็น',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
            ],
          ),
        );
      },
    );
  }
}
