import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule extends HiveObject {
  @HiveField(0)
  final String compoundName;

  @HiveField(1)
  final double dosage;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final List<int> daysOfWeek; // 1 = Mon ... 7 = Sun

  @HiveField(4)
  final DateTime startDate;

  Schedule({
    required this.compoundName,
    required this.dosage,
    required this.unit,
    required this.daysOfWeek,
    required this.startDate,
  });
}