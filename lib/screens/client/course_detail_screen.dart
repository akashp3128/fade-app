import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../config/theme.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  VideoPlayerController? _videoController;
  int _currentLessonIndex = 0;
  bool _isLocked = true; // Mock lock state

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo(String url) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _videoController?.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd fetch the specific course. For now, grabbing from list.
    final coursesAsync = ref.watch(coursesProvider);
    final lessonsAsync = ref.watch(courseLessonsProvider(widget.courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: coursesAsync.when(
        data: (courses) {
          final course = courses.firstWhere(
            (c) => c.id == widget.courseId,
            orElse: () => courses.first, // Fallback for mock safety
          );

          return CustomScrollView(
            slivers: [
              // Video Player Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            if (course.thumbnailUrl != null)
                              Hero(
                                tag: 'course_thumb_${course.id}',
                                child: Image.network(course.thumbnailUrl!, fit: BoxFit.cover),
                              ),
                            Container(color: Colors.black54),
                            const Center(
                              child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),

              // Course Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        course.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _InfoChip(icon: Icons.timer, label: '${course.durationMinutes} mins'),
                          const SizedBox(width: AppSpacing.md),
                          _InfoChip(icon: Icons.signal_cellular_alt, label: course.difficultyLevel),
                          const SizedBox(width: AppSpacing.md),
                          _InfoChip(icon: Icons.star, label: '4.9 (120)'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_isLocked && course.isPremium)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Unlock logic (payment)
                              setState(() => _isLocked = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Course Unlocked!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.textOnAccent,
                            ),
                            child: Text('Unlock Full Course - \$${course.price}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Lesson List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Curriculum',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              lessonsAsync.when(
                data: (lessons) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lesson = lessons[index];
                      final isLocked = _isLocked && !lesson.isPreview;
                      final isPlaying = _currentLessonIndex == index;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isPlaying ? AppColors.accent : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Icon(
                            isLocked ? Icons.lock : (isPlaying ? Icons.pause : Icons.play_arrow),
                            color: isPlaying ? AppColors.textOnAccent : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          lesson.title,
                          style: TextStyle(
                            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                            color: isPlaying ? AppColors.accent : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${lesson.durationMinutes} min',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        onTap: () {
                          if (isLocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Purchase course to unlock this lesson.')),
                            );
                          } else {
                            setState(() => _currentLessonIndex = index);
                            _initializeVideo(lesson.videoUrl);
                          }
                        },
                      );
                    },
                    childCount: lessons.length,
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
