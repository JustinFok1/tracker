import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
  TimeOfDay? _reminderTime;

  final List<String> dayLabels = ["M", "T", "W", "T", "F", "S", "S"];
  final List<String> dayFull = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      final s = widget.existingSchedule!;
      selectedDays = List.from(s.daysOfWeek);
      final vials = VialStore.instance.vials;
      final matches = vials.where(
        (v) => v.compoundName == s.compoundName && v.dosage == s.dosage,
      ).toList();
      selectedVial = matches.isNotEmpty
          ? matches.first
          : (vials.isNotEmpty ? vials.first : null);
      if (s.reminderMinutes != null) {
        _reminderTime = TimeOfDay(
          hour: s.reminderMinutes! ~/ 60,
          minute: s.reminderMinutes! % 60,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vials = VialStore.instance.vials;
    final isEdit = widget.existingSchedule != null;

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
          isEdit ? "Edit Schedule" : "Add Schedule",
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
                    colors: [Color(0xFFE91E8C), Color(0xFF7B2FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.calendar_month,
                    color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isEdit
                    ? "Update your schedule"
                    : "Set up your dosing schedule",
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 32),

            // Vial selector
            _fieldLabel("Select Compound"),
            const SizedBox(height: 8),
            _vialDropdown(vials),

            const SizedBox(height: 24),

            // Day selector
            _fieldLabel("Dosing Days"),
            const SizedBox(height: 12),
            _daySelector(),

            // Selected days summary
            if (selectedDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              _daysSummary(),
            ],

            const SizedBox(height: 24),

            // Reminder time
            _fieldLabel("Reminder Time (optional)"),
            const SizedBox(height: 8),
            _timePicker(),

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

  Widget _vialDropdown(List<Vial> vials) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vial>(
          dropdownColor: context.colors.card,
          hint: Text("Select a compound",
              style: TextStyle(color: context.colors.textSecondary)),
          value: selectedVial,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: vials.map((v) {
            return DropdownMenuItem<Vial>(
              value: v,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${v.compoundName}  •  ${v.dosage}${v.unit}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedVial = value),
        ),
      ),
    );
  }

  Widget _daySelector() {
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: selected ? null : context.colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : context.colors.border,
              ),
            ),
            child: Center(
              child: Text(
                dayLabels[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _daysSummary() {
    final sorted = List<int>.from(selectedDays)..sort();
    final names = sorted.map((d) => dayFull[d - 1]).join(", ");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.purpleAccent, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              names,
              style: const TextStyle(
                  color: Colors.purpleAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timePicker() {
    final label = _reminderTime == null
        ? 'No reminder set'
        : _reminderTime!.format(context);

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime ?? TimeOfDay.now(),
        );
        if (picked != null) setState(() => _reminderTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 18,
              color: _reminderTime != null
                  ? Colors.purpleAccent
                  : context.colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: _reminderTime != null
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
            if (_reminderTime != null)
              GestureDetector(
                onTap: () => setState(() => _reminderTime = null),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(bool isEdit) {
    return GestureDetector(
      onTap: _saveSchedule,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E8C), Color(0xFF7B2FBE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            isEdit ? "Update Schedule" : "Save Schedule",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  void _saveSchedule() {
    if (selectedVial == null || selectedDays.isEmpty) return;

    final vial = selectedVial!;
    final reminderMinutes = _reminderTime != null
        ? _reminderTime!.hour * 60 + _reminderTime!.minute
        : null;

    final schedule = Schedule(
      id: widget.existingSchedule?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      compoundName: vial.compoundName,
      dosage: vial.dosage,
      unit: vial.unit,
      daysOfWeek: selectedDays,
      startDate: widget.existingSchedule?.startDate ?? DateTime.now(),
      reminderMinutes: reminderMinutes,
    );

    if (widget.existingSchedule != null) {
      ScheduleStore.instance.updateSchedule(widget.existingSchedule!, schedule);
    } else {
      ScheduleStore.instance.addSchedule(schedule);
    }

    Navigator.pop(context);
  }
}