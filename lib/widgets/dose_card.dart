import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/schedule_store.dart';
import '../data/dose_log_store.dart';
import '../models/schedule.dart';

class DoseCard extends StatefulWidget {
  const DoseCard({super.key});

  @override
  State<DoseCard> createState() => _DoseCardState();
}

class _DoseCardState extends State<DoseCard> {
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

  List<Schedule> _getTodaySchedules() {
    final today = DateTime.now().weekday;
    final now = DateTime.now();
    return ScheduleStore.instance.schedules.where((s) {
      if (now.isBefore(s.startDate)) return false;
      return s.daysOfWeek.contains(today);
    }).toList();
  }

  String _doseKey(Schedule s) => "${s.compoundName}_${s.dosage}_${s.unit}";

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final schedules = _getTodaySchedules();
    final taken = schedules
        .where((s) => DoseLogStore.instance.isTaken(_doseKey(s), today))
        .length;
    final total = schedules.length;
    final allDone = total > 0 && taken == total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.card, context.colors.card2],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: allDone
                      ? Colors.greenAccent.withOpacity(0.12)
                      : Colors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  allDone ? Icons.check_circle : Icons.access_time,
                  color: allDone ? Colors.greenAccent : Colors.purple,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "TODAY",
                style: TextStyle(
                  color: allDone ? Colors.greenAccent : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Empty state
          if (schedules.isEmpty)
            const SizedBox(
              height: 80,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "No doses\ntoday",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            )

          // Has doses
          else ...[
            // Progress indicator
            Row(
              children: [
                Text(
                  "$taken",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: allDone ? Colors.greenAccent : context.colors.textPrimary,
                  ),
                ),
                Text(
                  " / $total",
                  style: const TextStyle(
                      fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? taken / total : 0,
                minHeight: 4,
                backgroundColor: context.colors.progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(
                  allDone ? Colors.greenAccent : Colors.purple,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Compound list
            SizedBox(
              height: 70,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: schedules.map((s) {
                  final isTaken = DoseLogStore.instance
                      .isTaken(_doseKey(s), today);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          isTaken
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isTaken
                              ? Colors.greenAccent
                              : Colors.grey,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.compoundName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isTaken
                                  ? Colors.grey
                                  : context.colors.textSecondary,
                              decoration: isTaken
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}