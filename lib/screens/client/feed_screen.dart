import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/barber.dart';
import '../../providers/barber_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final barbersAsync = ref.watch(featuredBarbersProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: barbersAsync.when(
        data: (barbers) {
          if (barbers.isEmpty) {
            return const Center(child: Text('No videos yet.'));
          }
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: barbers.length,
            itemBuilder: (context, index) {
              return _TikTokVideoItem(barber: barbers[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _TikTokVideoItem extends StatefulWidget {
  final BarberProfile barber;
  const _TikTokVideoItem({required this.barber});

  @override
  State<_TikTokVideoItem> createState() => _TikTokVideoItemState();
}

class _TikTokVideoItemState extends State<_TikTokVideoItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  final List<String> _mockVideos = [
    'https://assets.mixkit.co/videos/preview/mixkit-barber-cutting-hair-with-scissors-and-comb-12624-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-barber-shaving-a-client-with-a-razor-12625-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-hands-of-a-barber-cutting-hair-4651-large.mp4',
  ];

  @override
  void initState() {
    super.initState();
    // In a real app, use widget.barber.tiktokUrl or similar
    final videoUrl = _mockVideos[widget.barber.id.hashCode % _mockVideos.length];
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_initialized)
          GestureDetector(
            onTap: () {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            },
            child: VideoPlayer(_controller),
          )
        else
          const Center(child: CircularProgressIndicator(color: AppColors.accent)),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Post Info (Bottom)
        Positioned(
          bottom: 100,
          left: AppSpacing.lg,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('${Routes.barberDetail}/${widget.barber.id}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.barber.avatarUrl != null ? NetworkImage(widget.barber.avatarUrl!) : null,
                      backgroundColor: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      widget.barber.displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Classic razor fade for the weekend. Sharp lines and clean skin. #fade #barber',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Action Buttons (Right Side)
        Positioned(
          right: AppSpacing.md,
          bottom: 120,
          child: Column(
            children: [
              _ActionButton(icon: Icons.favorite, label: '1.2k'),
              const SizedBox(height: 20),
              _ActionButton(icon: Icons.chat_bubble, label: '84'),
              const SizedBox(height: 20),
              _ActionButton(icon: Icons.share, label: 'Share'),
            ],
          ),
        ),

        // BOOK THIS LOOK button
        Positioned(
          bottom: 100, // Moved up to make room for nav
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: ElevatedButton(
            onPressed: () => context.push('${Routes.booking}/${widget.barber.id}?serviceId=premium_fade'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('BOOK THIS LOOK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
              _NavItem(icon: Icons.play_circle_outline_rounded, isSelected: location == Routes.feed, onTap: () {}),
              _NavItem(icon: Icons.school_outlined, isSelected: location == Routes.academy, onTap: () => context.go(Routes.academy)),
              _NavItem(icon: Icons.person_rounded, isSelected: location == Routes.clientProfile, onTap: () => context.go(Routes.clientProfile)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
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
