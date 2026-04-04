import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String compoundName;

  @HiveField(2)
  final double dosage;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final List<int> daysOfWeek;

  @HiveField(5)
  final DateTime startDate;

  // Minutes since midnight (e.g. 480 = 8:00 AM). Null means no reminder.
  final int? reminderMinutes;

  Schedule({
    required this.id,
    required this.compoundName,
    required this.dosage,
    required this.unit,
    required this.daysOfWeek,
    required this.startDate,
    this.reminderMinutes,
  });
}