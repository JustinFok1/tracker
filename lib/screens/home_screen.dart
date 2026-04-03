import 'package:flutter/material.dart';
import '../widgets/dose_card.dart';
import '../widgets/section_tile.dart';
import 'calender_screen.dart';
import 'research_screen.dart';
import 'add_schedule_screen.dart';
import '../data/schedule_store.dart';
import '../data/dose_log_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ScheduleStore.instance.addListener(_refresh);
    DoseLogStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ScheduleStore.instance.removeListener(_refresh);
    DoseLogStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _topCards(context),
              const SizedBox(height: 20),
              _statsStrip(),
              const SizedBox(height: 24),
              _sectionLabel("QUICK ACCESS"),
              const SizedBox(height: 12),
              _navTile(
                icon: Icons.history,
                iconColor: Colors.purpleAccent,
                title: "Dose History",
                subtitle: "View and edit your dosing history",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarScreen())),
              ),
              const SizedBox(height: 10),
              _navTile(
                icon: Icons.science_outlined,
                iconColor: Colors.tealAccent,
                title: "Research Library",
                subtitle: "Browse compounds & peptides",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ResearchScreen())),
              ),
              const SizedBox(height: 10),
              _navTile(
                icon: Icons.calendar_month_outlined,
                iconColor: Colors.pinkAccent,
                title: "Schedule",
                subtitle: "Manage your dosing schedule",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AddScheduleScreen())),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? "Good morning"
        : hour < 17
        ? "Good afternoon"
        : "Good evening";

    final now = DateTime.now();
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    final dateStr =
        "${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 2),
            const Text(
              "Track Lab",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              dateStr,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Row(
          children: [
            _headerIcon(Icons.flash_on, Colors.purple),
            const SizedBox(width: 10),
            _headerIcon(Icons.calendar_today, Colors.white70, onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()));
            }),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // ===== TOP CARDS =====
  Widget _topCards(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DoseCard()),
        const SizedBox(width: 12),
        Expanded(child: _nextDoseCard(context)),
      ],
    );
  }

  Widget _nextDoseCard(BuildContext context) {
    final schedules = ScheduleStore.instance.schedules;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find next unchecked dose — today first, then future days
    String? nextCompound;
    String? nextDose;
    bool isToday = false;

    for (int i = 0; i <= 7; i++) {
      final day = today.add(Duration(days: i));
      final daySchedules = schedules.where((s) =>
      !day.isBefore(DateTime(s.startDate.year, s.startDate.month, s.startDate.day)) &&
          s.daysOfWeek.contains(day.weekday));

      for (final s in daySchedules) {
        final key = "${s.compoundName}_${s.dosage}_${s.unit}";
        final taken = DoseLogStore.instance.isTaken(key, day);
        if (!taken) {
          nextCompound = s.compoundName;
          nextDose = "${s.dosage}${s.unit}";
          isToday = i == 0;
          break;
        }
      }
      if (nextCompound != null) break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF222222)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.purple, size: 14),
              SizedBox(width: 6),
              Text("NEXT DOSE",
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          if (nextCompound == null) ...[
            const Icon(Icons.calendar_month, size: 32, color: Colors.purple),
            const SizedBox(height: 8),
            const Text("No schedule",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const AddScheduleScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("+ Add",
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isToday ? "TODAY" : "UPCOMING",
                style: TextStyle(
                  color: isToday ? Colors.orange : Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nextCompound!,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(nextDose!,
                  style: const TextStyle(
                      color: Colors.purple, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  // ===== STATS STRIP =====
  Widget _statsStrip() {
    final schedules = ScheduleStore.instance.schedules;
    final compoundKeys = schedules
        .map((s) => "${s.compoundName}_${s.dosage}_${s.unit}")
        .toSet()
        .toList();

    final dosesThisWeek =
    DoseLogStore.instance.dosesThisWeek(compoundKeys);
    final streak = DoseLogStore.instance.currentStreak(compoundKeys);
    final onCycle = schedules.map((s) => s.compoundName).toSet().length;

    return Row(
      children: [
        _miniStat("${dosesThisWeek}", "This Week", Icons.check_circle_outline,
            Colors.purple),
        const SizedBox(width: 10),
        _miniStat("${streak}d", "Streak", Icons.local_fire_department,
            streak >= 7 ? Colors.orange : Colors.purple),
        const SizedBox(width: 10),
        _miniStat("${onCycle}", "On Cycle", Icons.science, Colors.tealAccent),
      ],
    );
  }

  Widget _miniStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ===== SECTION LABEL =====
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2A2A2A), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== NAV TILE =====
  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF1E1E1E)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}