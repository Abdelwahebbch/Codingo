import 'package:appwrite/models.dart';
import 'package:flutter/material.dart' hide Row;

enum MissionType {
  debug,
  complete,
  test,
  singleChoice,
  multipleChoice,
  ordering
}

class Mission {
  final String id;
  String? conceptId;
  final String title;
  final String description;
  final MissionType type;
  final int points;
  final int difficulty; // 1-5
  final String? initialCode;
  String? solution;
  final List<dynamic>? options;
  final List<dynamic>? correctOrder;
  ValueNotifier<bool> isCompleted;
  int nbFailed;
  int aiPointsUsed;
  List<String> conversation;
  bool isSurrendered;

  Mission(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.points,
      required this.difficulty,
      this.initialCode,
      this.conceptId,
      this.solution,
      this.options,
      this.correctOrder,
      required this.isCompleted,
      this.nbFailed = 0,
      this.aiPointsUsed = 0,
      this.conversation = const [],
      this.isSurrendered = false});

  factory Mission.completeMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.complete,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonCompleteMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.complete,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: ValueNotifier(row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }

  factory Mission.testMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.test,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"],
        solution: row.data["solution"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonTestMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.test,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted:ValueNotifier( row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"],
        solution: row["solution"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }

  factory Mission.debugMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.debug,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonDebugMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.debug,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: ValueNotifier(row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }

  factory Mission.singleChoice(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.singleChoice,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        options: row.data["options"] ?? [],
        solution: row.data["solution"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonSingleChoice(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.singleChoice,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: ValueNotifier(row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        options: row["options"],
        solution: row["solution"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }

  factory Mission.multipleChoice(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.multipleChoice,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        options: row.data["options"],
        solution: row.data["solution"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonMultipleChoice(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id2",
        title: row['title'],
        description: row['description'],
        type: MissionType.multipleChoice,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: ValueNotifier(row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        options: row["options"],
        solution: row["solution"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }

  //mrigla
  factory Mission.ordering(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.ordering,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: ValueNotifier(row.data['isCompleted']),
        conversation: List<String>.from(row.data['conversation'] ?? []),
        correctOrder: row.data["correctOrder"],
        options: row.data["options"],
        isSurrendered: row.data["Surrendered"] ?? false,
        conceptId: row.data['conceptId']);
  }
  factory Mission.jsonOrdering(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id2",
        title: row['title'],
        description: row['description'],
        type: MissionType.ordering,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: ValueNotifier(row['isCompleted']),
        conversation: List<String>.from(row['conversation'] ?? []),
        correctOrder: row["correctOrder"],
        options: row["options"],
        isSurrendered: row["Surrendered"] ?? false,
        conceptId: row['conceptId']);
  }
}
