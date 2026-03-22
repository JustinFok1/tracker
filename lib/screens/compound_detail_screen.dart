import 'package:flutter/material.dart';
import '../models/compound.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Compound compound;

  const CompoundDetailScreen({super.key, required this.compound});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text(compound.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Category Tag
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                compound.category,
                style: const TextStyle(color: Colors.purple),
              ),
            ),

            const SizedBox(height: 20),

            /// Description Card
            Container(
              width: double.infinity,
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
              child: Text(
                compound.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            /// Placeholder sections (you’ll expand later)
            _infoTile("Dosage", "Coming soon"),
            const SizedBox(height: 12),
            _infoTile("Half-life", "Coming soon"),
            const SizedBox(height: 12),
            _infoTile("Frequency", "Coming soon"),

            const Spacer(),

            /// Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // future: add to tracker
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB388FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Add to Tracker"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}