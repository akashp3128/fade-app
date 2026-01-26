import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Academy Header
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FADE ACADEMY',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Master the craft from the world\'s best.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                // Academy Sections
                coursesAsync.when(
                  data: (courses) => SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSection(context, 'Trending Courses', courses),
                      _buildSection(context, 'Fading Masterclass', courses.where((c) => c.title.contains('Fade')).toList()),
                      _buildSection(context, 'Business of Barbering', []),
                    ]),
                  ),
                  loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          
          // Floating Bottom Navigation
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _buildFloatingBottomNav(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(icon: Icons.home_rounded, isSelected: location == Routes.clientHome, onTap: () => context.go(Routes.clientHome)),
              _NavItem(icon: Icons.search_rounded, isSelected: location == Routes.search, onTap: () => context.go(Routes.search)),
              _NavItem(icon: Icons.play_circle_outline_rounded, isSelected: location == Routes.feed, onTap: () => context.go(Routes.feed)),
              _NavItem(icon: Icons.school_outlined, isSelected: location == Routes.academy, onTap: () {}),
              _NavItem(icon: Icons.person_rounded, isSelected: location == Routes.clientProfile, onTap: () => context.go(Routes.clientProfile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Course> courses) {
    if (courses.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: courses.length,
            itemBuilder: (context, index) => _CourseCard(course: courses[index]),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${Routes.courseDetail}/${course.id}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                                  children: [
                                    Hero(
                                      tag: 'course_thumb_${course.id}',
                                      child: Image.network(
                                        course.thumbnailUrl ?? 'https://via.placeholder.com/400',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const Center(
                  
                      child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
                    ),
                    if (course.isPremium)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Leo The Blade', style: Theme.of(context).textTheme.bodySmall), // Mock Barber Name
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${course.lessonCount} Lessons', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                          Text('${course.durationMinutes} mins', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? AppColors.textOnAccent : AppColors.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}
