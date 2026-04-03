import 'package:flutter/material.dart';
import '../data/mock_compounds.dart';
import '../data/vial_store.dart';
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
  final TextEditingController dosageController = TextEditingController();

  final List<String> units = ['mg', 'mcg', 'IU', 'ml'];

  @override
  void initState() {
    super.initState();
    if (widget.existingVial != null) {
      selectedCompound = widget.existingVial!.compoundName;
      dosageController.text = widget.existingVial!.dosage.toString();
      selectedUnit = widget.existingVial!.unit;
    }
  }

  @override
  void dispose() {
    dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingVial != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
        ),
        title: Text(
          isEdit ? "Edit Vial" : "Add Vial",
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
                isEdit ? "Update your vial details" : "Add a new vial to your inventory",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

            const SizedBox(height: 32),

            // Compound selector
            _fieldLabel("Compound"),
            const SizedBox(height: 8),
            _styledDropdown(),

            const SizedBox(height: 20),

            // Dosage + unit row
            _fieldLabel("Dosage"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _dosageField()),
                const SizedBox(width: 12),
                _unitSelector(),
              ],
            ),

            const SizedBox(height: 36),

            // Save button
            _saveButton(isEdit),
          ],
        ),
      ),
    );
  }

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

  Widget _styledDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1A1A1A),
          hint: const Text("Select Compound",
              style: TextStyle(color: Colors.grey)),
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
                        Text(c.name,
                            style: const TextStyle(fontSize: 14)),
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

  Widget _dosageField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: dosageController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 15),
        decoration: const InputDecoration(
          hintText: "e.g. 250",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _unitSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1A1A1A),
          value: selectedUnit,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey, size: 18),
          items: units
              .map((u) => DropdownMenuItem(
            value: u,
            child: Text(u, style: const TextStyle(fontSize: 14)),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => selectedUnit = value);
          },
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
            isEdit ? "Update Vial" : "Save Vial",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _saveVial() {
    if (selectedCompound == null || dosageController.text.isEmpty) return;

    final newVial = Vial(
      compoundName: selectedCompound!,
      dosage: double.parse(dosageController.text),
      unit: selectedUnit,
    );

    if (widget.existingVial != null) {
      VialStore.instance.updateVial(widget.existingVial!, newVial);
    } else {
      VialStore.instance.addVial(newVial);
    }

    Navigator.pop(context);
  }
}