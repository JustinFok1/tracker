import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_compounds.dart';
import '../models/compound.dart';
import 'compound_detail_screen.dart';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  String searchQuery = "";
  String? selectedCategory;

  List<String> get categories {
    final cats = allCompounds.map((c) => c.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Compound> get filteredCompounds {
    return allCompounds.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              c.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == null || c.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Peptide':
        return Colors.tealAccent;
      case 'Injectable':
        return Colors.orangeAccent;
      case 'Oral':
        return Colors.pinkAccent;
      case 'SARM':
        return Colors.blueAccent;
      default:
        return Colors.purple;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Peptide':
        return Icons.biotech;
      case 'Injectable':
        return Icons.colorize_outlined;
      case 'Oral':
        return Icons.medication;
      case 'SARM':
        return Icons.science;
      default:
        return Icons.science;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _searchBar(),
            const SizedBox(height: 12),
            _categoryFilter(),
            const SizedBox(height: 16),
            _resultsLabel(),
            const SizedBox(height: 10),
            Expanded(child: _compoundList()),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Research Library",
                style:
                TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Browse compounds & peptides",
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== SEARCH BAR =====
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey, size: 18),
            hintText: "Search compounds...",
            hintStyle: TextStyle(color: context.colors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ===== CATEGORY FILTER =====
  Widget _categoryFilter() {
    return SizedBox(
      height: 34,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _filterChip("All", null),
          ...categories.map((cat) => _filterChip(cat, cat)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = selectedCategory == value;
    final color = value != null ? _categoryColor(value) : Colors.purple;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withOpacity(0.6) : context.colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ===== RESULTS LABEL =====
  Widget _resultsLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "${filteredCompounds.length} compound${filteredCompounds.length != 1 ? 's' : ''}",
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ===== COMPOUND LIST =====
  Widget _compoundList() {
    if (filteredCompounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.search_off,
                  color: Colors.grey, size: 24),
            ),
            const SizedBox(height: 12),
            Text("No compounds found",
                style: TextStyle(color: context.colors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredCompounds.length,
      itemBuilder: (context, index) {
        final compound = filteredCompounds[index];
        final color = _categoryColor(compound.category);
        final icon = _categoryIcon(compound.category);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompoundDetailScreen(compound: compound),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.cardAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.colors.border2),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compound.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              compound.category,
                              style: TextStyle(
                                  color: color, fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        compound.description,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}