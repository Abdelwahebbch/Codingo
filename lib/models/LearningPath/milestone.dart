import 'package:pfe_test/models/LearningPath/concept.dart';

class LearningPathMilestone {
  final String id;
  final String title;
  final String description;
  final List<String> conceptIds; // Concepts in this milestone
  final List<Concept> concepts; // Concepts in this milestone
  final int order; // Order in the learning path
  final bool isUnlocked;

  final String icon;
  final DateTime? unlockedAt;
  final DateTime? completedAt;

  LearningPathMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.conceptIds,
    required this.order,
    this.isUnlocked = false,
    required this.icon,
    this.unlockedAt,
    this.completedAt,
    required this.concepts,
  });

  double get completionPercentage {
    final conceptMissions =
        concepts.where((m) => conceptIds.contains(m.id)).toList();

    if (conceptMissions.isEmpty) return 0.0;

    return conceptMissions.where((m) => m.isCompleted).length /
        conceptMissions.length;
  }

  bool get isCompleted =>
      (concepts
              .where((m) => conceptIds.contains(m.id) && m.isCompleted)
              .toList()
              .length /
          concepts.where((m) => conceptIds.contains(m.id)).toList().length) >=
      1;
  factory LearningPathMilestone.fromJson(
      Map<String, dynamic> json, List<Concept> concepts) {
    return LearningPathMilestone(
      id: json[r'$id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      conceptIds: List<String>.from(json['conceptIds'] as List? ?? []),
      order: json['order'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      // isCompleted: json['isCompleted'] as bool? ?? false,

      //completionPercentage: json['completionPercentage'] as int? ?? 0,
      icon: json['icon'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      concepts: concepts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'conceptIds': conceptIds,
      'order': order,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
      'icon': icon,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
