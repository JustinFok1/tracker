import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_compounds.dart';
import '../data/custom_compound_store.dart';
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

  @override
  void initState() {
    super.initState();
    CustomCompoundStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    CustomCompoundStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<Compound> get _allCompounds => [
        ...allCompounds,
        ...CustomCompoundStore.instance.compounds,
      ];

  List<String> get categories {
    final cats = _allCompounds.map((c) => c.category).toSet().toList();
    cats.sort();
    return cats;
  }

  static const _myCompoundsKey = '__custom__';

  List<Compound> get filteredCompounds {
    return _allCompounds.where((c) {
      final q = searchQuery.toLowerCase();
      final matchesSearch =
          c.name.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q) ||
              (c.genericName?.toLowerCase().contains(q) ?? false);
      final matchesCategory = selectedCategory == null
          ? true
          : selectedCategory == _myCompoundsKey
              ? c.isCustom
              : c.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Peptide':    return Colors.tealAccent;
      case 'Injectable': return Colors.orangeAccent;
      case 'Oral':       return Colors.pinkAccent;
      default:           return Colors.purple;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Peptide':    return Icons.biotech;
      case 'Injectable': return Icons.colorize_outlined;
      case 'Oral':       return Icons.medication;
      default:           return Icons.science;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCompoundForm(context),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.search, color: Colors.grey, size: 18),
            hintText: "Search compounds...",
            hintStyle: TextStyle(color: context.colors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
          if (CustomCompoundStore.instance.compounds.isNotEmpty)
            _filterChip("My Compounds", _myCompoundsKey),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = selectedCategory == value;
    final color = value == _myCompoundsKey
        ? Colors.purpleAccent
        : value != null
            ? _categoryColor(value)
            : Colors.purple;

    return GestureDetector(
      onTap: () => setState(() => selectedCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : context.colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : context.colors.border,
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
              child: const Icon(Icons.search_off, color: Colors.grey, size: 24),
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

        final tile = GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompoundDetailScreen(compound: compound),
            ),
          ),
          onLongPress: compound.isCustom
              ? () => _showCustomOptions(context, compound)
              : null,
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            compound.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (compound.isCustom) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.purpleAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Custom',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (compound.genericName != null)
                        Text(
                          compound.genericName!,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              compound.category,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        compound.description,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ),
        );

        if (!compound.isCustom) return tile;

        return Dismissible(
          key: ValueKey(compound.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => CustomCompoundStore.instance.delete(compound),
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
          ),
          child: tile,
        );
      },
    );
  }

  // ===== CUSTOM COMPOUND OPTIONS =====
  void _showCustomOptions(BuildContext context, Compound compound) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(compound.name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.tealAccent),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showCompoundForm(context, existing: compound);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await CustomCompoundStore.instance.delete(compound);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== ADD / EDIT FORM =====
  void _showCompoundForm(BuildContext context, {Compound? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompoundFormSheet(existing: existing),
    );
  }
}

// ===== COMPOUND FORM SHEET =====
class CompoundFormSheet extends StatefulWidget {
  final Compound? existing;
  const CompoundFormSheet({super.key, this.existing});

  @override
  State<CompoundFormSheet> createState() => _CompoundFormSheetState();
}

class _CompoundFormSheetState extends State<CompoundFormSheet> {
  final _nameCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _halfLifeCtrl = TextEditingController();
  final _frequencyCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Peptide';
  bool _saving = false;

  static const _categories = ['Peptide', 'Injectable', 'Oral'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _genericCtrl.text = e.genericName ?? '';
      _descCtrl.text = e.description;
      _category = e.category;
      _dosageCtrl.text = e.dosage ?? '';
      _halfLifeCtrl.text = e.halfLife ?? '';
      _frequencyCtrl.text = e.frequency ?? '';
      _routeCtrl.text = e.route ?? '';
      _notesCtrl.text = e.profileNotes ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _genericCtrl.dispose();
    _descCtrl.dispose();
    _dosageCtrl.dispose();
    _halfLifeCtrl.dispose();
    _frequencyCtrl.dispose();
    _routeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final compound = Compound(
        id: widget.existing?.id,
        name: name,
        category: _category,
        description: _descCtrl.text.trim(),
        genericName: _genericCtrl.text.trim().isEmpty ? null : _genericCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        halfLife: _halfLifeCtrl.text.trim().isEmpty ? null : _halfLifeCtrl.text.trim(),
        frequency: _frequencyCtrl.text.trim().isEmpty ? null : _frequencyCtrl.text.trim(),
        route: _routeCtrl.text.trim().isEmpty ? null : _routeCtrl.text.trim(),
        profileNotes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isCustom: true,
      );
      if (widget.existing != null) {
        await CustomCompoundStore.instance.update(compound);
      } else {
        await CustomCompoundStore.instance.add(compound);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Edit Compound' : 'New Custom Compound',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _label('NAME'),
              const SizedBox(height: 6),
              _textField(_nameCtrl, 'e.g. BPC-157'),
              const SizedBox(height: 14),
              _label('CATEGORY'),
              const SizedBox(height: 6),
              _categoryPicker(),
              const SizedBox(height: 14),
              _label('GENERIC / SCIENTIFIC NAME (optional)'),
              const SizedBox(height: 6),
              _textField(_genericCtrl, 'e.g. Body Protection Compound'),
              const SizedBox(height: 14),
              _label('DESCRIPTION (optional)'),
              const SizedBox(height: 6),
              _textField(_descCtrl, 'e.g. Healing peptide for recovery'),
              const SizedBox(height: 20),
              _sectionDivider('COMPOUND PROFILE (optional)'),
              const SizedBox(height: 14),
              _label('DOSAGE'),
              const SizedBox(height: 6),
              _textField(_dosageCtrl, 'e.g. 200–500 mcg/day'),
              const SizedBox(height: 14),
              _label('HALF-LIFE'),
              const SizedBox(height: 6),
              _textField(_halfLifeCtrl, 'e.g. ~4 hours'),
              const SizedBox(height: 14),
              _label('FREQUENCY'),
              const SizedBox(height: 6),
              _textField(_frequencyCtrl, 'e.g. Once or twice daily'),
              const SizedBox(height: 14),
              _label('ROUTE'),
              const SizedBox(height: 6),
              _textField(_routeCtrl, 'e.g. Subcutaneous injection'),
              const SizedBox(height: 14),
              _label('NOTES'),
              const SizedBox(height: 6),
              _textField(_notesCtrl, 'e.g. Stack with TB-500 for enhanced healing', maxLines: 3),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            isEdit ? 'Save Changes' : 'Add Compound',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionDivider(String label) => Row(
        children: [
          Expanded(child: Divider(color: context.colors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Expanded(child: Divider(color: context.colors.border)),
        ],
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2),
      );

  Widget _textField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _categoryPicker() {
    return Row(
      children: _categories.map((cat) {
        final selected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.purple.withValues(alpha: 0.2)
                  : context.colors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? Colors.purple.withValues(alpha: 0.6)
                    : context.colors.border,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.purpleAccent : Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
