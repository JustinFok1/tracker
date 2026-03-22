import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Text("NEXT DOSE", style: TextStyle(color: Colors.grey)),
          Spacer(),
          Icon(Icons.calendar_today, color: Colors.purple),
          SizedBox(height: 8),
          Text("No schedule set"),
        ],
      ),
    );
  }
}