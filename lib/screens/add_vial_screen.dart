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
  final TextEditingController dosageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingVial != null) {
      selectedCompound = widget.existingVial!.compoundName;
      dosageController.text =
          widget.existingVial!.dosage.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text(
          widget.existingVial != null ? "Edit Vial" : "Add Vial",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SELECT COMPOUND
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A1A),
              hint: const Text("Select Compound"),
              value: selectedCompound,
              items: allCompounds
                  .map((c) => DropdownMenuItem(
                value: c.name,
                child: Text(c.name),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedCompound = value);
              },
            ),

            const SizedBox(height: 20),

            /// DOSAGE
            TextField(
              controller: dosageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Dosage (e.g. 250)",
              ),
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveVial,
                child: Text(
                  widget.existingVial != null ? "Update" : "Save",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveVial() {
    if (selectedCompound == null || dosageController.text.isEmpty) return;

    final newVial = Vial(
      compoundName: selectedCompound!,
      dosage: double.parse(dosageController.text),
      unit: "mg",
    );

    if (widget.existingVial != null) {
      VialStore.instance.updateVial(
        widget.existingVial!,
        newVial,
      );
    } else {
      VialStore.instance.addVial(newVial);
    }

    Navigator.pop(context);
  }
}