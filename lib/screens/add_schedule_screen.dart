import 'package:flutter/material.dart';
import '../data/vial_store.dart';
import '../data/schedule_store.dart';
import '../models/schedule.dart';
import '../models/vial.dart';

class AddScheduleScreen extends StatefulWidget {
  final Schedule? existingSchedule;

  const AddScheduleScreen({super.key, this.existingSchedule});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  Vial? selectedVial;
  List<int> selectedDays = [];

  @override
  void initState() {
    super.initState();

    if (widget.existingSchedule != null) {
      selectedDays = List.from(widget.existingSchedule!.daysOfWeek);

      final vials = VialStore.instance.vials;

      selectedVial = vials.firstWhere(
            (v) =>
        v.compoundName == widget.existingSchedule!.compoundName &&
            v.dosage == widget.existingSchedule!.dosage,
        orElse: () => vials.isNotEmpty ? vials.first : null as Vial,
      );
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
            DropdownButtonFormField<Vial>(
              dropdownColor: const Color(0xFF1A1A1A),
              hint: const Text("Select Vial"),
              value: selectedVial,
              items: vials.map((v) {
                return DropdownMenuItem<Vial>(
                  value: v,
                  child: Text("${v.compoundName} (${v.dosage}${v.unit})"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedVial = value);
              },
            ),

            const SizedBox(height: 20),

            /// SELECT DAYS
            _daySelector(),

            const SizedBox(height: 20),

            /// SAVE BUTTON
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
    if (selectedVial == null || selectedDays.isEmpty) return;

    final vial = selectedVial!;

    final schedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      compoundName: vial.compoundName,
      dosage: vial.dosage,
      unit: vial.unit,
      daysOfWeek: selectedDays,
      startDate: DateTime.now(),
    );

    /// EDIT MODE
    if (widget.existingSchedule != null) {
      ScheduleStore.instance.updateSchedule(
        widget.existingSchedule!,
        schedule,
      );
    } else {
      ScheduleStore.instance.addSchedule(schedule);
    }

    Navigator.pop(context);
  }

  Widget _daySelector() {
    final days = ["M", "T", "W", "T", "F", "S", "S"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = index + 1;

        final selected = selectedDays.contains(day);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                selectedDays.remove(day);
              } else {
                selectedDays.add(day);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.purple
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(days[index]),
          ),
        );
      }),
    );
  }
}