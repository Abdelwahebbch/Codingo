import 'package:flutter/material.dart';

/// Enum for resource types
enum ResourceType {
  video,
  documentation,
  exercise,
  article,
  tutorial,
  webinar,
  book,
  interactive,
}

/// Enum for difficulty levels
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Model for individual learning resources
class LearningResource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final String url;
  final String? thumbnailUrl;
  final Duration? duration; // For videos
  final int? pageCount; // For books/PDFs
  final DifficultyLevel difficulty;
  final double rating; // 0-5 stars
  final int reviewCount;
  final List<String> tags;
  final String author;
  final DateTime publishedDate;
  final bool isBookmarked;
  final bool isCompleted;
  final int? completionPercentage;
  final String language; // e.g., 'en', 'fr'
  final bool isPremium;
  final String source; // e.g., 'YouTube', 'Udemy', 'Official Docs'

  LearningResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.duration,
    this.pageCount,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.author,
    required this.publishedDate,
    this.isBookmarked = false,
    this.isCompleted = false,
    this.completionPercentage,
    required this.language,
    this.isPremium = false,
    required this.source,
  });

  String get typeLabel {
    switch (type) {
      case ResourceType.video:
        return '🎥 Video';
      case ResourceType.documentation:
        return '📚 Documentation';
      case ResourceType.exercise:
        return '💪 Exercise';
      case ResourceType.article:
        return '📄 Article';
      case ResourceType.tutorial:
        return '🎓 Tutorial';
      case ResourceType.webinar:
        return '🎤 Webinar';
      case ResourceType.book:
        return '📖 Book';
      case ResourceType.interactive:
        return '🎮 Interactive';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.yellow;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }

  String get durationLabel {
    if (duration == null) return '';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Model for resource collections
class ResourceCollection {
  final String id;
  final String title;
  final String description;
  final List<LearningResource> resources;
  final String? coverImageUrl;
  final int totalDuration; // in minutes
  final double averageRating;
  final DateTime createdDate;
  final String createdBy;
  final int enrollmentCount;

  ResourceCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.resources,
    this.coverImageUrl,
    required this.totalDuration,
    required this.averageRating,
    required this.createdDate,
    required this.createdBy,
    required this.enrollmentCount,
  });

  int get completedCount => resources.where((r) => r.isCompleted).length;
  int get totalCount => resources.length;
  int get completionPercentage => (completedCount / totalCount * 100).toInt();
}

/// Model for user resource progress
class ResourceProgress {
  final String resourceId;
  final String userId;
  final int completionPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeSpentMinutes;
  final List<String> notes;
  final double? userRating;

  ResourceProgress({
    required this.resourceId,
    required this.userId,
    required this.completionPercentage,
    required this.startedAt,
    this.completedAt,
    required this.timeSpentMinutes,
    required this.notes,
    this.userRating,
  });

  bool get isCompleted => completionPercentage == 100;
}

/// Sample data for learning resources
class LearningResourcesSampleData {
  static List<LearningResource> getSampleVideoResources() {
    return [
      LearningResource(
        id: 'vid_001',
        title: 'Python Variables Explained',
        description: 'Complete guide to understanding variables and data types in Python',
        type: ResourceType.video,
        url: 'https://youtube.com/watch?v=example1',
        thumbnailUrl: 'https://via.placeholder.com/320x180?text=Python+Variables',
        duration: const Duration(minutes: 15),
        difficulty: DifficultyLevel.beginner,
        rating: 4.8,
        reviewCount: 1250,
        tags: ['variables', 'basics', 'python', 'data-types'],
        author: 'Code Academy',
        publishedDate: DateTime(2024, 1, 15),
        language: 'en',
        source: 'YouTube',
      ),
      LearningResource(
        id: 'vid_002',
        title: 'Advanced OOP Concepts',
        description: 'Deep dive into object-oriented programming principles and design patterns',
        type: ResourceType.video,
        url: 'https://youtube.com/watch?v=example2',
        thumbnailUrl: 'https://via.placeholder.com/320x180?text=OOP+Advanced',
        duration: const Duration(minutes: 45),
        difficulty: DifficultyLevel.advanced,
        rating: 4.6,
        reviewCount: 890,
        tags: ['oop', 'design-patterns', 'advanced'],
        author: 'Tech Master',
        publishedDate: DateTime(2024, 2, 20),
        language: 'en',
        source: 'YouTube',
      ),
    ];
  }

  static List<LearningResource> getSampleDocumentation() {
    return [
      LearningResource(
        id: 'doc_001',
        title: 'Python Official Documentation',
        description: 'Official Python documentation with comprehensive guides and API reference',
        type: ResourceType.documentation,
        url: 'https://docs.python.org',
        difficulty: DifficultyLevel.intermediate,
        rating: 4.9,
        reviewCount: 5000,
        tags: ['official', 'reference', 'comprehensive'],
        author: 'Python Software Foundation',
        publishedDate: DateTime(2023, 1, 1),
        language: 'en',
        source: 'Official',
      ),
      LearningResource(
        id: 'doc_002',
        title: 'Django REST Framework Guide',
        description: 'Complete guide to building REST APIs with Django',
        type: ResourceType.documentation,
        url: 'https://www.django-rest-framework.org',
        difficulty: DifficultyLevel.intermediate,
        rating: 4.7,
        reviewCount: 2100,
        tags: ['django', 'rest-api', 'web-development'],
        author: 'Django Community',
        publishedDate: DateTime(2024, 3, 10),
        language: 'en',
        source: 'Official',
      ),
    ];
  }

  static List<LearningResource> getSampleExercises() {
    return [
    
    ];
  }

  static List<LearningResource> getSampleTutorials() {
    return [
      LearningResource(
        id: 'tut_001',
        title: 'Getting Started with Python',
        description: 'Step-by-step tutorial for beginners to start with Python',
        type: ResourceType.tutorial,
        url: 'https://realpython.com/python-basics',
        difficulty: DifficultyLevel.beginner,
        rating: 4.8,
        reviewCount: 4500,
        tags: ['beginner', 'getting-started', 'tutorial'],
        author: 'Real Python',
        publishedDate: DateTime(2024, 1, 1),
        language: 'en',
        source: 'Real Python',
      ),
      LearningResource(
        id: 'tut_002',
        title: 'Building Microservices with Python',
        description: 'Learn how to build scalable microservices architecture',
        type: ResourceType.tutorial,
        url: 'https://example.com/microservices',
        difficulty: DifficultyLevel.advanced,
        rating: 4.7,
        reviewCount: 2200,
        tags: ['microservices', 'architecture', 'advanced'],
        author: 'Architecture Experts',
        publishedDate: DateTime(2024, 3, 20),
        language: 'en',
        source: 'Tech Blog',
      ),
    ];
  }

  static List<LearningResource> getSampleInteractiveResources() {
    return [
  
    ];
  }

  static List<LearningResource> getAllSampleResources() {
    return [
      ...getSampleVideoResources(),
      ...getSampleDocumentation(),
      ...getSampleExercises(),
      ...getSampleTutorials(),
      ...getSampleInteractiveResources(),
    ];
  }

  static ResourceCollection getSampleResourceCollection() {
    return ResourceCollection(
      id: 'col_001',
      title: 'Complete Python Mastery',
      description: 'A comprehensive collection of resources to master Python programming',
      resources: getAllSampleResources(),
      coverImageUrl: 'https://via.placeholder.com/400x300?text=Python+Mastery',
      totalDuration: 480, // 8 hours
      averageRating: 4.7,
      createdDate: DateTime(2024, 1, 1),
      createdBy: 'Learning Platform',
      enrollmentCount: 15000,
    );
  }
}
