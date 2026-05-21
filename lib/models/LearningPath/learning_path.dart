import 'package:pfe_test/models/LearningPath/concept.dart';
import 'package:pfe_test/models/LearningPath/milestone.dart';
import 'package:pfe_test/models/mission_model.dart';

class LearningPath {
  final String id;
  final String language;
  final List<LearningPathMilestone> milestones;
  final List<Concept> concepts;
  final List<Mission> missions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String currentLevel;

  LearningPath({
    required this.id,
    required this.language,
    required this.milestones,
    required this.concepts,
    required this.missions,
    required this.startedAt,
    this.completedAt,
    required this.currentLevel,
  });

  // ✅ All computed live from concepts
  int get totalConcepts => concepts.length;
  int get totalConceptsCompleted => concepts.where((c) => c.isCompleted).length;
  int get remainingConcepts => totalConcepts - totalConceptsCompleted;
  int get overallProgressPercentage =>
      totalConcepts > 0 ? (totalConceptsCompleted * 100 ~/ totalConcepts) : 0;
  int get completedPercentage => overallProgressPercentage;
  int get completedMilestones => milestones.where((m) => m.isCompleted).length;
  int get unlockedMilestones => milestones.where((m) => m.isUnlocked).length;

  factory LearningPath.fromJson(
    Map<String, dynamic> json,
    List<Concept> concepts,
    List<Mission> missions,
  ) {
    return LearningPath(
      id: json[r'$id'] as String,
      language: json['language'] as String,
      milestones: (json['milestones'] as List)
          .map((m) => LearningPathMilestone.fromJson(m , concepts))
          .toList(),
      concepts: concepts,
      missions: missions,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentLevel: json['currentLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'concepts': concepts.map((c) => c.toJson()).toList(),
      'totalConceptsCompleted': totalConceptsCompleted,
      'totalConcepts': totalConcepts,
      'overallProgressPercentage': overallProgressPercentage,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentLevel': currentLevel,
    };
  }
}