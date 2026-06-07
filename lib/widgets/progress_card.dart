import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/views/learning_path/learning_path_screen.dart';
import 'package:pfe_test/widgets/rank_widget.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class ProgressCard extends StatelessWidget {
  final UserInfo user;

  const ProgressCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final dataservice = Provider.of<DataProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        try {
          final learningPath = dataservice.path;
          if (learningPath == null) throw Exception("No Learning Path !");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearningPathScreen(
                learningPath: learningPath,
              ),
            ),
          );
        } catch (e) {
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    icon: Icon(Icons.info),
                    title: Text(
                      "No Learning Path !",
                      style: TextStyle(fontSize: 12),
                    ),
                  ));
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Level",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text("${user.userLevel}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    RankWidget(
                        elo: dataservice.progress.elo,
                        rank: dataservice.progress.rank,
                        showBar: false,
                        height: 50,
                        width: 50),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // Animated Total Points
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: user.totalPoints),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Text(
                            "$value 💎",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Animated Progress Bar and Percentage Text
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: user.progressToNextLevel),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${(value * 100).toInt()}% to Level ${user.userLevel + 1}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const Text(
                          "Tap to view learning path",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}