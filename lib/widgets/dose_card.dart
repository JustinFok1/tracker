import 'package:flutter/material.dart';

class DoseCard extends StatelessWidget {
  const DoseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: _cardStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("LAST DOSE", style: TextStyle(color: Colors.grey)),
          Spacer(),
          Text(
            "Log your first dose",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardStyle() {
  return BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(20),
  );
}