import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text("NEXT DOSE", style: TextStyle(color: context.colors.textSecondary)),
          const Spacer(),
          const Icon(Icons.calendar_today, color: Colors.purple),
          const SizedBox(height: 8),
          const Text("No schedule set"),
        ],
      ),
    );
  }
}