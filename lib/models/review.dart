import 'package:flutter/foundation.dart';
import 'user.dart';
import 'barber.dart';

@immutable
class Review {
  final String id;
  final String? appointmentId;
  final String clientId;
  final String barberId;
  final int rating;
  final String? comment;
  final List<String> photos;
  final DateTime createdAt;

  // Joined data
  final AppUser? client;
  final BarberProfile? barber;

  const Review({
    required this.id,
    this.appointmentId,
    required this.clientId,
    required this.barberId,
    required this.rating,
    this.comment,
    this.photos = const [],
    required this.createdAt,
    this.client,
    this.barber,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String?,
      clientId: json['client_id'] as String,
      barberId: json['barber_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      client: json['profiles'] != null
          ? AppUser.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      barber: json['barber_profiles'] != null
          ? BarberProfile.fromJson(json['barber_profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'client_id': clientId,
      'barber_id': barberId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get clientName => client?.fullName ?? 'Anonymous';
  String? get clientAvatar => client?.avatarUrl;

  Review copyWith({
    String? id,
    String? appointmentId,
    String? clientId,
    String? barberId,
    int? rating,
    String? comment,
    List<String>? photos,
    DateTime? createdAt,
    AppUser? client,
    BarberProfile? barber,
  }) {
    return Review(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      clientId: clientId ?? this.clientId,
      barberId: barberId ?? this.barberId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      client: client ?? this.client,
      barber: barber ?? this.barber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
