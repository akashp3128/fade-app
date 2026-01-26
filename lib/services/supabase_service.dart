import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/barber.dart';
import '../models/appointment.dart';
import '../models/review.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ============ USER OPERATIONS ============

  Future<AppUser?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return AppUser.fromJson(response);
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('profiles').update(data).eq('id', userId);
  }

  // ============ BARBER OPERATIONS ============

  Future<List<BarberProfile>> getBarbers({
    double? latitude,
    double? longitude,
    double radiusKm = 10,
    String? specialty,
    double? minRating,
    String? shopId,
    bool? isIndependent,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client.from('barber_profiles').select('''
      *,
      profiles!inner(*),
      services(*),
      shops(*)
    ''').eq('is_available', true);

    if (specialty != null) {
      query = query.contains('specialties', [specialty]);
    }

    if (minRating != null) {
      query = query.gte('rating', minRating);
    }

    if (shopId != null) {
      query = query.eq('shop_id', shopId);
    }

    if (isIndependent != null) {
      query = query.eq('is_independent', isIndependent);
    }

    final response = await query
        .order('rating', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => BarberProfile.fromJson(json))
        .toList();
  }

  Future<List<Shop>> getShops({
    double? latitude,
    double? longitude,
    double radiusKm = 10,
    int limit = 20,
  }) async {
    final response = await _client
        .from('shops')
        .select()
        .limit(limit);

    return (response as List).map((json) => Shop.fromJson(json)).toList();
  }

  Future<List<BarberProfile>> getBarbersByShop(String shopId) async {
    return getBarbers(shopId: shopId);
  }

  Future<BarberProfile?> getBarberById(String barberId) async {
    final response = await _client.from('barber_profiles').select('''
      *,
      profiles!inner(*),
      services(*),
      portfolio_images(*)
    ''').eq('id', barberId).maybeSingle();

    if (response == null) return null;
    return BarberProfile.fromJson(response);
  }

  Future<BarberProfile?> getBarberByUserId(String userId) async {
    final response = await _client.from('barber_profiles').select('''
      *,
      profiles!inner(*),
      services(*)
    ''').eq('user_id', userId).maybeSingle();

    if (response == null) return null;
    return BarberProfile.fromJson(response);
  }

  Future<void> updateBarberProfile(String barberId, Map<String, dynamic> data) async {
    await _client.from('barber_profiles').update(data).eq('id', barberId);
  }

  // ============ SERVICE OPERATIONS ============

  Future<List<Service>> getBarberServices(String barberId) async {
    final response = await _client
        .from('services')
        .select()
        .eq('barber_id', barberId)
        .eq('is_active', true)
        .order('price');

    return (response as List).map((json) => Service.fromJson(json)).toList();
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await _client.from('services').insert(data);
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _client.from('services').update(data).eq('id', serviceId);
  }

  Future<void> deleteService(String serviceId) async {
    await _client.from('services').update({'is_active': false}).eq('id', serviceId);
  }

  // ============ APPOINTMENT OPERATIONS ============

  Future<List<Appointment>> getClientAppointments(String clientId) async {
    final response = await _client.from('appointments').select('''
      *,
      barber_profiles!inner(*, profiles!inner(*)),
      services(*)
    ''').eq('client_id', clientId).order('scheduled_at', ascending: false);

    return (response as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<List<Appointment>> getBarberAppointments(String barberId) async {
    final response = await _client.from('appointments').select('''
      *,
      profiles!inner(*),
      services(*)
    ''').eq('barber_id', barberId).order('scheduled_at');

    return (response as List)
        .map((json) => Appointment.fromJson(json))
        .toList();
  }

  Future<Appointment> createAppointment(Map<String, dynamic> data) async {
    final response =
        await _client.from('appointments').insert(data).select().single();
    return Appointment.fromJson(response);
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _client
        .from('appointments')
        .update({'status': status})
        .eq('id', appointmentId);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, 'cancelled');
  }

  // ============ REVIEW OPERATIONS ============

  Future<List<Review>> getBarberReviews(String barberId, {int limit = 20}) async {
    final response = await _client.from('reviews').select('''
      *,
      profiles!inner(*)
    ''').eq('barber_id', barberId).order('created_at', ascending: false).limit(limit);

    return (response as List).map((json) => Review.fromJson(json)).toList();
  }

  Future<void> createReview(Map<String, dynamic> data) async {
    await _client.from('reviews').insert(data);

    // Update barber rating (this should ideally be a database trigger)
    final barberId = data['barber_id'];
    final reviews = await _client
        .from('reviews')
        .select('rating')
        .eq('barber_id', barberId);

    if (reviews.isNotEmpty) {
      final totalRating =
          reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
      final avgRating = totalRating / reviews.length;

      await _client.from('barber_profiles').update({
        'rating': avgRating,
        'review_count': reviews.length,
      }).eq('id', barberId);
    }
  }

  // ============ AVAILABILITY OPERATIONS ============

  Future<List<Map<String, dynamic>>> getBarberAvailability(String barberId) async {
    final response = await _client
        .from('availability')
        .select()
        .eq('barber_id', barberId)
        .eq('is_available', true)
        .order('day_of_week');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<DateTime>> getAvailableSlots(
    String barberId,
    DateTime date,
    int durationMinutes,
  ) async {
    // Get barber's availability for the day of week
    final dayOfWeek = date.weekday % 7; // 0 = Sunday, 6 = Saturday
    final availability = await _client
        .from('availability')
        .select()
        .eq('barber_id', barberId)
        .eq('day_of_week', dayOfWeek)
        .eq('is_available', true)
        .maybeSingle();

    if (availability == null) return [];

    // Get existing appointments for that day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existingAppointments = await _client
        .from('appointments')
        .select('scheduled_at, duration_minutes')
        .eq('barber_id', barberId)
        .gte('scheduled_at', startOfDay.toIso8601String())
        .lt('scheduled_at', endOfDay.toIso8601String())
        .inFilter('status', ['pending', 'confirmed']);

    // Calculate available slots
    final slots = <DateTime>[];
    final startTime = _parseTime(availability['start_time'] as String);
    final endTime = _parseTime(availability['end_time'] as String);

    var currentSlot = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endSlot = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentSlot.add(Duration(minutes: durationMinutes)).isBefore(endSlot) ||
        currentSlot.add(Duration(minutes: durationMinutes)).isAtSameMomentAs(endSlot)) {
      // Check if slot conflicts with existing appointments
      final hasConflict = existingAppointments.any((apt) {
        final aptStart = DateTime.parse(apt['scheduled_at'] as String);
        final aptEnd = aptStart.add(Duration(minutes: apt['duration_minutes'] as int));
        final slotEnd = currentSlot.add(Duration(minutes: durationMinutes));

        return (currentSlot.isBefore(aptEnd) && slotEnd.isAfter(aptStart));
      });

      if (!hasConflict && currentSlot.isAfter(DateTime.now())) {
        slots.add(currentSlot);
      }

      currentSlot = currentSlot.add(const Duration(minutes: 30)); // 30-min intervals
    }

    return slots;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  // ============ FAVORITES OPERATIONS ============

  Future<List<BarberProfile>> getFavorites(String clientId) async {
    final response = await _client.from('favorites').select('''
      barber_profiles!inner(*, profiles!inner(*))
    ''').eq('client_id', clientId);

    return (response as List)
        .map((json) => BarberProfile.fromJson(json['barber_profiles']))
        .toList();
  }

  Future<void> addFavorite(String clientId, String barberId) async {
    await _client.from('favorites').insert({
      'client_id': clientId,
      'barber_id': barberId,
    });
  }

  Future<void> removeFavorite(String clientId, String barberId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('client_id', clientId)
        .eq('barber_id', barberId);
  }

  Future<bool> isFavorite(String clientId, String barberId) async {
    final response = await _client
        .from('favorites')
        .select('id')
        .eq('client_id', clientId)
        .eq('barber_id', barberId)
        .maybeSingle();

    return response != null;
  }

  // ============ STORAGE OPERATIONS ============

  Future<String> uploadAvatar(String userId, List<int> bytes, String filename) async {
    final path = 'avatars/$userId/$filename';
    await _client.storage.from('avatars').uploadBinary(path, bytes as dynamic);
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<String> uploadPortfolioImage(
    String barberId,
    List<int> bytes,
    String filename,
  ) async {
    final path = 'portfolio/$barberId/$filename';
    await _client.storage.from('portfolio').uploadBinary(path, bytes as dynamic);
    return _client.storage.from('portfolio').getPublicUrl(path);
  }
}
