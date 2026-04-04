import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/dose_log_store.dart';
import '../data/schedule_store.dart';
import '../models/schedule.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    ScheduleStore.instance.addListener(_refresh);
    DoseLogStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ScheduleStore.instance.removeListener(_refresh);
    DoseLogStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<Schedule> _getSchedulesForDay(DateTime day) {
    return ScheduleStore.instance.schedules.where((s) {
      final start = DateTime(s.startDate.year, s.startDate.month, s.startDate.day);
      final d = DateTime(day.year, day.month, day.day);
      return !d.isBefore(start) && s.daysOfWeek.contains(day.weekday);
    }).toList();
  }

  String _doseKey(Schedule s) => "${s.compoundName}_${s.dosage}_${s.unit}";

  bool _allTaken(DateTime day) {
    final schedules = _getSchedulesForDay(day);
    if (schedules.isEmpty) return false;
    return schedules.every((s) => DoseLogStore.instance.isTaken(_doseKey(s), day));
  }

  bool _someTaken(DateTime day) {
    final schedules = _getSchedulesForDay(day);
    if (schedules.isEmpty) return false;
    return schedules.any((s) => DoseLogStore.instance.isTaken(_doseKey(s), day));
  }

  @override
  Widget build(BuildContext context) {
    final selectedSchedules = _getSchedulesForDay(_selectedDay);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 8),
            _buildCalendar(),
            const SizedBox(height: 16),
            _selectedDayLabel(),
            const SizedBox(height: 10),
            Expanded(child: _doseList(selectedSchedules)),
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
          const Text(
            "Calendar",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===== CALENDAR =====
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.inputDeep,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border2),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        eventLoader: (day) => _getSchedulesForDay(day),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey, size: 20),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          headerPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: context.colors.textSecondary, fontSize: 12),
          weekendStyle: TextStyle(color: context.colors.textSecondary, fontSize: 12),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2FBE), Color(0xFFE91E8C)],
            ),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.purple, width: 1.5),
          ),
          selectedTextStyle: TextStyle(
              color: context.colors.textPrimary, fontWeight: FontWeight.bold),
          todayTextStyle: TextStyle(
              color: context.colors.textPrimary, fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(color: context.colors.textSecondary),
          weekendTextStyle: TextStyle(color: context.colors.textSecondary),
          markerDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          markersMaxCount: 0,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final all = _allTaken(day);
            final some = _someTaken(day);
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: all
                      ? Colors.greenAccent
                      : some
                      ? Colors.orange
                      : Colors.purple,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===== SELECTED DAY LABEL =====
  Widget _selectedDayLabel() {
    final now = DateTime.now();
    final isToday = isSameDay(_selectedDay, now);
    final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    final label = isToday
        ? "Today"
        : "${weekdays[_selectedDay.weekday - 1]}, ${months[_selectedDay.month - 1]} ${_selectedDay.day}";

    final schedules = _getSchedulesForDay(_selectedDay);
    final taken = schedules.where((s) =>
        DoseLogStore.instance.isTaken(_doseKey(s), _selectedDay)).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
          ),
          if (schedules.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: taken == schedules.length
                    ? Colors.greenAccent.withValues(alpha: 0.15)
                    : Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$taken / ${schedules.length} done",
                style: TextStyle(
                  fontSize: 12,
                  color: taken == schedules.length
                      ? Colors.greenAccent
                      : Colors.purpleAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== DOSE LIST =====
  Widget _doseList(List<Schedule> schedules) {
    if (schedules.isEmpty) {
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
              child: const Icon(Icons.calendar_today,
                  color: Colors.grey, size: 22),
            ),
            const SizedBox(height: 12),
            Text("No doses scheduled",
                style: TextStyle(color: context.colors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final s = schedules[index];
        final key = _doseKey(s);
        final taken = DoseLogStore.instance.isTaken(key, _selectedDay);

        return GestureDetector(
          onTap: () {
            DoseLogStore.instance.toggleDose(key, _selectedDay);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: taken
                  ? Colors.greenAccent.withValues(alpha: 0.07)
                  : context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: taken
                    ? Colors.greenAccent.withValues(alpha: 0.3)
                    : context.colors.border,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: taken
                        ? Colors.greenAccent.withValues(alpha: 0.12)
                        : Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.science,
                    color: taken ? Colors.greenAccent : Colors.purpleAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Compound info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.compoundName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: taken ? Colors.grey : context.colors.textPrimary,
                          decoration: taken
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${s.dosage}${s.unit}",
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Check button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: taken
                        ? const LinearGradient(
                      colors: [Colors.greenAccent, Colors.teal],
                    )
                        : null,
                    color: taken ? null : context.colors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    taken ? Icons.check : Icons.circle_outlined,
                    color: taken ? Colors.black : Colors.grey,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}