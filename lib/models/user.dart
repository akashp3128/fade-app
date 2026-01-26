import 'package:flutter/foundation.dart';

enum UserType { client, barber }

@immutable
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final UserType userType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? stripeAccountId; // New field for Stripe Connect

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    this.stripeAccountId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      userType: json['user_type'] == 'barber' ? UserType.barber : UserType.client,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stripeAccountId: json['stripe_account_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'user_type': userType == UserType.barber ? 'barber' : 'client',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'stripe_account_id': stripeAccountId,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? stripeAccountId,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
    );
  }

  bool get isBarber => userType == UserType.barber;
  bool get isClient => userType == UserType.client;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}