class Compound {
  final String? id;          // null for built-in compounds
  final String name;
  final String category;
  final String description;
  final String? genericName; // Scientific / IUPAC name shown in detail view
  final bool isCustom;

  // Custom compound profile fields
  final String? dosage;
  final String? halfLife;
  final String? frequency;
  final String? route;
  final String? profileNotes;

  Compound({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    this.genericName,
    this.isCustom = false,
    this.dosage,
    this.halfLife,
    this.frequency,
    this.route,
    this.profileNotes,
  });
}