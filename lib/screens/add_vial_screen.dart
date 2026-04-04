import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_compounds.dart';
import '../data/vial_store.dart';
import '../models/compound.dart';
import '../models/vial.dart';

class AddVialScreen extends StatefulWidget {
  final Vial? existingVial;

  const AddVialScreen({super.key, this.existingVial});

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
    return allCompounds
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
        color: Colors.tealAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.2)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: context.colors.card,
          hint: Text("Select Compound",
              style: TextStyle(color: context.colors.textSecondary)),
          value: selectedCompound,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: allCompounds.map((c) {
            return DropdownMenuItem<String>(
              value: c.name,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.name, style: const TextStyle(fontSize: 14)),
                        Text(c.category,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCompound = value),
        ),
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
    if (selectedCompound == null || vialAmountController.text.isEmpty) return;

    final newVial = Vial(
      compoundName: selectedCompound!,
      dosage: double.parse(vialAmountController.text),
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
