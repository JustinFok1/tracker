import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule {
  @HiveField(0)
  final String compoundName;

  @HiveField(1)
  final double dosage;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final String frequency;

  Schedule({
    required this.compoundName,
    required this.dosage,
    required this.unit,
    required this.frequency,
  });
}