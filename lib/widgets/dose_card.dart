import 'package:flutter/material.dart';
import '../data/schedule_store.dart';
import '../models/schedule.dart';

class DoseCard extends StatefulWidget {
  const DoseCard({super.key});

  @override
  State<DoseCard> createState() => _DoseCardState();
}

class _DoseCardState extends State<DoseCard> {
  final Set<String> expanded = {};

  List<Schedule> _getTodaySchedules() {
    final schedules = ScheduleStore.instance.schedules;
    final today = DateTime.now().weekday;

    return schedules.where((s) {
      if (DateTime.now().isBefore(s.startDate)) return false;
      return s.daysOfWeek.contains(today);
    }).toList();
  }

  Map<String, List<Schedule>> _groupByCompound(List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};

    for (var s in schedules) {
      map.putIfAbsent(s.compoundName, () => []);
      map[s.compoundName]!.add(s);
    }

    return map;
  }

  Map<String, List<Schedule>> _groupByDosage(List<Schedule> schedules) {
    final Map<String, List<Schedule>> map = {};

    for (var s in schedules) {
      final key = "${s.dosage}${s.unit}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(s);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final todaySchedules = _getTodaySchedules();
    final grouped = _groupByCompound(todaySchedules);

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

          /// EMPTY
          if (todaySchedules.isEmpty)
            if (todaySchedules.isEmpty)
              const SizedBox(
                height: 135,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "No doses today",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )

          /// HAS DATA
          else
            SizedBox(
              height: 135,
              child: ListView(
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
                      /// HEADER (tap to expand)
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
                              Expanded(
                                child: Text(
                                  compound,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// EXPANDED DOSAGES
                      if (isExpanded)
                        ..._groupByDosage(schedules)
                            .entries
                            .map((d) {
                          final dosageKey = d.key;

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8, bottom: 4),
                            child: Text(
                              dosageKey,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}