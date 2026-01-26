import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

import '../../providers/barber_provider.dart';

class BarberDashboardScreen extends ConsumerStatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  ConsumerState<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends ConsumerState<BarberDashboardScreen> {
  bool isOnline = false;

    void _toggleAvailability(bool value) {
    if (value) {
      // Gating Logic
      final userAsync = ref.read(currentUserProvider);
      final hasStripe = userAsync.value?.stripeAccountId != null;
      
      if (!hasStripe) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Connect Stripe'),
            content: const Text(
              'To go online and accept bookings, you must connect your bank account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(Routes.barberStripeSetup);
                },
                child: const Text('Setup Payments'),
              ),
            ],
          ),
        );
        return;
      }
    }
    setState(() => isOnline = value);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final appRole = ref.watch(appRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                            boxShadow: AppColors.glowShadow,
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.surface,
                            child: currentUser.when(
                              data: (user) => user?.avatarUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        user!.avatarUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person, color: AppColors.textLight),
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              currentUser.when(
                                data: (user) => Text(
                                  user?.fullName.split(' ').first ?? 'Barber',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                loading: () => const Text('...'),
                                error: (_, __) => const Text('Barber'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Switch(
                            value: isOnline, // This needs to be stateful or watched from provider
                            onChanged: _toggleAvailability,
                            activeColor: AppColors.success,
                            inactiveTrackColor: AppColors.surface,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            color: AppColors.accent,
                            onPressed: () {
                              ref.read(appRoleProvider.notifier).switchToClient();
                              context.go(Routes.clientHome);
                            },
                            tooltip: 'Switch to Client Mode',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Stats Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Today\'s Earnings',
                            value: '\$125',
                            icon: Icons.attach_money,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            title: 'Appointments',
                            value: '5',
                            icon: Icons.calendar_today,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Rating',
                            value: '4.8',
                            icon: Icons.star,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            title: 'This Week',
                            value: '\$850',
                            icon: Icons.trending_up,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // Today's Schedule
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Schedule',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () => context.go(Routes.barberCalendar),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Appointments List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _AppointmentTile(
                        clientName: 'Mike Johnson',
                        service: 'Classic Haircut',
                        time: '9:00 AM',
                        status: 'completed',
                      ),
                      _AppointmentTile(
                        clientName: 'David Smith',
                        service: 'Haircut + Beard',
                        time: '10:00 AM',
                        status: 'in_progress',
                      ),
                      _AppointmentTile(
                        clientName: 'James Brown',
                        service: 'Premium Fade',
                        time: '11:30 AM',
                        status: 'upcoming',
                      ),
                      _AppointmentTile(
                        clientName: 'Robert Wilson',
                        service: 'Classic Haircut',
                        time: '1:00 PM',
                        status: 'upcoming',
                      ),
                      _AppointmentTile(
                        clientName: 'Chris Davis',
                        service: 'Beard Trim',
                        time: '2:30 PM',
                        status: 'upcoming',
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Floating Navigation Bar
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _buildFloatingBottomNav(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.barberContentStudio),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                isSelected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.calendar_month_rounded,
                isSelected: false,
                onTap: () => context.go(Routes.barberCalendar),
              ),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(
                icon: Icons.account_balance_wallet_rounded,
                isSelected: false,
                onTap: () => context.go(Routes.barberEarnings),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                isSelected: false,
                onTap: () => context.go(Routes.barberProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.more_horiz, color: AppColors.textLight, size: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final String clientName;
  final String service;
  final String time;
  final String status;

  const _AppointmentTile({
    required this.clientName,
    required this.service,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case 'in_progress':
        statusColor = AppColors.accent;
        statusText = 'In Chair';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Upcoming';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: status == 'in_progress' ? AppColors.accent : AppColors.divider,
          width: status == 'in_progress' ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              time,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
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
