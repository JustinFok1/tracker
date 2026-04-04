import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/compound.dart';

class CompoundDetailScreen extends StatelessWidget {
  final Compound compound;

  const CompoundDetailScreen({super.key, required this.compound});

  Color _categoryColor(String category) {
    switch (category) {
      case 'Peptide':        return Colors.tealAccent;
      case 'Hormone':        return Colors.orangeAccent;
      case 'Secretagogue':   return Colors.purpleAccent;
      case 'Oral Steroid':   return Colors.pinkAccent;
      case 'SARM':           return Colors.blueAccent;
      default:               return Colors.purple;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Peptide':        return Icons.biotech;
      case 'Hormone':        return Icons.bolt;
      case 'Secretagogue':   return Icons.trending_up;
      case 'Oral Steroid':   return Icons.medication;
      case 'SARM':           return Icons.science;
      default:               return Icons.science;
    }
  }

  // Static compound data
  Map<String, String> _getDetails() {
    switch (compound.name) {
      case 'BPC-157':
        return {
          'Dosage':    '200–500 mcg/day',
          'Half-life': '~4 hours',
          'Frequency': 'Once or twice daily',
          'Route':     'Subcutaneous or IM injection',
          'Notes':     'Best taken near site of injury. Often stacked with TB-500 for enhanced healing.',
        };
      case 'TB-500':
        return {
          'Dosage':    '2–2.5 mg twice/week',
          'Half-life': 'Several days',
          'Frequency': 'Once Weekly',
          'Route':     'Subcutaneous injection',
          'Notes':     'Systemic peptide — no need to inject near injury site.',
        };
      case 'Testosterone Enanthate':
        return {
          'Dosage':    '250–500 mg/week',
          'Half-life': '~4.5 days',
          'Frequency': 'Once or twice weekly',
          'Route':     'Intramuscular injection',
          'Notes':     'PCT required after cycle. Common AI: Anastrozole or Aromasin.',
        };
      case 'MK-677':
        return {
          'Dosage':    '10–25 mg/day',
          'Half-life': '~24 hours',
          'Frequency': 'Once daily (before bed)',
          'Route':     'Oral',
          'Notes':     'Non-peptide GH secretagogue. Increases GH and IGF-1. May cause water retention and increased appetite.',
        };
      case 'Anavar':
        return {
          'Dosage':    '20–80 mg/day',
          'Half-life': '~9 hours',
          'Frequency': 'Split into 2 doses daily',
          'Route':     'Oral',
          'Notes':     'Mild hepatotoxicity. Commonly used in cutting cycles. Females: 5–20 mg/day.',
        };
      default:
        return {
          'Dosage':    'Varies',
          'Half-life': 'Varies',
          'Frequency': 'Varies',
          'Route':     'Varies',
          'Notes':     'Consult research literature for specific protocols.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(compound.category);
    final icon = _categoryIcon(compound.category);
    final details = _getDetails();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _header(context, color, icon),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description card
                          _descriptionCard(context, color),

                          const SizedBox(height: 20),

                          // Info tiles
                          _sectionLabel(context, "COMPOUND PROFILE"),
                          const SizedBox(height: 12),
                          ...details.entries
                              .where((e) => e.key != 'Notes')
                              .map((e) => _infoTile(context, e.key, e.value, color)),

                          const SizedBox(height: 20),

                          // Notes card
                          if (details.containsKey('Notes'))
                            _notesCard(details['Notes']!, color),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add to Tracker button
            _addButton(context, color),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            context.colors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compound.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        compound.category,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== DESCRIPTION CARD =====
  Widget _descriptionCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.cardAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              compound.description,
              style: TextStyle(
                  fontSize: 14, height: 1.5, color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ===== SECTION LABEL =====
  Widget _sectionLabel(BuildContext context, String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.border, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== INFO TILE =====
  Widget _infoTile(BuildContext context, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border2),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ===== NOTES CARD =====
  Widget _notesCard(String notes, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                  fontSize: 13, height: 1.5, color: color.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  // ===== ADD BUTTON =====
  Widget _addButton(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.card)),
      ),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              "Add to Tracker",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}