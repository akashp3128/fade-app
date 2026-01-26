import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/appointment_provider.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final appRole = ref.watch(appRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Premium Header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryLight, AppColors.background],
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.accent, width: 2),
                                      boxShadow: AppColors.glowShadow,
                                    ),
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundColor: AppColors.surface,
                                      child: currentUser.when(
                                        data: (user) => user?.avatarUrl != null
                                            ? ClipOval(child: Image.network(user!.avatarUrl!, fit: BoxFit.cover, width: 90, height: 90))
                                            : const Icon(Icons.person, size: 45, color: AppColors.textLight),
                                        loading: () => const CircularProgressIndicator(),
                                        error: (_, __) => const Icon(Icons.person, size: 45),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                      child: const Icon(Icons.edit, size: 14, color: AppColors.textOnAccent),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              currentUser.when(
                                data: (user) => Text(
                                  user?.fullName ?? 'Guest',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                loading: () => const Text('...'),
                                error: (_, __) => const Text('Error'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fade Pro Member',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ref.read(appRoleProvider.notifier).switchToBarber();
                                      context.go(Routes.barberDashboard);
                                    },
                                    icon: const Icon(Icons.swap_horiz, size: 18),
                                    label: const Text('BARBER MODE'),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final authService = ref.read(authServiceProvider);
                                      await authService.signOut();
                                      ref.invalidate(localAppointmentsProvider);
                                      if (context.mounted) context.go(Routes.login);
                                    },
                                    icon: const Icon(Icons.logout, size: 18),
                                    label: const Text('LOGOUT'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
                ],
              ),

              // My Mirror (Style Vault) Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('My Mirror', style: Theme.of(context).textTheme.titleLarge),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                            label: const Text('Add Cut'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your private history of haircuts. Only you and your barber can see this.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Mock Grid of past cuts
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.divider),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=200'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: index == 0 ? const Center(child: Icon(Icons.lock, color: Colors.white54, size: 16)) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Items
              SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileMenuItem(icon: Icons.favorite_outline, title: 'Favorite Barbers', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
                  
                  // Debug: Simulate Notification
                  _ProfileMenuItem(
                    icon: Icons.bug_report, 
                    title: 'Simulate Booking Request', 
                    onTap: () {
                      ref.read(notificationProvider.notifier).simulateIncomingRequest();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification Triggered!')),
                      );
                    }
                  ),

                  const SizedBox(height: 120),
                ]),
              ),
            ],
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
              _NavItem(icon: Icons.school_outlined, isSelected: location == Routes.academy, onTap: () => context.go(Routes.academy)),
              _NavItem(icon: Icons.person_rounded, isSelected: location == Routes.clientProfile, onTap: () {}),
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

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: AppColors.accent),
      ),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}