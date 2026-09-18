import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStreak = 7;
  int _maxStreak = 14;
  int _streakRecovery = 2;
  bool _hasCheckedInToday = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStreakData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckIn = prefs.getString('last_checkin_date');
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _currentStreak = prefs.getInt('current_streak') ?? 7;
      _maxStreak = prefs.getInt('max_streak') ?? 14;
      _streakRecovery = prefs.getInt('streak_recovery') ?? 2;
      _hasCheckedInToday = (lastCheckIn == todayStr);
    });
  }

  Future<void> _handleCheckIn() async {
    if (_hasCheckedInToday) return;

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final newStreak = _currentStreak + 1;
    final newMax = newStreak > _maxStreak ? newStreak : _maxStreak;

    await prefs.setString('last_checkin_date', todayStr);
    await prefs.setInt('current_streak', newStreak);
    await prefs.setInt('max_streak', newMax);

    setState(() {
      _currentStreak = newStreak;
      _maxStreak = newMax;
      _hasCheckedInToday = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.onPrimary),
              const SizedBox(width: 12),
              Text(
                'เช็คอินสำเร็จ! สตรีคปัจจุบัน: $_currentStreak วันต่อเนื่อง 🔥',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onPrimary),
              ),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ภารกิจและกิจกรรม',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ติดตามการอ่าน ทำภารกิจรายวันเพื่อรักษาสตรีคของคุณ',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Community Banner (Matching Screenshot 4)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161722),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF262838)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'เข้าร่วมคอมมูนิตี้ Rels Reading',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ติดตามข่าวสาร อัปเดตนิยายใหม่ และกิจกรรมพิเศษมากมาย',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrlString(AppConfig.lineOaUrl),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                          label: const Text('LINE OA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06C755),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ช่องทาง Discord ยังไม่เปิดให้บริการ จะเปิดให้บริการเร็วๆ นี้ครับ'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forum_rounded, size: 16, color: Colors.white),
                          label: const Text('Discord (เร็วๆ นี้)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5865F2),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Buttons
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF262838), width: 1)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'เช็คอินรายวัน'),
                  Tab(text: 'กิจกรรม & การอ่าน'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3 Streak Metric Cards (Matching Screenshot 4)
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.calendar_month_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    title: 'เช็คอินติดต่อกัน\nนานที่สุด',
                    value: '$_maxStreak วัน',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'สถิติปัจจุบัน\n',
                    value: '$_currentStreak วัน',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFF97316),
                    title: 'สิทธิ์กู้คืนสตรีค\n',
                    value: '$_streakRecovery ครั้ง',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Check-in Card (Matching Screenshot 4)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161722),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF262838)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_getMonthName(DateTime.now().month)} ${DateTime.now().year + 543}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF64748B)),
                          SizedBox(width: 4),
                          Text(
                            'รีเซ็ต 00:00 น.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7 Days Week Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final isChecked = i < (_currentStreak % 7 == 0 && _currentStreak > 0 ? 7 : _currentStreak % 7);
                      return Column(
                        children: [
                          Text('วันที่ $dayNum', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          const SizedBox(height: 6),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isChecked ? AppTheme.primary : const Color(0xFF222432),
                              border: Border.all(
                                color: isChecked ? AppTheme.primary : const Color(0xFF33364A),
                              ),
                            ),
                            child: Icon(
                              isChecked ? Icons.check_rounded : Icons.local_fire_department_rounded,
                              size: 18,
                              color: isChecked ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Check In Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _hasCheckedInToday ? null : _handleCheckIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor: const Color(0xFF252838),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _hasCheckedInToday ? '✓ เช็คอินวันนี้แล้ว' : '🔥 กดเช็คอินรักษาสตรีควันนี้',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _hasCheckedInToday ? const Color(0xFF64748B) : AppTheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF262838)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return months[month - 1];
  }
}
