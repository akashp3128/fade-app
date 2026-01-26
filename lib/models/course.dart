import 'package:flutter/foundation.dart';

@immutable
class Course {
  final String id;
  final String barberId;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final double price;
  final bool isPremium;
  final String difficultyLevel;
  final int durationMinutes;
  final int lessonCount;
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.barberId,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.price = 0.0,
    this.isPremium = true,
    this.difficultyLevel = 'intermediate',
    this.durationMinutes = 0,
    this.lessonCount = 0,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      barberId: json['barber_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isPremium: json['is_premium'] as bool? ?? true,
      difficultyLevel: json['difficulty_level'] as String? ?? 'intermediate',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      lessonCount: json['lesson_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

@immutable
class CourseLesson {
  final String id;
  final String courseId;
  final String title;
  final String videoUrl;
  final int durationMinutes;
  final int orderIndex;
  final bool isPreview;

  const CourseLesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.videoUrl,
    required this.durationMinutes,
    required this.orderIndex,
    this.isPreview = false,
  });

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      orderIndex: json['order_index'] as int? ?? 0,
      isPreview: json['is_preview'] as bool? ?? false,
    );
  }
}
