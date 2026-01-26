import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';

// Mock Provider for Courses
class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  CourseNotifier() : super(const AsyncValue.loading()) {
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncValue.data([
      Course(
        id: 'course_1',
        barberId: 'barber_1',
        title: 'The Perfect Skin Fade',
        description: 'Master the art of the blurry fade step by step.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=400',
        price: 29.99,
        difficultyLevel: 'Advanced',
        durationMinutes: 45,
        lessonCount: 3,
        createdAt: DateTime.now(),
      ),
      Course(
        id: 'course_2',
        barberId: 'barber_2',
        title: 'Beard Sculpting 101',
        description: 'Learn how to shape and trim beards like a pro.',
        thumbnailUrl: 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=400',
        price: 19.99,
        difficultyLevel: 'Beginner',
        durationMinutes: 30,
        lessonCount: 5,
        createdAt: DateTime.now(),
      ),
    ]);
  }
}

final coursesProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  return CourseNotifier();
});

// Mock Provider for Lessons
final courseLessonsProvider = FutureProvider.family<List<CourseLesson>, String>((ref, courseId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  if (courseId == 'course_1') {
    return [
      const CourseLesson(
        id: 'lesson_1',
        courseId: 'course_1',
        title: 'Tools & Preparation',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-barber-preparing-tools-12626-large.mp4',
        durationMinutes: 10,
        orderIndex: 1,
        isPreview: true,
      ),
      const CourseLesson(
        id: 'lesson_2',
        courseId: 'course_1',
        title: 'Setting Guidelines',
        videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-scissors-and-comb-12624-large.mp4',
        durationMinutes: 15,
        orderIndex: 2,
        isPreview: false,
      ),
    ];
  }
  return [];
});
