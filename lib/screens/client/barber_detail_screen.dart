import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/barber_provider.dart';

class BarberDetailScreen extends ConsumerWidget {
  final String barberId;

  const BarberDetailScreen({
    super.key,
    required this.barberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barberAsync = ref.watch(barberByIdProvider(barberId));

    return barberAsync.when(
      data: (barber) {
        if (barber == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Barber not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Header with immersive image
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: AppColors.accent),
                          onPressed: () {
                            // TODO: Toggle favorite
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            // TODO: Share profile
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (barber.avatarUrl != null)
                      Hero(
                        tag: 'barber_avatar_${barber.id}',
                        child: Image.network(
                          barber.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(color: AppColors.surface),
                    
                    // Gradient Overlay

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.transparent,
                                  AppColors.background.withOpacity(0.8),
                                  AppColors.background,
                                ],
                                stops: const [0.0, 0.5, 0.8, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: AppSpacing.lg,
                            right: AppSpacing.lg,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        barber.displayName,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: AppColors.accent),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              barber.shop?.name ?? (barber.isIndependent ? 'Independent Barber' : 'Barbershop'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(color: Colors.white70),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                    ],
                                  ),
                                ),
                                if (barber.instagramHandle != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                                      onPressed: () {
                                        // TODO: Launch Instagram with barber.instagramHandle
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Row
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  value: barber.rating.toStringAsFixed(1),
                                  label: 'Rating',
                                  icon: Icons.star,
                                ),
                                _StatDivider(),
                                _StatItem(
                                  value: '${barber.yearsExperience ?? 0}+',
                                  label: 'Years',
                                  icon: Icons.history,
                                ),
                                _StatDivider(),
                                _StatItem(
                                  value: '${barber.reviewCount}',
                                  label: 'Reviews',
                                  icon: Icons.chat_bubble_outline,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // About
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            barber.bio ?? 'No bio available.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Services
                          if (barber.services != null && barber.services!.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Services',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ...barber.services!.map((service) => _ServiceTile(
                                  name: service.name,
                                  duration: service.formattedDuration,
                                  price: service.formattedPrice,
                                  onTap: () => context.go('${Routes.booking}/$barberId'),
                                )),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // Portfolio
                          if (barber.portfolio != null && barber.portfolio!.isNotEmpty) ...[
                            Text(
                              'Portfolio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: barber.portfolio!.length,
                                itemBuilder: (context, index) {
                                  final image = barber.portfolio![index];
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(color: AppColors.divider),
                                      image: DecorationImage(
                                        image: NetworkImage(image.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // Reviews
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reviews',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('See All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _ReviewCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Booking Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.8),
                        border: const Border(top: BorderSide(color: AppColors.divider)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: ElevatedButton(
                          onPressed: () => context.push('${Routes.booking}/$barberId'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textOnAccent,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            elevation: 10,
                            shadowColor: AppColors.accent.withOpacity(0.4),
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.divider,
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String name;
  final String duration;
  final String price;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.name,
    required this.duration,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.cut, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mike Johnson',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '2 days ago',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Great haircut! John really knows what he\'s doing. Will definitely come back.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
