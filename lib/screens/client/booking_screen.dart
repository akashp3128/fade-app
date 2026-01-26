import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/barber_provider.dart';
import '../../models/barber.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String barberId;
  final String? initialServiceId;

  const BookingScreen({
    super.key,
    required this.barberId,
    this.initialServiceId,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _currentStep = 0;
  String? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final _notesController = TextEditingController();
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceId == 'premium_fade') {
      _selectedService = 'Premium Fade - \$40';
    } else if (widget.initialServiceId != null) {
      // In real app, look up service by ID
      _selectedService = 'Classic Haircut - \$25';
    }
  }

  final List<String> _services = [
    'Classic Haircut - \$25',
    'Haircut + Beard - \$35',
    'Premium Fade - \$40',
    'Kids Haircut - \$18',
  ];
  
  // Helper to get service object from string
  Service _getServiceFromString(String serviceStr, String barberId) {
    // This is a mock helper since UI uses strings currently
    final parts = serviceStr.split(' - \$');
    final name = parts[0];
    final price = double.parse(parts[1]);
    
    return Service(
      id: 'mock_svc_${DateTime.now().millisecondsSinceEpoch}',
      barberId: barberId,
      name: name,
      durationMinutes: 45, // Default
      price: price,
    );
  }

  final List<String> _availableTimes = [
// ... existing times ...
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch barber data to display name
    final barberAsync = ref.watch(barberByIdProvider(widget.barberId));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: barberAsync.when(
        data: (barber) {
          if (barber == null) return const Center(child: Text('Barber not found'));
          return Column(
            children: [
              // Stepper indicator (keep existing)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _StepIndicator(
                      step: 1,
                      label: 'Service',
                      isActive: _currentStep >= 0,
                      isCompleted: _currentStep > 0,
                    ),
                    Expanded(child: _StepLine(isActive: _currentStep > 0)),
                    _StepIndicator(
                      step: 2,
                      label: 'Date & Time',
                      isActive: _currentStep >= 1,
                      isCompleted: _currentStep > 1,
                    ),
                    Expanded(child: _StepLine(isActive: _currentStep > 1)),
                    _StepIndicator(
                      step: 3,
                      label: 'Confirm',
                      isActive: _currentStep >= 2,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _buildStepContent(barber),
                ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isBooking ? null : () {
                              setState(() => _currentStep--);
                            },
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _canProceed() && !_isBooking 
                              ? () => _nextStep(barber) 
                              : null,
                          child: _isBooking 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black))
                              : Text(_currentStep == 2 ? 'Confirm Booking' : 'Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _selectedTime != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextStep(BarberProfile barber) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _confirmBooking(barber);
    }
  }

  Future<void> _confirmBooking(BarberProfile barber) async {
    setState(() => _isBooking = true);

    try {
      // Create actual appointment
      final service = _getServiceFromString(_selectedService!, barber.id);
      
      final success = await ref.read(appointmentActionsProvider.notifier).createAppointment(
        barber: barber,
        service: service,
        date: _selectedDate,
        time: _selectedTime!,
        notes: _notesController.text,
      );

      if (mounted) {
        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 40,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Booking Confirmed!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your appointment has been scheduled. You\'ll receive a confirmation shortly.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      context.go(Routes.clientAppointments); // Go to appointments tab
                    },
                    child: const Text('View Appointments'),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show Error Dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Slot Unavailable'),
              content: const Text(
                'Oh no! This time slot was just booked by someone else. Please select a different time.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Widget _buildStepContent(BarberProfile barber) {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep();
      case 1:
        return _buildDateTimeStep();
      case 2:
        return _buildConfirmStep(barber);
      default:
        return const SizedBox();
    }
  }

  // ... _buildServiceStep and _buildDateTimeStep (unchanged) ...
  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Service',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(
          _services.length,
          (index) => _ServiceOption(
            title: _services[index],
            isSelected: _selectedService == _services[index],
            onTap: () {
              setState(() => _selectedService = _services[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _selectedDate.day == date.day &&
                  _selectedDate.month == date.month;
              return _DateCard(
                date: date,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedDate = date);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Select Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _availableTimes.map((time) {
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(BarberProfile barber) {
    final servicePrice = _selectedService != null 
        ? _selectedService!.split(' - \$')[1] 
        : '0.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Summary',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Barber', value: barber.displayName),
              const Divider(height: AppSpacing.lg),
              _SummaryRow(label: 'Service', value: _selectedService?.split(' - ')[0] ?? ''),
              const Divider(height: AppSpacing.lg),
              _SummaryRow(
                label: 'Date',
                value:
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              const Divider(height: AppSpacing.lg),
              _SummaryRow(label: 'Time', value: _selectedTime ?? ''),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Add Notes (Optional)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Any special requests or preferences...',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '\$$servicePrice',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;

  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: isActive ? AppColors.accent : AppColors.border,
    );
  }
}

class _ServiceOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateCard({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNames[date.weekday - 1],
              style: TextStyle(
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
