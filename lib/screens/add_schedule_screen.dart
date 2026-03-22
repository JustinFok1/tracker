import 'package:flutter/material.dart';
import '../data/vial_store.dart';
import '../data/schedule_store.dart';
import '../models/schedule.dart';

class AddScheduleScreen extends StatefulWidget {
  final Schedule? existingSchedule;

  const AddScheduleScreen({super.key, this.existingSchedule});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String? selectedVial;
  String frequency = "Daily";

  @override
  void initState() {
    super.initState();

    if (widget.existingSchedule != null) {
      selectedVial = widget.existingSchedule!.compoundName;
      frequency = widget.existingSchedule!.frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vials = VialStore.instance.vials;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          widget.existingSchedule != null
              ? "Edit Schedule"
              : "Add Schedule",
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SELECT VIAL
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A1A),
              hint: const Text("Select Vial"),
              value: selectedVial,
              items: vials.map((v) {
                return DropdownMenuItem(
                  value: v.compoundName,
                  child: Text(v.compoundName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedVial = value);
              },
            ),

            const SizedBox(height: 20),

            /// FREQUENCY
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A1A),
              value: frequency,
              items: ["Daily", "Weekly"]
                  .map((f) => DropdownMenuItem(
                value: f,
                child: Text(f),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => frequency = value!);
              },
            ),

            const SizedBox(height: 20),

            /// SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSchedule,
                child: Text(
                  widget.existingSchedule != null
                      ? "Update Schedule"
                      : "Save Schedule",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSchedule() {
    if (selectedVial == null) return;

    final vial = VialStore.instance.vials
        .firstWhere((v) => v.compoundName == selectedVial);

    final schedule = Schedule(
      compoundName: vial.compoundName,
      dosage: vial.dosage,
      unit: vial.unit,
      frequency: frequency,
    );

    /// EDIT MODE
    if (widget.existingSchedule != null) {
      ScheduleStore.instance.removeSchedule(widget.existingSchedule!);
    }

    ScheduleStore.instance.addSchedule(schedule);

    Navigator.pop(context);
  }
}