import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_compounds.dart';
import '../data/custom_compound_store.dart';
import '../data/vial_store.dart';
import '../models/compound.dart';
import '../models/vial.dart';

class AddVialScreen extends StatefulWidget {
  final Vial? existingVial;
  final String? initialCompound;

  const AddVialScreen({super.key, this.existingVial, this.initialCompound});

  @override
  State<AddVialScreen> createState() => _AddVialScreenState();
}

class _AddVialScreenState extends State<AddVialScreen> {
  String? selectedCompound;
  String selectedUnit = 'mg';
  final TextEditingController vialAmountController = TextEditingController();

  // Peptide reconstitution
  final TextEditingController bacWaterController = TextEditingController();
  final TextEditingController peptideDoseController = TextEditingController();
  String peptideDoseUnit = 'mg';

  // Injectable (pre-mixed)
  final TextEditingController injConcentrationController = TextEditingController();
  final TextEditingController injDrawPerDoseController = TextEditingController();

  // Oral
  final TextEditingController mgPerTabletController = TextEditingController();
  final TextEditingController dosePerDayController = TextEditingController();

  final List<String> units = ['mg', 'mcg', 'IU', 'ml'];

  @override
  void initState() {
    super.initState();
    if (widget.existingVial != null) {
      selectedCompound = widget.existingVial!.compoundName;
      vialAmountController.text = widget.existingVial!.dosage.toString();
      selectedUnit = widget.existingVial!.unit;
    } else if (widget.initialCompound != null) {
      selectedCompound = widget.initialCompound;
    }
  }

  @override
  void dispose() {
    vialAmountController.dispose();
    bacWaterController.dispose();
    peptideDoseController.dispose();
    injConcentrationController.dispose();
    injDrawPerDoseController.dispose();
    mgPerTabletController.dispose();
    dosePerDayController.dispose();
    super.dispose();
  }

  // ===== CATEGORY HELPERS =====
  String get _category {
    if (selectedCompound == null) return '';
    final all = [...allCompounds, ...CustomCompoundStore.instance.compounds];
    return all
        .firstWhere(
          (c) => c.name == selectedCompound,
          orElse: () => Compound(name: '', category: '', description: ''),
        )
        .category;
  }

  bool get _isPeptide => _category == 'Peptide';
  bool get _isInjectable => _category == 'Injectable';
  bool get _isOral => _category == 'Oral';

  // ===== PEPTIDE CALC =====
  double? get _vialMcg {
    final v = double.tryParse(vialAmountController.text);
    if (v == null) return null;
    return selectedUnit == 'mg' ? v * 1000 : v;
  }

  double? get _bacMl => double.tryParse(bacWaterController.text);

  double? get _peptideDesiredMcg {
    final d = double.tryParse(peptideDoseController.text);
    if (d == null) return null;
    return peptideDoseUnit == 'mg' ? d * 1000 : d;
  }

  double? get _peptideConcPerMl {
    final vial = _vialMcg;
    final bac = _bacMl;
    if (vial == null || bac == null || bac <= 0) return null;
    return vial / bac;
  }

  double? get _peptideMlToDraw {
    final conc = _peptideConcPerMl;
    final dose = _peptideDesiredMcg;
    if (conc == null || dose == null || conc <= 0) return null;
    return dose / conc;
  }

  int? get _peptideTotalDoses {
    final vial = _vialMcg;
    final dose = _peptideDesiredMcg;
    if (vial == null || dose == null || dose <= 0) return null;
    return (vial / dose).floor();
  }

  // ===== INJECTABLE CALC =====
  double? get _injVialMl => double.tryParse(vialAmountController.text);
  double? get _injConcMgPerMl => double.tryParse(injConcentrationController.text);
  double? get _injDrawPerDose => double.tryParse(injDrawPerDoseController.text);

  double? get _injMgPerDose {
    final conc = _injConcMgPerMl;
    final draw = _injDrawPerDose;
    if (conc == null || draw == null) return null;
    return conc * draw;
  }

  int? get _injTotalDoses {
    final vol = _injVialMl;
    final draw = _injDrawPerDose;
    if (vol == null || draw == null || draw <= 0) return null;
    return (vol / draw).floor();
  }

  // ===== ORAL CALC =====
  double? get _pillCount => double.tryParse(vialAmountController.text);
  double? get _mgPerTablet => double.tryParse(mgPerTabletController.text);
  double? get _dosePerDay => double.tryParse(dosePerDayController.text);

  double? get _pillsPerDose {
    final perTab = _mgPerTablet;
    final dose = _dosePerDay;
    if (perTab == null || dose == null || perTab <= 0) return null;
    return dose / perTab;
  }

  int? get _daysSupply {
    final pills = _pillCount;
    final perDose = _pillsPerDose;
    if (pills == null || perDose == null || perDose <= 0) return null;
    return (pills / perDose).floor();
  }

  // ===== COMPUTED TOTAL DOSES TO SAVE =====
  int? get _totalDosesToSave {
    if (_isPeptide) return _peptideTotalDoses;
    if (_isInjectable) return _injTotalDoses;
    if (_isOral) return _daysSupply;
    return null;
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingVial != null;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
        ),
        title: Text(
          isEdit ? "Edit Compound" : "Add Compound",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon header
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.opacity, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isEdit
                    ? "Update your compound details"
                    : "Add a new compound to your inventory",
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 32),

            // Compound
            _fieldLabel("Compound"),
            const SizedBox(height: 8),
            _compoundDropdown(),

            const SizedBox(height: 20),

            // Vial amount + unit
            _fieldLabel(_isOral
                ? "Number of Pills / Capsules"
                : _isInjectable
                    ? "Vial Volume"
                    : "Vial Amount"),
            const SizedBox(height: 8),
            _isInjectable
                ? _textField(vialAmountController, "e.g. 10", suffix: "ml")
                : _isOral
                    ? _textField(vialAmountController, "e.g. 100",
                        suffix: "pills")
                    : Row(
                        children: [
                          Expanded(
                              child:
                                  _textField(vialAmountController, "e.g. 5")),
                          const SizedBox(width: 12),
                          _unitDropdown(
                            value: selectedUnit,
                            items: units,
                            onChanged: (v) => setState(() => selectedUnit = v!),
                          ),
                        ],
                      ),

            // ---- PEPTIDE ----
            if (_isPeptide) ...[
              const SizedBox(height: 20),
              _fieldLabel("BAC Water Added"),
              const SizedBox(height: 8),
              _textField(bacWaterController, "e.g. 2", suffix: "ml"),
              const SizedBox(height: 20),
              _fieldLabel("Dose Per Injection"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _textField(peptideDoseController, "e.g. 250")),
                  const SizedBox(width: 12),
                  _unitDropdown(
                    value: peptideDoseUnit,
                    items: const ['mcg', 'mg', 'IU'],
                    onChanged: (v) => setState(() => peptideDoseUnit = v!),
                  ),
                ],
              ),
              if (_peptideConcPerMl != null) ...[
                const SizedBox(height: 20),
                _peptideResults(),
              ],
            ],

            // ---- INJECTABLE ----
            if (_isInjectable) ...[
              const SizedBox(height: 20),
              _fieldLabel("Concentration"),
              const SizedBox(height: 8),
              _textField(injConcentrationController, "e.g. 250", suffix: "mg/ml"),
              const SizedBox(height: 20),
              _fieldLabel("Draw Per Injection"),
              const SizedBox(height: 8),
              _textField(injDrawPerDoseController, "e.g. 0.5", suffix: "ml"),
              if (_injConcMgPerMl != null && _injDrawPerDose != null) ...[
                const SizedBox(height: 20),
                _injectableResults(),
              ],
            ],

            // ---- ORAL ----
            if (_isOral) ...[
              const SizedBox(height: 20),
              _fieldLabel("mg Per Tablet / Capsule"),
              const SizedBox(height: 8),
              _textField(mgPerTabletController, "e.g. 10", suffix: "mg"),
              const SizedBox(height: 20),
              _fieldLabel("Dose Per Day"),
              const SizedBox(height: 8),
              _textField(dosePerDayController, "e.g. 20", suffix: "mg"),
              if (_mgPerTablet != null && _dosePerDay != null) ...[
                const SizedBox(height: 20),
                _oralResults(),
              ],
            ],

            const SizedBox(height: 32),
            _saveButton(isEdit),
          ],
        ),
      ),
    );
  }

  // ===== RESULT CARDS =====
  Widget _peptideResults() {
    final conc = _peptideConcPerMl!;
    final ml = _peptideMlToDraw;
    final total = _peptideTotalDoses;

    final concLabel = conc >= 1000
        ? "${(conc / 1000).toStringAsFixed(2)} mg/ml"
        : "${conc.toStringAsFixed(1)} mcg/ml";

    return _resultsCard(
      rows: [
        _resultRow(Icons.water_drop_outlined, Colors.tealAccent,
            "Concentration", concLabel),
        if (ml != null)
          _resultRow(Icons.colorize_outlined, Colors.purpleAccent,
              "Draw per dose", "${ml.toStringAsFixed(3)} ml"),
        if (ml != null)
          _resultRow(Icons.straighten_outlined, Colors.pinkAccent,
              "Insulin syringe (100u)", "${(ml * 100).toStringAsFixed(1)} units"),
        if (total != null)
          _resultRowHighlighted(Icons.inventory_2_outlined, Colors.amber,
              "Total doses", "$total doses"),
      ],
    );
  }

  Widget _injectableResults() {
    final mgPerDose = _injMgPerDose;
    final total = _injTotalDoses;

    return _resultsCard(
      rows: [
        if (mgPerDose != null)
          _resultRow(Icons.science_outlined, Colors.tealAccent,
              "mg per dose", "${mgPerDose.toStringAsFixed(1)} mg"),
        if (total != null)
          _resultRowHighlighted(Icons.inventory_2_outlined, Colors.amber,
              "Total doses", "$total doses"),
      ],
    );
  }

  Widget _oralResults() {
    final perDose = _pillsPerDose;
    final days = _daysSupply;

    return _resultsCard(
      rows: [
        if (perDose != null)
          _resultRow(Icons.medication_outlined, Colors.tealAccent,
              "Pills per dose", "${perDose.toStringAsFixed(1)} pills"),
        if (days != null)
          _resultRowHighlighted(Icons.calendar_today_outlined, Colors.amber,
              "Days supply", "$days days"),
      ],
    );
  }

  Widget _resultsCard({required List<Widget> rows}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined,
                  color: Colors.tealAccent, size: 14),
              const SizedBox(width: 8),
              const Text(
                "Calculated",
                style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _resultRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _resultRowHighlighted(
      IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Divider(color: context.colors.border, height: 1),
        ),
        _resultRow(icon, color, label, value),
      ],
    );
  }

  // ===== SHARED WIDGETS =====
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint,
      {String? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 15),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixText: suffix,
          suffixStyle: TextStyle(color: context.colors.textSecondary),
        ),
      ),
    );
  }

  Widget _unitDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: context.colors.card,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey, size: 18),
          items: items
              .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (v) {
            onChanged(v);
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _compoundDropdown() {
    return GestureDetector(
      onTap: _openCompoundPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            if (selectedCompound != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                selectedCompound ?? "Search compounds...",
                style: TextStyle(
                  fontSize: 14,
                  color: selectedCompound != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  void _openCompoundPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompoundPickerSheet(
        selected: selectedCompound,
        onSelected: (name) => setState(() => selectedCompound = name),
      ),
    );
  }

  Widget _saveButton(bool isEdit) {
    return GestureDetector(
      onTap: _saveVial,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            isEdit ? "Update Compound" : "Save Compound",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void _saveVial() {
    final dosage = double.tryParse(vialAmountController.text);
    if (selectedCompound == null || dosage == null || dosage <= 0) return;

    final newVial = Vial(
      compoundName: selectedCompound!,
      dosage: dosage,
      unit: _isInjectable ? 'ml' : _isOral ? 'pills' : selectedUnit,
      totalDoses: _totalDosesToSave,
    );

    if (widget.existingVial != null) {
      VialStore.instance.updateVial(widget.existingVial!, newVial);
    } else {
      VialStore.instance.addVial(newVial);
    }

    Navigator.pop(context);
  }
}

// ===== COMPOUND PICKER SHEET =====
class _CompoundPickerSheet extends StatefulWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CompoundPickerSheet({required this.selected, required this.onSelected});

  @override
  State<_CompoundPickerSheet> createState() => _CompoundPickerSheetState();
}

class _CompoundPickerSheetState extends State<_CompoundPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    CustomCompoundStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    CustomCompoundStore.instance.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  List<Compound> get _allCompounds => [
        ...allCompounds,
        ...CustomCompoundStore.instance.compounds,
      ];

  List<Compound> get _filtered {
    if (_query.isEmpty) return _allCompounds;
    final q = _query.toLowerCase();
    return _allCompounds.where((c) =>
      c.name.toLowerCase().contains(q) ||
      (c.genericName?.toLowerCase().contains(q) ?? false) ||
      c.category.toLowerCase().contains(q),
    ).toList();
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Peptide':    return Colors.tealAccent;
      case 'Injectable': return Colors.orangeAccent;
      case 'Oral':       return Colors.pinkAccent;
      default:           return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text("Select Compound",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 18),
                  hintText: "Search by name, category...",
                  hintStyle: TextStyle(color: context.colors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${filtered.length} compound${filtered.length != 1 ? 's' : ''}",
                style: const TextStyle(color: Colors.grey, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final c = filtered[i];
                final color = _categoryColor(c.category);
                final isSelected = c.name == widget.selected;

                return GestureDetector(
                  onTap: () {
                    widget.onSelected(c.name);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withValues(alpha: 0.12)
                          : context.colors.cardAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple.withValues(alpha: 0.4)
                            : context.colors.border2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600)),
                              if (c.genericName != null)
                                Text(c.genericName!,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(c.category,
                              style: TextStyle(
                                  color: color, fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle,
                              color: Colors.purpleAccent, size: 16),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Create new compound button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: GestureDetector(
              onTap: () => _showCreateCompound(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.purpleAccent, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Create custom compound',
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCompound(BuildContext context) {
    Navigator.pop(context); // close picker
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InlineCompoundForm(
        onCreated: (name) {
          widget.onSelected(name);
        },
      ),
    );
  }
}

// ===== INLINE CREATE COMPOUND FORM =====
class _InlineCompoundForm extends StatefulWidget {
  final ValueChanged<String> onCreated;
  const _InlineCompoundForm({required this.onCreated});

  @override
  State<_InlineCompoundForm> createState() => _InlineCompoundFormState();
}

class _InlineCompoundFormState extends State<_InlineCompoundForm> {
  final _nameCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Peptide';
  bool _saving = false;

  static const _categories = ['Peptide', 'Injectable', 'Oral'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _genericCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final compound = Compound(
        name: name,
        category: _category,
        description: _descCtrl.text.trim(),
        genericName: _genericCtrl.text.trim().isEmpty
            ? null
            : _genericCtrl.text.trim(),
        isCustom: true,
      );
      await CustomCompoundStore.instance.add(compound);
      widget.onCreated(name);
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const Text('New Custom Compound',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _label('NAME'),
            const SizedBox(height: 6),
            _field(_nameCtrl, 'e.g. BPC-157'),
            const SizedBox(height: 14),
            _label('CATEGORY'),
            const SizedBox(height: 6),
            _categoryRow(),
            const SizedBox(height: 14),
            _label('GENERIC NAME (optional)'),
            const SizedBox(height: 6),
            _field(_genericCtrl, 'e.g. Body Protection Compound'),
            const SizedBox(height: 14),
            _label('DESCRIPTION (optional)'),
            const SizedBox(height: 6),
            _field(_descCtrl, 'e.g. Healing peptide for recovery'),
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
                      : const Text('Add Compound',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2));

  Widget _field(TextEditingController ctrl, String hint) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: TextField(
          controller: ctrl,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      );

  Widget _categoryRow() => Row(
        children: _categories.map((cat) {
          final sel = _category == cat;
          return GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? Colors.purple.withValues(alpha: 0.2)
                    : context.colors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel
                      ? Colors.purple.withValues(alpha: 0.6)
                      : context.colors.border,
                ),
              ),
              child: Text(cat,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.purpleAccent : Colors.grey)),
            ),
          );
        }).toList(),
      );
}
