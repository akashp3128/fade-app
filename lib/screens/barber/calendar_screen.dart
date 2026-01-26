import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';

class BarberCalendarScreen extends ConsumerStatefulWidget {
  const BarberCalendarScreen({super.key});

  @override
  ConsumerState<BarberCalendarScreen> createState() =>
      _BarberCalendarScreenState();
}

class _BarberCalendarScreenState extends ConsumerState<BarberCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.barberDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() => _selectedDate = DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    // Previous month
                  },
                ),
                Text(
                  _getMonthYear(_focusedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // Next month
                  },
                ),
              ],
            ),
          ),

          // Week days header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildCalendarGrid(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Selected date appointments
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatSelectedDate(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '5 appointments',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      children: const [
                        _CalendarAppointment(
                          time: '9:00 AM',
                          endTime: '9:30 AM',
                          clientName: 'Mike Johnson',
                          service: 'Classic Haircut',
                        ),
                        _CalendarAppointment(
                          time: '10:00 AM',
                          endTime: '10:45 AM',
                          clientName: 'David Smith',
                          service: 'Haircut + Beard',
                        ),
                        _CalendarAppointment(
                          time: '11:30 AM',
                          endTime: '12:15 PM',
                          clientName: 'James Brown',
                          service: 'Premium Fade',
                        ),
                        _CalendarAppointment(
                          time: '1:00 PM',
                          endTime: '1:30 PM',
                          clientName: 'Robert Wilson',
                          service: 'Classic Haircut',
                        ),
                        _CalendarAppointment(
                          time: '2:30 PM',
                          endTime: '2:45 PM',
                          clientName: 'Chris Davis',
                          service: 'Beard Trim',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Block time slot
          _showBlockTimeDialog();
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.block, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    // Empty cells for days before the first day
    for (var i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }

    // Days of the month
    for (var day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDate.day == day &&
          _selectedDate.month == _focusedMonth.month;
      final isToday = DateTime.now().day == day &&
          DateTime.now().month == _focusedMonth.month &&
          DateTime.now().year == _focusedMonth.year;
      final hasAppointments = day % 3 == 0; // Placeholder logic

      days.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent
                  : isToday
                      ? AppColors.accent.withOpacity(0.2)
                      : null,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.accent
                            : AppColors.textPrimary,
                    fontWeight:
                        isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasAppointments && !isSelected)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: (MediaQuery.of(context).size.width - 32 - 280) / 6,
      runSpacing: AppSpacing.sm,
      children: days,
    );
  }

  String _getMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatSelectedDate(DateTime date) {
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  void _showBlockTimeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Block Time Slot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Select a time range to block off your schedule.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      hintText: '9:00 AM',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      hintText: '12:00 PM',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g., Lunch break, Personal time',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Block Time'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _CalendarAppointment extends StatelessWidget {
  final String time;
  final String endTime;
  final String clientName;
  final String service;

  const _CalendarAppointment({
    required this.time,
    required this.endTime,
    required this.clientName,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  endTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.border,
                    child:
                        Icon(Icons.person, size: 20, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          service,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
