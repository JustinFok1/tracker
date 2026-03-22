import 'package:flutter/material.dart';
import '../widgets/dose_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/section_tile.dart';
import '../widgets/bottom_nav.dart';
import 'research_screen.dart';

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
              _header(),
              const SizedBox(height: 20),

              /// Top Cards
              Row(
                children: const [
                  Expanded(child: DoseCard()),
                  SizedBox(width: 12),
                  Expanded(child: ScheduleCard()),
                ],
              ),

              const SizedBox(height: 20),

              /// Sections
              SectionTile(
                title: "Dose History",
                subtitle: "View and edit your dosing history",
                onTap: () {
                  // future screen
                },
              ),

              const SizedBox(height: 12),

              SectionTile(
                title: "AI Insights",
                subtitle: "Patterns and correlations in your data",
                onTap: () {
                  // future screen
                },
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

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Pep AI",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.chat_bubble_outline),
        )
      ],
    );
  }
}