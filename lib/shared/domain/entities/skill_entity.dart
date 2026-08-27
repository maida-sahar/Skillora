class SkillEntity {
  final String id;
  final String name;
  final String category;
  final String level; // Beginner, Intermediate, Advanced

  const SkillEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
  });
}
