import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:pfe_test/models/LearningPath/concept.dart';
import 'package:pfe_test/models/LearningPath/learning_path.dart';
import 'package:pfe_test/models/LearningPath/milestone.dart';
import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/services/CloudFunctions/appwrite_cloud_functions_service.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/chat/ai_tutor_chat.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/widgets/choice_challenge.dart';
import 'package:pfe_test/widgets/ordering_challenge.dart';
import 'package:provider/provider.dart';
import 'package:highlight/languages/python.dart';

class MissionDetailScreen extends StatefulWidget {
  final Mission mission;
  final LearningPath? learningPath;
  final Concept? concept;
  final LearningPathMilestone? milestone;
  final bool isLearningPath;

  const MissionDetailScreen({
    super.key,
    required this.isLearningPath,
    required this.mission,
    this.learningPath,
    this.concept,
    this.milestone,
  });

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  late CodeController _codeController;
  // ignore: prefer_typing_uninitialized_variables
  var _currentAnswer;

  @override
  void initState() {
    super.initState();
    _codeController =
        CodeController(text: widget.mission.initialCode, language: python);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    final isDark = themeManager.themeMode == ThemeMode.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mission.title),
          actions: [
            if (widget.mission.type.name == "debug" ||
                widget.mission.type.name == "complete")
              IconButton(
                icon: const Icon(Icons.restore_rounded,
                    color: AppTheme.accentColor),
                onPressed: () {
                  _codeController.text = widget.mission.initialCode!.trim();
                },
              ),
          ],
        ),
        body: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: isDark ? AppTheme.cardColor : const Color(0xFFF5F6FA),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("MISSION OBJECTIVE",
                          style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      if (!widget.isLearningPath)
                        TextButton(
                            onPressed: () async {
                              final authService = Provider.of<DataProvider>(
                                  context,
                                  listen: false);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  title: Center(
                                      child: Text(
                                    "Warning !",
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  )),
                                  content: const Text(
                                      "Are you sure you want to surrender?"),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await authService.surrendereMission(
                                                widget.mission.id);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              "Surrendere",
                              style: TextStyle(color: Colors.redAccent),
                            ))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.mission.description,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChallengeInterface(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.mission.solution = _codeController.text.trim();
                        _showAITutor(context);
                      },
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text("Ask me"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _checkAnswer();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildChallengeInterface(context) {
    final themeManager = Provider.of<ThemeManager>(context);

    final isDark = themeManager.themeMode == ThemeMode.dark;
    switch (widget.mission.type) {
      case MissionType.debug:
      case MissionType.complete:
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: SingleChildScrollView(
              child: CodeField(
            minLines: 20,
            controller: _codeController,
            textStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.secondaryColor : Colors.white,
            ),
          )),
        );
      case MissionType.test:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CODE",
              style: TextStyle(
                color: AppTheme.accentColor, 
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 500,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: SingleChildScrollView(
                  child: CodeField(
                minLines: 20,
                controller: _codeController,
                textStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.secondaryColor : Colors.white,
                ),
              )),
            ),
            const SizedBox(height: 8),
            const Text(
              "OUTPUT ",
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            TextField(
              onChanged: (txt) {
                _currentAnswer = txt.trim();
              },
            ),
          ],
        );
      case MissionType.multipleChoice:
      case MissionType.singleChoice:
        if (widget.mission.initialCode == null) {
          return ChoiceChallenge(
              mission: widget.mission,
              onAnswerChanged: (answer) {
                return _currentAnswer = answer;
              });
        } else {
          return Column(
            children: [
              const Text("Test"),
              ChoiceChallenge(
                  mission: widget.mission,
                  onAnswerChanged: (answer) {
                    return _currentAnswer = answer;
                  }),
            ],
          );
        }

      case MissionType.ordering:
        return OrderingChallenge(
            mission: widget.mission,
            onOrderChanged: (order) {
              return _currentAnswer = order;
            });
    }
  }

  void _showAITutor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AITutorChat(
              mission: widget.mission, scrollController: controller),
        ),
      ),
    );
  }

  double getRate() {
    final authService = Provider.of<DataProvider>(context, listen: false);
    double rate = 1 -
        (((widget.mission.aiPointsUsed /
                    (authService.progress.totalPoints + 1)) *
                0.2) +
            ((widget.mission.nbFailed /
                    (authService.progress.totalFailures + 1)) *
                0.1));
    if (rate < 0.0) {
      return 0.0;
    }
    return rate;
  }

  Future<void> _checkAnswer() async {
    final authService = Provider.of<DataProvider>(context, listen: false);

    bool isCorrect = false;
    double rate = 0.0;
    switch (widget.mission.type) {
      case MissionType.debug:
      case MissionType.complete:
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            content: SizedBox(
              width: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Checking...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
        final List<dynamic> check =
            await AppwritecloudfunctionsService.checkAnwser(
                authService.progress,
                widget.mission,
                _codeController.text.trim());
        if (!mounted) return;
        Navigator.pop(context);
        isCorrect = check[0];
        rate = getRate();

        break;
      case MissionType.singleChoice:
        isCorrect = _currentAnswer
            .toString()
            .contains(widget.mission.solution.toString());
        rate = getRate();
        break;
      case MissionType.multipleChoice:
        if (_currentAnswer is List<String>) {
          final correctAnswers = widget.mission.solution?.split(',') ?? [];
          isCorrect = _currentAnswer.length == correctAnswers.length &&
              _currentAnswer.every((item) => correctAnswers.contains(item));
          rate = getRate();
        }
        break;
      case MissionType.ordering:
        if (_currentAnswer is List<String>) {
          final correctOrder = widget.mission.correctOrder ?? [];
          isCorrect = _currentAnswer.length == correctOrder.length &&
              equals(_currentAnswer, correctOrder);
          rate = getRate();
        }
        break;
      case MissionType.test:
        if (widget.mission.solution == null) {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              content: SizedBox(
                width: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Checking...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
          final List<dynamic> check =
              await AppwritecloudfunctionsService.checkAnwser(
                  authService.progress, widget.mission, _currentAnswer);
          if (!mounted) return;
          Navigator.pop(context);
          isCorrect = check[0];
          rate = getRate();
        } else {
          isCorrect = _currentAnswer.toString().contains(
              widget.mission.solution.toString().replaceAll('\n', ' '));
          rate = getRate();
        }
        break;
    }

    if (isCorrect && !widget.isLearningPath) {
      authService.updateXp(widget.mission.points);
      authService.updateMissionStatus(widget.mission.id, rate);
    } else if (!widget.isLearningPath) {
      authService.updateFailedNb(widget.mission.id);
    } else if (isCorrect && widget.isLearningPath) {
      setState(() {
        widget.mission.isCompleted.value = true;
      });
      authService.saveMission(widget.mission, widget.learningPath!.id);

      // authService.saveLearningPath();
      //authService.updateMissionStatus(widget.mission.id, rate);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? "Mission Accomplished !" : "Not Quite..."),
        content: Text(isCorrect
            ? (widget.isLearningPath)
                ? "Great job !"
                : "Great job ! You've earned ${widget.mission.points} XP."
            : "That's not the right answer. Try asking the AI Tutor for a hint!"),
        actions: [
          TextButton(
            onPressed: () async {
              if (isCorrect) {
                if (widget.isLearningPath) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()),
                      (Route<dynamic> route) => false);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

bool equals(List l1, List l2) {
  if (l1.length != l2.length) return false;
  for (int i = 0; i < l1.length; i++) {
    if (l1[i] != l2[i]) return false;
  }
  return true;
}
