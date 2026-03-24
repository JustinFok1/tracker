import 'package:flutter/material.dart';
import '../data/schedule_store.dart';
import '../models/schedule.dart';


class DoseCard extends StatelessWidget {
  const DoseCard({super.key});

  List<Schedule> _getTodaySchedules() {
    final schedules = ScheduleStore.instance.schedules;
    final today = DateTime.now().weekday;

    return schedules.where((s) {
      /// Only show if started
      if (DateTime.now().isBefore(s.startDate)) return false;

      return s.daysOfWeek.contains(today);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todaySchedules = _getTodaySchedules();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF222222),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                "TODAY",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// ===== EMPTY STATE =====
          if (todaySchedules.isEmpty)
            const Text(
              "No doses today",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )

          /// ===== HAS DATA =====
          else
            SizedBox(
              height: 135,
              child: _TodayExpandableList(schedules: todaySchedules),
            ),
        ],
      ),
    );
  }
}
class _TodayExpandableList extends StatefulWidget {
  final List<Schedule> schedules;

  const _TodayExpandableList({required this.schedules});

  @override
  State<_TodayExpandableList> createState() =>
      _TodayExpandableListState();
}

class _TodayExpandableListState
    extends State<_TodayExpandableList> {
  final Set<String> expanded = {};

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByCompound(widget.schedules);

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: grouped.entries.map((entry) {
        final compound = entry.key;
        final schedules = entry.value;
        final isExpanded = expanded.contains(compound);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER (same style as before)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expanded.remove(compound);
                  } else {
                    expanded.add(compound);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      compound,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            /// EXPANDED DOSAGES
            if (isExpanded)
              ..._groupByDosage(schedules).entries.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 8, bottom: 4),
                  child: Text(
                    d.key, // "30mg"
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                );
              }),
          ],
        );
      }).toList(),
    );
  }

  /// GROUP BY COMPOUND
  Map<String, List<Schedule>> _groupByCompound(
      List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};

    for (var s in schedules) {
      map.putIfAbsent(s.compoundName, () => []).add(s);
    }

    return map;
  }

  /// GROUP BY DOSAGE (combine duplicates)
  Map<String, List<Schedule>> _groupByDosage(
      List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};

    for (var s in schedules) {
      final key = "${s.dosage}${s.unit}";
      map.putIfAbsent(key, () => []).add(s);
    }

    return map;
  }
}