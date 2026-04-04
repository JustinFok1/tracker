class Compound {
  final String name;
  final String category;
  final String description;
  final String? genericName; // Scientific / IUPAC name shown in detail view

  Compound({
    required this.name,
    required this.category,
    required this.description,
    this.genericName,
  });
}