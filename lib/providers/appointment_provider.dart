import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import 'barber_provider.dart';

// Local provider to store session appointments (Mock Database)
class LocalAppointmentsNotifier extends StateNotifier<List<Appointment>> {
  LocalAppointmentsNotifier() : super([]);

  void addAppointment(Appointment appointment) {
    state = [...state, appointment];
  }

  void cancelAppointment(String id) {
    state = state.map((apt) {
      if (apt.id == id) {
        return apt.copyWith(status: AppointmentStatus.cancelled);
      }
      return apt;
    }).toList();
  }
}

final localAppointmentsProvider = 
    StateNotifierProvider<LocalAppointmentsNotifier, List<Appointment>>((ref) {
  return LocalAppointmentsNotifier();
});

// Providers consumed by UI
final upcomingAppointmentsProvider = Provider<AsyncValue<List<Appointment>>>((ref) {
  final appointments = ref.watch(localAppointmentsProvider);
  final upcoming = appointments
      .where((apt) => apt.isUpcoming && !apt.isCancelled)
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  
  return AsyncValue.data(upcoming);
});

final pastAppointmentsProvider = Provider<AsyncValue<List<Appointment>>>((ref) {
  final appointments = ref.watch(localAppointmentsProvider);
  final past = appointments
      .where((apt) => apt.isPast || apt.isCompleted || apt.isCancelled)
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt)); // Newest first
  
  return AsyncValue.data(past);
});

// Dummy provider to satisfy existing references in appointments_screen.dart
final clientAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  return ref.watch(localAppointmentsProvider);
});

// Action provider
final appointmentActionsProvider = StateNotifierProvider<AppointmentActionsNotifier, void>((ref) {
  return AppointmentActionsNotifier(ref);
});

class AppointmentActionsNotifier extends StateNotifier<void> {
  final Ref _ref;

  AppointmentActionsNotifier(this._ref) : super(null);

  Future<bool> cancelAppointment(String appointmentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    _ref.read(localAppointmentsProvider.notifier).cancelAppointment(appointmentId);
    return true;
  }
  
  Future<bool> createAppointment({
    required BarberProfile barber,
    required Service service, // We need to create a Service model instance from string if needed
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Parse time string "9:00 AM"
    final timeParts = time.split(' '); // ["9:00", "AM"]
    final hourMin = timeParts[0].split(':');
    int hour = int.parse(hourMin[0]);
    final minute = int.parse(hourMin[1]);
    if (timeParts[1] == 'PM' && hour != 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;
    
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // --- CONCURRENCY CHECK (Simulating Backend RPC) ---
    final existingAppointments = _ref.read(localAppointmentsProvider);
    final isSlotTaken = existingAppointments.any((apt) {
      if (apt.barberId != barber.id) return false;
      if (apt.isCancelled) return false;
      
      // Calculate end times
      final aptEnd = apt.scheduledAt.add(Duration(minutes: apt.durationMinutes));
      final newEnd = scheduledAt.add(Duration(minutes: service.durationMinutes));

      // Check overlap: StartA < EndB AND EndA > StartB
      return apt.scheduledAt.isBefore(newEnd) && aptEnd.isAfter(scheduledAt);
    });

    if (isSlotTaken) {
      return false; // Fail silently (UI handles boolean)
    }
    // --------------------------------------------------

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: 'current_user',
      barberId: barber.id,
      serviceId: service.id,
      scheduledAt: scheduledAt,
      durationMinutes: service.durationMinutes,
      totalPrice: service.price,
      notes: notes,
      createdAt: DateTime.now(),
      status: AppointmentStatus.confirmed,
      barber: barber,
      service: service,
    );

    _ref.read(localAppointmentsProvider.notifier).addAppointment(newAppointment);
    return true;
  }
}

// Review Notifier (Mock)
final reviewNotifierProvider = StateNotifierProvider<ReviewNotifier, void>((ref) {
  return ReviewNotifier();
});

class ReviewNotifier extends StateNotifier<void> {
  ReviewNotifier() : super(null);

  Future<bool> submitReview({
    required String barberId,
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true; 
  }
}