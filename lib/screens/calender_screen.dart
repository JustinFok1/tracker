import 'package:flutter/material.dart';
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
  DateTime? _selectedDay = DateTime.now();

  List<Schedule> _getSchedulesForDay(DateTime day) {
    final schedules = ScheduleStore.instance.schedules;

    return schedules.where((s) {
      /// Only show if day is AFTER start date
      if (day.isBefore(s.startDate)) return false;

      /// Match selected weekday
      return s.daysOfWeek.contains(day.weekday);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSchedules =
    _selectedDay != null ? _getSchedulesForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,

            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),

            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            eventLoader: (day) => _getSchedulesForDay(day),

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ===== LIST OF SCHEDULES =====
          Expanded(
            child: selectedSchedules.isEmpty
                ? const Center(
              child: Text(
                "No doses scheduled",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: selectedSchedules.map((s) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.compoundName),

                      Row(
                        children: [
                          Text("${s.dosage}${s.unit}"),
                          const SizedBox(width: 10),

                          GestureDetector(
                            onTap: () {
                              DoseLogStore.instance.toggleDose(
                                s.compoundName,
                                _selectedDay!,
                              );
                              setState(() {});
                            },
                            child: Icon(
                              DoseLogStore.instance.isTaken(
                                s.compoundName,
                                _selectedDay!,
                              )
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}