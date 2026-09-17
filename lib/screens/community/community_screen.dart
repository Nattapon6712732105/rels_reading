import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['ทั้งหมด', 'ตอนใหม่', 'ความคิดเห็น', 'ระบบ'];

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LINE OA Notification Link Card (As requested: "การแจ้งเตือนทำผ่านline oa เอานะครับ")
          Container(
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
                        'แจ้งเตือนทันทีเมื่อมีตอนใหม่อัปเดต และข้อความจากนักเขียน',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => launchUrlString(AppConfig.lineOaUrl),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
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
