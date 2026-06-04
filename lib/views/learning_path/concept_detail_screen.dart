import 'package:flutter/material.dart';
import 'package:pfe_test/models/LearningPath/concept.dart';
import 'package:pfe_test/models/LearningPath/learning_path.dart';
import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/mission/mission_detail_screen.dart';

class ConceptDetailScreen extends StatefulWidget {
  final Concept concept;
  final LearningPath learningPath;

  const ConceptDetailScreen({
    super.key,
    required this.concept,
    required this.learningPath,
  });

  @override
  State<ConceptDetailScreen> createState() => _ConceptDetailScreenState();
}

class _ConceptDetailScreenState extends State<ConceptDetailScreen> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = false;
  }

  @override
  Widget build(BuildContext context) {
    final prerequisiteConcepts = widget.learningPath.concepts
        .where((c) => widget.concept.prerequisites.contains(c.id))
        .toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Concept Details'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isBookmarked = !_isBookmarked;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.concept.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.concept.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.concept.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDifficultyBadge(),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.concept.estimatedHours}h',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              ListenableBuilder(
                listenable: Listenable.merge(
                  widget.concept.relatedMissionss
                      .map((m) => m.isCompleted)
                      .toList(),
                ),
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              '${(widget.concept.completionPercentage * 100).round()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: widget.concept.completionPercentage,
                            minHeight: 12,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.concept.isCompleted
                                  ? Colors.green
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.concept.startedAt != null)
                          Column(
                            children: [
                              _buildProgressInfo(
                                'Started',
                                _formatDate(widget.concept.startedAt!),
                                '📅',
                              ),
                              const SizedBox(height: 8),
                              if (widget.concept.completedAt != null)
                                _buildProgressInfo(
                                  'Completed',
                                  _formatDate(widget.concept.completedAt!),
                                  '✅',
                                ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.concept.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              if (prerequisiteConcepts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prerequisites',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      ...prerequisiteConcepts.map((concept) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: concept.isCompleted
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(
                                  concept.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        concept.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        concept.category,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (concept.isCompleted)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related Missions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.concept.relatedMissions.isEmpty)
                      const Text('AA'),
                    const SizedBox(height: 12),
                    ...widget.learningPath.missions
                        .where((m) => m.conceptId!.contains(widget.concept.id))
                        .map((mission) => _missionTile(mission, context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _missionTile(Mission mission, BuildContext context) {
    return GestureDetector(
      onTap: () => mission.isCompleted.value
          ? null
          : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MissionDetailScreen(
                      isLearningPath: true,
                      mission: mission,
                      concept: widget.concept,
                      learningPath: widget.learningPath))),
      child: ValueListenableBuilder<bool>(
        valueListenable: mission.isCompleted,
        builder: (context, isCompleted, _) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.assignment,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Practice this concept',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.arrow_forward,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    final colors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    final labels = ['Beginner', 'Easy', 'Medium', 'Hard', 'Expert'];
    final difficulty = widget.concept.difficulty - 1;

    return Container(
      decoration: BoxDecoration(
        color: colors[difficulty].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        labels[difficulty],
        style: TextStyle(
          color: colors[difficulty],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value, String emoji) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
