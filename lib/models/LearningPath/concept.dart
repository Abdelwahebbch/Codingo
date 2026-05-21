import 'package:pfe_test/models/mission_model.dart';

class Concept {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "Variables", "Functions", "OOP"
  final int difficulty; // 1-5
  final int estimatedHours;
  final List<String>
      prerequisites; // IDs of concepts that must be completed first
  final List<String> relatedMissionsIds; // Mission IDs related to this concept
  final List<Mission> relatedMissions; // Mission IDs related to this concept
  final String icon; // Emoji or icon name
  bool _isCompleted; // Emoji or icon name
  double _completionPercentage; // Emoji or icon name
  // 0-100
  final DateTime? startedAt;
  final DateTime? completedAt;

  Concept({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedHours,
    required this.prerequisites,
    required this.relatedMissionsIds,
    required this.icon,
    this.startedAt,
    this.completedAt,
    required this.relatedMissions,
    required bool isCompleted,
    required double completionPercentage,
  })  : _isCompleted = isCompleted,
        _completionPercentage = completionPercentage;

  set isCompleted(bool value) {
    _isCompleted = value;
  }

  bool get isCompleted {
    _isCompleted = completionPercentage >= 1;
    return _isCompleted;
  }

  set completionPercentage(double value) {
    _completionPercentage = value;
  }

  double get completionPercentage {
    final conceptMissions = relatedMissions
        .where((m) => relatedMissionsIds.contains(m.id))
        .toList();

    if (conceptMissions.isEmpty) return 0.0;
    _completionPercentage = conceptMissions.where((m) => m.isCompleted.value).length /
        conceptMissions.length;
    return _completionPercentage;
  }

  List<Mission> get relatedMissionss =>
      relatedMissions.where((m) => relatedMissionsIds.contains(m.id)).toList();

  // double get completionPercentage {
  //   final conceptMissions = relatedMissions
  //       .where((m) => relatedMissionsIds.contains(m.id))
  //       .toList();

  //   if (conceptMissions.isEmpty) return 0.0;

  //   return conceptMissions.where((m) => m.isCompleted).length /
  //       conceptMissions.length;
  // }

  // bool get isCompleted =>
  //     (relatedMissions
  //             .where((m) => relatedMissionsIds.contains(m.id) && m.isCompleted)
  //             .toList()
  //             .length /
  //         relatedMissions
  //             .where((m) => relatedMissionsIds.contains(m.id))
  //             .toList()
  //             .length) >=
  //     1;
  factory Concept.fromJson(Map<String, dynamic> json, List<Mission> missions) {
    return Concept(
      id: json[r'$id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      estimatedHours: json['estimatedHours'] as int,
      prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
      relatedMissionsIds:
          List<String>.from(json['relatedMissions'] as List? ?? []),
      icon: json['icon'] as String,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      relatedMissions: missions,
      isCompleted: json['isCompleted'] as bool,
      completionPercentage: json['completionPercentage'] / 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimatedHours': estimatedHours,
      'prerequisites': prerequisites,
      'relatedMissions': relatedMissionsIds,
      'icon': icon,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
