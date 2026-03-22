import 'package:hive/hive.dart';

part 'vial.g.dart';

@HiveType(typeId: 0)
class Vial {
  @HiveField(0)
  final String compoundName;

  @HiveField(1)
  final double dosage;

  @HiveField(2)
  final String unit;

  Vial({
    required this.compoundName,
    required this.dosage,
    required this.unit,
  });
}