import 'dart:convert';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart' hide Row;
import 'package:appwrite/models.dart';
import 'package:pfe_test/models/LearningPath/concept.dart';
import 'package:pfe_test/models/LearningPath/learning_path.dart';
import 'package:pfe_test/models/LearningPath/milestone.dart';
import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/CloudFunctions/appwrite_cloud_functions_service.dart';
import 'package:pfe_test/services/Data/data_repository.dart';

class DataProvider extends ChangeNotifier {
  final DataRepository dataRepository;

  // Private - access via getter so the field cannot be accidentally replaced.
  final AuthProvider _authProvider;
  AuthProvider get authProvider => _authProvider;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  // ─── User data ────────────────────────────────────────────────────────────
  UserInfo progress = _emptyUserInfo();
  bool isFirstLogin = false;
  LearningPath? path;
  Map<String, dynamic>? userGoals;
  // ─────────────────────────────────────────────────────────────────────────

  DataProvider({
    required this.dataRepository,
    required AuthProvider authProvider,
  }) : _authProvider = authProvider {
    // ─── React to every future auth-state change ──────────────────────────
    _authProvider.addListener(_onAuthChanged);

    // ─── Handle the case where AuthProvider already finished init()
    //     before this listener was attached (possible with fast storage).
    if (_authProvider.status == AuthStatus.authenticated) {
      // Use microtask so we don't call init() inside a constructor body
      // while the provider tree is still being built.
      Future.microtask(init);
    }
    // ─────────────────────────────────────────────────────────────────────
  }

  // ─── Auth listener ───────────────────────────────────────────────────────
  void _onAuthChanged() {
    switch (_authProvider.status) {
      case AuthStatus.authenticated:
        // A user just signed in (or init confirmed an existing session).
        init();
        break;
      case AuthStatus.unauthenticated:
        // User signed out - wipe local data so nothing leaks between sessions.
        _clearData();
        break;
      case AuthStatus.uninitialized:
        // Still checking - nothing to do yet.
        break;
    }
  }

  @override
  void dispose() {
    // Always remove the listener to prevent memory leaks.
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
  // ─────────────────────────────────────────────────────────────────────────

  bool _isInitializing = false; // add this field

  Future<void> init() async {
    if (_isInitializing) return; // ← already running, skip
    _isInitializing = true;
    _isLoading = true;
    notifyListeners();
    try {
      await getUserInfo();
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      debugPrint('DataProvider.init - error: $e');
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Wipe all user-specific state when the session ends.
  void _clearData() {
    progress = _emptyUserInfo();
    path = null;
    userGoals = null;
    isFirstLogin = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Static helper so _emptyUserInfo can be called both in the field
  //     initializer and in _clearData() without repeating the literal.
  static UserInfo _emptyUserInfo() {
    return UserInfo(
      progLanguage: 'not selected',
      username: '',
      experience: 0,
      totalPoints: 0,
      earnedBadges: [],
      bio: '',
      imageId: '',
      email: '',
      rank: 0,
      difficultySelected: 'Intermediate',
      nbMissions: 0,
      missions: [],
      badgesProgress: {
        'debug': 0,
        'complete': 0,
        'multipleChoice': 0,
        'ordering': 0,
        'singleChoice': 0,
        'test': 0,
      },
      showingBadges: [],
      nbMissionCompletedWithoutHints: 0,
      totalFailures: 0,
      totalAIQuestions: 0,
      elo: 0,
    );
  }

  Future<void> completeOnboarding(
    Map<String, String> data,
    bool pathCreation,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    try {
      userGoals = data;

      if (startDate != null && endDate != null) {
        await dataRepository.createRow(
          tableId: 'user_goals',
          rowId: _authProvider.currentUser!.id,
          data: {
            'username': _authProvider.currentUser!.name,
            'prompt': jsonEncode(data),
            'startDate': startDate.toString(),
            'endDate': endDate.toString(),
          },
        );
      } else {
        await dataRepository.createRow(
          tableId: 'user_goals',
          rowId: _authProvider.currentUser!.id,
          data: {
            'username': _authProvider.currentUser!.name,
            'prompt': jsonEncode(data),
          },
        );
      }

      final rows = await dataRepository.getRows(
        tableId: 'mock_mission',
        queries: [
          Query.equal('user_category', data['journey'].toString()),
          Query.equal('language', progress.progLanguage),
        ],
      );

      for (final row in rows.rows) {
        await dataRepository.createRow(
          tableId: 'missions',
          rowId: ID.unique(),
          data: {
            'user_id': _authProvider.currentUser!.id,
            'title': row.data['title'],
            'type': row.data['type'],
            'difficulty': row.data['difficulty'],
            'initialCode': row.data['initialCode'],
            'solution': row.data['solution'],
            'options': List<String>.from(row.data['options']),
            'correctOrder': List<String>.from(row.data['correctOrder']),
            'points': row.data['points'],
            'isCompleted': false,
            'description': row.data['description'],
            'nbFailed': 0,
            'aiPointsUsed': 0,
            'conversation': [],
            'rate': 0,
          },
        );
      }
    } catch (e) {
      debugPrint('DataProvider.completeOnboarding - error: $e');
      rethrow;
    }
  }

  Future<void> getUserInfo() async {
    try {
      Row? row;
      try {
        row = await dataRepository.getRow(
          tableId: 'user_profiles',
          rowId: _authProvider.currentUser!.id,
        );
      } on AppwriteException catch (e) {
        if (e.code == 404) {
          debugPrint('DataProvider.getUserInfo - no profile, first login');
          isFirstLogin = true;
          progress = _emptyUserInfo();
          await dataRepository.createRow(
            rowId: _authProvider.currentUser!.id,
            tableId: 'user_profiles',
            data: {
              'progLanguage': 'not selected',
              'username': _authProvider.currentUser!.name,
              'experience': 500,
              'totalPoints': 0,
              'earnedBadges': [],
              'bio': '',
              'imageId': '',
              'difficulty': 'Intermediate',
              'nbMission': 0,
              'badgesProgress': jsonEncode({
                'debug': 0,
                'complete': 0,
                'multipleChoice': 0,
                'ordering': 0,
                'singleChoice': 0,
                'test': 0,
              }),
              'nbMissionCompletedWithoutHints': 0,
              'totalFailures': 0,
              'totalAIQuestions': 0,
              'elo': 0,
            },
          );
          return;
        }
        rethrow;
      }

      final int rank = await getRank();

      progress = UserInfo(
        progLanguage: row.data['progLanguage'] ?? 'not selected',
        username: _authProvider.currentUser!.name,
        experience: row.data['experience'],
        totalPoints: row.data['totalPoints'],
        earnedBadges: List<String>.from(row.data['earnedBadges'] ?? []),
        bio: row.data['bio'],
        imageId: row.data['imageId'],
        email: _authProvider.currentUser!.email,
        rank: rank,
        difficultySelected: row.data['difficulty'] ?? 'Intermediate',
        nbMissions: row.data['nbMission'] ?? 0,
        missions: await getMissions(),
        badgesProgress: row.data['badgesProgress'] != null
            ? jsonDecode(row.data['badgesProgress'])
            : {},
        showingBadges: [],
        nbMissionCompletedWithoutHints:
            row.data['nbMissionCompletedWithoutHints'] ?? 0,
        totalFailures: row.data['totalFailures'] ?? 0,
        totalAIQuestions: row.data['totalAIQuestions'] ?? 0,
        elo: row.data['elo'],
      );
      try {
        await getuserGoals();
      } on AppwriteException catch (e) {
        if (e.code == 404) {
          debugPrint(
              'DataProvider.getUserInfo - no user_goals, sending to onboarding');
          isFirstLogin = true;
          return;
        }
        rethrow;
      }
      try {
        path = await fetchLearningPath(_authProvider.currentUser!.id);
      } on AppwriteException catch (e) {
        if (e.code != 404) rethrow;
        //TODO Call for creating LP
        AppwritecloudfunctionsService.createLearningPath(
            id: authProvider.currentUser!.id,
            desc:userGoals!["prompt"] ??"",
            progLang: progress.progLanguage);
        debugPrint('DataProvider.getUserInfo - no learning path yet');
      }
    } catch (e) {
      debugPrint('DataProvider.getUserInfo - error: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> getuserGoals() async {
    final row = await dataRepository.getRow(
      tableId: 'user_goals',
      rowId: _authProvider.currentUser!.id,
    );
    progress.rate = row.data['rate'] / 1;
    userGoals = jsonDecode(row.data['prompt']);
  }

  Future<List<Mission>> getMissions() async {
    try {
      late RowList response;
      String date = DateTime.now().toUtc().toIso8601String().split('T').first;

      response = await dataRepository.getRows(
        tableId: 'missions',
        queries: [
          Query.equal('user_id', _authProvider.currentUser!.id),
          Query.createdAfter('${date}T00:00:00Z'),
          Query.createdBefore('${date}T23:59:59Z'),
          Query.orderDesc('\$createdAt'),
        ],
      );

      if (response.rows.isEmpty) {
        date = DateTime.now()
            .toUtc()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')
            .first;

        response = await dataRepository.getRows(
          tableId: 'missions',
          queries: [
            Query.equal('user_id', _authProvider.currentUser!.id),
            Query.createdAfter('${date}T00:00:00Z'),
            Query.createdBefore('${date}T23:59:59Z'),
            Query.orderDesc('\$createdAt'),
          ],
        );
      }

      return response.rows.map((doc) {
        final MissionType type = MissionType.values
            .firstWhere((e) => e.name.contains(doc.data['type']));
        switch (type) {
          case MissionType.complete:
            return Mission.completeMission(doc);
          case MissionType.debug:
            return Mission.debugMission(doc);
          case MissionType.multipleChoice:
            return Mission.multipleChoice(doc);
          case MissionType.ordering:
            return Mission.ordering(doc);
          case MissionType.singleChoice:
            return Mission.singleChoice(doc);
          case MissionType.test:
            return Mission.testMission(doc);
        }
      }).toList();
    } catch (e) {
      debugPrint('DataProvider.getMissions - error: $e');
      rethrow;
    }
  }

  Future<void> updateMissionAiPoints(String id) async {
    try {
      int previousAiPointsUsed = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          previousAiPointsUsed = progress.missions[i].aiPointsUsed;
          progress.missions[i].aiPointsUsed = previousAiPointsUsed + 1;
        }
      }
      final int currentAiPointsUsed = previousAiPointsUsed + 1;
      final int currentTotalAIQuestions = progress.totalAIQuestions + 1;
      progress.totalAIQuestions = currentTotalAIQuestions;
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {'aiPointsUsed': currentAiPointsUsed},
      );
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'totalAIQuestions': currentTotalAIQuestions},
      );
      await updateUserPoints(-1);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserPoints(int nb) async {
    try {
      final int currentTotalPoints = progress.totalPoints + nb;
      progress.totalPoints = currentTotalPoints;
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'totalPoints': currentTotalPoints},
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToConversation(
      String role, int index, String id, String msg) async {
    try {
      progress.missions[index].conversation
          .add(jsonEncode({'role': role, 'message': msg}));
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {'conversation': progress.missions[index].conversation},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateXp(int xp) async {
    try {
      final int newExperience = progress.experience + xp;
      progress.experience = newExperience;
      notifyListeners();
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'experience': newExperience},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMissionStatus(String id, double rate) async {
    try {
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {'isCompleted': true, 'rate': rate},
      );
      progress.nbMissions += 1;
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'nbMission': progress.nbMissions},
      );
      int? missionNb;
      int missionDifficulty = 0;
      int missionPoints = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isCompleted.value = true;
          missionDifficulty = progress.missions[i].difficulty;
          missionNb = i;
        }
      }
      await updateRate(missionDifficulty, missionPoints, rate);
      await checkbadges(missionNb!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> surrendereMission(String id) async {
    try {
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {'Surrendered': true},
      );
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {'rate': 0.0},
      );
      int missionDifficulty = 0;
      int missionPoints = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isSurrendered = true;
          missionDifficulty = progress.missions[i].difficulty;
          missionPoints = progress.missions[i].points;
        }
      }
      await updateRate(missionDifficulty, missionPoints, 0);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void emptyShowingBadges() {
    progress.showingBadges = [];
    notifyListeners();
  }

  Future<void> updateRate(
      int missionDifficulty, int missionPoints, double S) async {
    try {
      final double E =
          1 / (1 + pow(10, ((missionDifficulty - progress.rate) / 4)));
      final double k = 0.3 * (1 + 0.5 * (missionDifficulty / 10));
      final double s2 = S * (1 + 0.1 * (missionPoints / 2500));
      double newRate = progress.rate + k * (s2 - E);
      progress.elo += ((k * (s2 - E)) * 100).toInt();
      if (progress.elo < 0) progress.elo = 0;
      if (newRate > 10) newRate = 10;
      if (newRate < 0.0) newRate = 0.0;
      progress.rate = double.parse(newRate.clamp(1, 10).toStringAsFixed(2));
      notifyListeners();
      await dataRepository.updateRow(
        tableId: 'user_goals',
        rowId: _authProvider.currentUser!.id,
        data: {'rate': progress.rate},
      );
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'elo': progress.elo},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkbadges(int missionNb) async {
    try {
      final String missionType = progress.missions[missionNb].type.name;
      progress.badgesProgress[missionType] =
          (progress.badgesProgress[missionType]! + 1);

      int missionsCompletedToday = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].isCompleted.value) missionsCompletedToday += 1;
      }

      Future<void> award(String badge) async {
        if (!progress.earnedBadges.contains(badge)) {
          progress.earnedBadges.add(badge);
          progress.showingBadges.add(badge);
          await updateUserPoints(10);
        }
      }

      if (progress.badgesProgress['debug']! >= 10) await award('Bug Hunter');
      if (progress.nbMissionCompletedWithoutHints >= 10)
        await award('Code Ninja');
      if (progress.badgesProgress['test']! >= 20) await award('Test Master');
      if (missionsCompletedToday >= 5) await award('Fast Learner');
      if (progress.badgesProgress['ordering']! >= 10) await award('Architect');
      if (progress.badgesProgress['complete']! >= 10 &&
          progress.totalFailures <= 30) {
        await award('Clean Coder');
      }
      if (progress.badgesProgress['singleChoice']! >= 10 &&
          progress.badgesProgress['multipleChoice']! >= 10) {
        await award('Team Player');
      }
      if (progress.totalAIQuestions >= 50) await award('AI Whisperer');

      notifyListeners();
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {
          'badgesProgress': jsonEncode(progress.badgesProgress),
          'earnedBadges': progress.earnedBadges,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFailedNb(String id) async {
    try {
      progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed += 1;
      await dataRepository.updateRow(
        tableId: 'missions',
        rowId: id,
        data: {
          'nbFailed':
              progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed,
        },
      );
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {
          'totalFailures':
              progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed,
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserGoals(Map<String, String> data) async {
    await dataRepository.updateRow(
      tableId: 'user_goals',
      rowId: _authProvider.currentUser!.id,
      data: {'prompt': jsonEncode(data)},
    );
    userGoals = data;
    notifyListeners();
  }

  Future<void> fixEducationTime(DateTime? startDate, DateTime? endDate) async {
    await dataRepository.updateRow(
      tableId: 'user_goals',
      rowId: _authProvider.currentUser!.id,
      data: {
        'startDate': startDate?.toString(),
        'endDate': endDate?.toString(),
      },
    );
  }

  Future<void> updateProfile(
      String imagePath, String userName, String bio) async {
    try {
      if (imagePath.isNotEmpty) {
        final file = await dataRepository.appwriteService.storage.createFile(
          bucketId: '69891b1d0012c9a7e862',
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: imagePath,
            filename: imagePath.split('/').last,
          ),
        );
        await dataRepository.updateRow(
          tableId: 'user_profiles',
          rowId: _authProvider.currentUser!.id,
          data: {'imageId': file.$id, 'bio': bio},
        );
        progress.bio = bio;
        progress.imageId = file.$id;
        progress.username = userName;
      } else {
        await dataRepository.updateRow(
          tableId: 'user_profiles',
          rowId: _authProvider.currentUser!.id,
          data: {'bio': bio},
        );
        progress.bio = bio;
        progress.username = userName;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLanguageSelected(String languageSelected) async {
    try {
      await dataRepository.updateRow(
        tableId: 'user_profiles',
        rowId: _authProvider.currentUser!.id,
        data: {'progLanguage': languageSelected},
      );
      progress.progLanguage = languageSelected;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getRank() async {
    try {
      final r = await dataRepository.getRows(
        tableId: 'user_profiles',
        queries: [Query.orderDesc('experience')],
      );
      return r.rows.indexWhere(
            (row) => row.$id == _authProvider.currentUser!.id,
          ) +
          1;
    } on AppwriteException catch (e) {
      debugPrint('DataProvider.getRank - error: ${e.message}');
      rethrow;
    }
  }

  Future<LearningPath?> fetchLearningPath(String learningPathId) async {
    try {
      final lpRow = await dataRepository.getRow(
        tableId: 'learnig_paths',
        rowId: learningPathId,
      );

      final results = await Future.wait([
        dataRepository.getRows(
          tableId: 'learnig_path_concepts',
          queries: [Query.equal('learningPathId', learningPathId)],
        ),
        dataRepository.getRows(
          tableId: 'learnig_path_milestones',
          queries: [Query.equal('learningPathId', learningPathId)],
        ),
        dataRepository.getRows(
          tableId: 'learning_path_missions',
          queries: [Query.equal('learningPathId', learningPathId)],
        ),
      ]);

      final missions = results[2].rows.map((doc) {
        final MissionType type = MissionType.values
            .firstWhere((e) => e.name.contains(doc.data['type']));
        switch (type) {
          case MissionType.complete:
            return Mission.completeMission(doc);
          case MissionType.debug:
            return Mission.debugMission(doc);
          case MissionType.multipleChoice:
            return Mission.multipleChoice(doc);
          case MissionType.ordering:
            return Mission.ordering(doc);
          case MissionType.singleChoice:
            return Mission.singleChoice(doc);
          case MissionType.test:
            return Mission.testMission(doc);
        }
      }).toList();

      final concepts = results[0]
          .rows
          .map((d) => Concept.fromJson(d.data, missions))
          .toList();

      final milestones = results[1]
          .rows
          .map((d) => LearningPathMilestone.fromJson(d.data, concepts))
          .toList();

      return LearningPath(
        id: lpRow.$id,
        language: lpRow.data['language'],
        milestones: milestones,
        concepts: concepts,
        missions: missions,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        currentLevel: lpRow.data['currentLevel'],
      );
    } catch (e) {
      debugPrint('DataProvider.fetchLearningPath - error: $e');
      return null;
    }
  }

  Future<void> saveLearningPath() async {
    try {
      final lpDoc = await _saveLearningPathRow(path!);
      final learningPathId = lpDoc.$id;
      await Future.wait([
        ...path!.concepts.map((c) => _saveConcept(c, learningPathId)),
        ...path!.milestones.map((m) => _saveMilestone(m, learningPathId)),
        ...path!.missions.map((ms) => _saveMission(ms, learningPathId)),
      ]);
      await fetchLearningPath(path!.id);
      debugPrint('LearningPath saved successfully (id: $learningPathId)');
      notifyListeners();
    } catch (e) {
      debugPrint('DataProvider.saveLearningPath - error: $e');
      rethrow;
    }
  }

  Future<Row> _saveLearningPathRow(LearningPath path) async {
    return dataRepository.updateRow(
      tableId: 'learnig_paths',
      rowId: path.id,
      data: {
        'totalConceptsCompleted': path.totalConceptsCompleted,
        'overallProgressPercentage': path.overallProgressPercentage,
        'currentLevel': path.currentLevel,
        'startedAt': path.startedAt.toIso8601String(),
        'completedAt': path.completedAt?.toIso8601String(),
      },
    );
  }

  Future<void> _saveConcept(Concept concept, String learningPathId) async {
    await dataRepository.updateRow(
      tableId: 'learnig_path_concepts',
      rowId: concept.id,
      data: {
        'isCompleted': concept.isCompleted,
        'completionPercentage': concept.completionPercentage,
        'startedAt': concept.startedAt?.toIso8601String(),
        'completedAt': concept.completedAt?.toIso8601String(),
      },
    );
  }

  Future<void> _saveMilestone(
      LearningPathMilestone milestone, String learningPathId) async {
    await dataRepository.updateRow(
      rowId: milestone.id,
      tableId: 'learnig_path_milestones',
      data: {
        'isUnlocked': milestone.isUnlocked,
        'isCompleted': milestone.isCompleted,
        'completionPercentage': milestone.completionPercentage,
        'completedAt': milestone.completedAt?.toIso8601String(),
      },
    );
  }

  Future<void> _saveMission(Mission mission, String learningPathId) async {
    await dataRepository.updateRow(
      tableId: 'learning_path_missions',
      rowId: mission.id,
      data: {
        'isCompleted': mission.isCompleted,
        'Surrendered': mission.isSurrendered,
      },
    );
  }
}
