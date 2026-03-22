class Schedule {
  final String compoundName;
  final double dosage;
  final String unit;
  final String frequency; // e.g. "Daily", "Weekly"

  Schedule({
    required this.compoundName,
    required this.dosage,
    required this.unit,
    required this.frequency,
  });
}