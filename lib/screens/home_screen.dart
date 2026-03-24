import 'package:flutter/material.dart';
import '../widgets/dose_card.dart';
import '../widgets/section_tile.dart';
import 'calender_screen.dart';
import 'research_screen.dart';
import 'add_schedule_screen.dart';
import '../data/schedule_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 20),

              /// Top Cards
              Row(
                children: [
                  const Expanded(child: DoseCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _nextDoseCard(context)),
                ],
              ),

              const SizedBox(height: 20),

              /// Sections
              SectionTile(
                title: "Dose History",
                subtitle: "View and edit your dosing history",
                onTap: () {},
              ),

              const SizedBox(height: 12),

              SectionTile(
                title: "AI Insights",
                subtitle: "Patterns and correlations in your data",
                onTap: () {},
              ),

              const SizedBox(height: 12),

              SectionTile(
                title: "Research Library",
                subtitle: "Browse compounds",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResearchScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== HEADER =====
  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Pep AI",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.purple),
            const SizedBox(width: 12),

            /// CALENDAR BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.chat_bubble_outline),
            ),
          ],
        )
      ],
    );
  }

  /// ===== NEXT DOSE CARD (NEW) =====
  Widget _nextDoseCard(BuildContext context) {
    final schedules = ScheduleStore.instance.schedules;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF222222),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                "NEXT DOSE",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                const Icon(Icons.calendar_month,
                    size: 40, color: Colors.purple),
                const SizedBox(height: 10),

                Text(
                  schedules.isEmpty
                      ? "No schedule set"
                      : "Scheduled",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddScheduleScreen(),
                      ),
                    );
                  },
                  child: const Text("+ Add Schedule"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}