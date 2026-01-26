import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';

class BarberProfileEditScreen extends ConsumerStatefulWidget {
  const BarberProfileEditScreen({super.key});

  @override
  ConsumerState<BarberProfileEditScreen> createState() =>
      _BarberProfileEditScreenState();
}

class _BarberProfileEditScreenState
    extends ConsumerState<BarberProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isAvailable = true;
  List<String> _selectedSpecialties = ['Haircut', 'Fade'];

  final List<String> _allSpecialties = [
    'Haircut',
    'Fade',
    'Beard',
    'Color',
    'Kids',
    'Hot Towel Shave',
    'Hair Design',
    'Braids',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with mock data
    _nameController.text = 'John\'s Barbershop';
    _bioController.text =
        'Professional barber with 5+ years of experience. Specializing in modern cuts, fades, and beard grooming.';
    _addressController.text = '123 Main St, Downtown';
    _phoneController.text = '(555) 123-4567';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.barberDashboard),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile photo
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.border,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Change photo
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Business name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  hintText: 'Enter your business name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'About You',
                  hintText: 'Tell clients about yourself...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your business address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Availability toggle
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available for Bookings',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          _isAvailable
                              ? 'Clients can book appointments'
                              : 'Bookings are paused',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() => _isAvailable = value);
                      },
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Specialties
              Text(
                'Specialties',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _allSpecialties.map((specialty) {
                  final isSelected = _selectedSpecialties.contains(specialty);
                  return FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecialties.add(specialty);
                        } else {
                          _selectedSpecialties.remove(specialty);
                        }
                      });
                    },
                    selectedColor: AppColors.accent.withOpacity(0.2),
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Services section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: _showAddServiceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _ServiceEditTile(
                name: 'Classic Haircut',
                price: '\$25',
                duration: '30 min',
                onEdit: () => _showEditServiceDialog('Classic Haircut'),
                onDelete: () {},
              ),
              _ServiceEditTile(
                name: 'Haircut + Beard',
                price: '\$35',
                duration: '45 min',
                onEdit: () => _showEditServiceDialog('Haircut + Beard'),
                onDelete: () {},
              ),
              _ServiceEditTile(
                name: 'Premium Fade',
                price: '\$40',
                duration: '45 min',
                onEdit: () => _showEditServiceDialog('Premium Fade'),
                onDelete: () {},
              ),

              const SizedBox(height: AppSpacing.xl),

              // Working hours section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Working Hours',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Edit working hours
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _WorkingHoursTile(day: 'Monday', hours: '9:00 AM - 6:00 PM'),
              _WorkingHoursTile(day: 'Tuesday', hours: '9:00 AM - 6:00 PM'),
              _WorkingHoursTile(day: 'Wednesday', hours: '9:00 AM - 6:00 PM'),
              _WorkingHoursTile(day: 'Thursday', hours: '9:00 AM - 6:00 PM'),
              _WorkingHoursTile(day: 'Friday', hours: '9:00 AM - 6:00 PM'),
              _WorkingHoursTile(day: 'Saturday', hours: '10:00 AM - 4:00 PM'),
              _WorkingHoursTile(day: 'Sunday', hours: 'Closed', isClosed: true),

              const SizedBox(height: AppSpacing.xxl),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                    ref.invalidate(localAppointmentsProvider); // Clear session data
                    if (context.mounted) {
                      context.go(Routes.login);
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save profile to Supabase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  void _showAddServiceDialog() {
    _showServiceDialog(isEdit: false);
  }

  void _showEditServiceDialog(String serviceName) {
    _showServiceDialog(isEdit: true, serviceName: serviceName);
  }

  void _showServiceDialog({required bool isEdit, String? serviceName}) {
    final nameController = TextEditingController(text: isEdit ? serviceName : '');
    final priceController = TextEditingController(text: isEdit ? '25' : '');
    final durationController = TextEditingController(text: isEdit ? '30' : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Service' : 'Add Service',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                hintText: 'e.g., Classic Haircut',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      hintText: '25',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      hintText: '30',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isEdit ? 'Save Changes' : 'Add Service'),
              ),
            ),
            if (isEdit) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: const Text('Delete Service'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _ServiceEditTile extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceEditTile({
    required this.name,
    required this.price,
    required this.duration,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '$price • $duration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class _WorkingHoursTile extends StatelessWidget {
  final String day;
  final String hours;
  final bool isClosed;

  const _WorkingHoursTile({
    required this.day,
    required this.hours,
    this.isClosed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            hours,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isClosed ? AppColors.error : AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
