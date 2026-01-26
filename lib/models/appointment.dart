import 'package:flutter/foundation.dart';
import 'user.dart';
import 'barber.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

@immutable
class Appointment {
  final String id;
  final String clientId;
  final String barberId;
  final String serviceId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final AppointmentStatus status;
  final double totalPrice;
  final String? notes;
  final String? stripePaymentIntentId;
  final DateTime createdAt;

  // Joined data
  final AppUser? client;
  final BarberProfile? barber;
  final Service? service;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.barberId,
    required this.serviceId,
    required this.scheduledAt,
    required this.durationMinutes,
    this.status = AppointmentStatus.pending,
    required this.totalPrice,
    this.notes,
    this.stripePaymentIntentId,
    required this.createdAt,
    this.client,
    this.barber,
    this.service,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      barberId: json['barber_id'] as String,
      serviceId: json['service_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      status: _parseStatus(json['status'] as String?),
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      client: json['profiles'] != null
          ? AppUser.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      barber: json['barber_profiles'] != null
          ? BarberProfile.fromJson(json['barber_profiles'] as Map<String, dynamic>)
          : null,
      service: json['services'] != null
          ? Service.fromJson(json['services'] as Map<String, dynamic>)
          : null,
    );
  }

  static AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'barber_id': barberId,
      'service_id': serviceId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': statusString,
      'total_price': totalPrice,
      'notes': notes,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get isUpcoming =>
      (isPending || isConfirmed) && scheduledAt.isAfter(DateTime.now());
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  String get formattedPrice => '\$${totalPrice.toStringAsFixed(2)}';

  Appointment copyWith({
    String? id,
    String? clientId,
    String? barberId,
    String? serviceId,
    DateTime? scheduledAt,
    int? durationMinutes,
    AppointmentStatus? status,
    double? totalPrice,
    String? notes,
    String? stripePaymentIntentId,
    DateTime? createdAt,
    AppUser? client,
    BarberProfile? barber,
    Service? service,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      barberId: barberId ?? this.barberId,
      serviceId: serviceId ?? this.serviceId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      createdAt: createdAt ?? this.createdAt,
      client: client ?? this.client,
      barber: barber ?? this.barber,
      service: service ?? this.service,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
