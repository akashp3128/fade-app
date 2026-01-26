import 'package:flutter/foundation.dart';
import 'user.dart';

@immutable
class Shop {
  final String id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? avatarUrl;
  final String? phone;
  final String? website;

  const Shop({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.avatarUrl,
    this.phone,
    this.website,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'avatar_url': avatarUrl,
      'phone': phone,
      'website': website,
    };
  }
}

@immutable
class BarberProfile {
  final String id;
  final String userId;
  final String? bio;
  final List<String> specialties;
  final int? yearsExperience;
  final double? hourlyRate;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? stripeAccountId;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final String? instagramHandle;
  final String? shopId;
  final bool isIndependent;
  final DateTime createdAt;

  final bool bookingRequiresConfirmation;
  final bool instantBookEnabled;
  final double subscriptionPrice;

  // Joined data
  final AppUser? user;
  final List<Service>? services;
  final List<PortfolioImage>? portfolio;
  final Shop? shop;

  const BarberProfile({
    required this.id,
    required this.userId,
    this.bio,
    this.specialties = const [],
    this.yearsExperience,
    this.hourlyRate,
    this.latitude,
    this.longitude,
    this.address,
    this.stripeAccountId,
    this.isAvailable = true,
    this.rating = 0,
    this.reviewCount = 0,
    this.instagramHandle,
    this.shopId,
    this.isIndependent = true,
    this.bookingRequiresConfirmation = true,
    this.instantBookEnabled = false,
    this.subscriptionPrice = 0.0,
    required this.createdAt,
    this.user,
    this.services,
    this.portfolio,
    this.shop,
  });

  factory BarberProfile.fromJson(Map<String, dynamic> json) {
    return BarberProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bio: json['bio'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      yearsExperience: json['years_experience'] as int?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      stripeAccountId: json['stripe_account_id'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      instagramHandle: json['instagram_handle'] as String?,
      shopId: json['shop_id'] as String?,
      isIndependent: json['is_independent'] as bool? ?? true,
      bookingRequiresConfirmation: json['booking_requires_confirmation'] as bool? ?? true,
      instantBookEnabled: json['instant_book_enabled'] as bool? ?? false,
      subscriptionPrice: (json['subscription_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['profiles'] != null
          ? AppUser.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      portfolio: (json['portfolio_images'] as List<dynamic>?)
          ?.map((e) => PortfolioImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      shop: json['shops'] != null
          ? Shop.fromJson(json['shops'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
      'specialties': specialties,
      'years_experience': yearsExperience,
      'hourly_rate': hourlyRate,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'stripe_account_id': stripeAccountId,
      'is_available': isAvailable,
      'rating': rating,
      'review_count': reviewCount,
      'instagram_handle': instagramHandle,
      'shop_id': shopId,
      'is_independent': isIndependent,
      'booking_requires_confirmation': bookingRequiresConfirmation,
      'instant_book_enabled': instantBookEnabled,
      'subscription_price': subscriptionPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName => user?.fullName ?? 'Unknown Barber';
  String? get avatarUrl => user?.avatarUrl;

  BarberProfile copyWith({
    String? id,
    String? userId,
    String? bio,
    List<String>? specialties,
    int? yearsExperience,
    double? hourlyRate,
    double? latitude,
    double? longitude,
    String? address,
    String? stripeAccountId,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    String? instagramHandle,
    String? shopId,
    bool? isIndependent,
    bool? bookingRequiresConfirmation,
    bool? instantBookEnabled,
    double? subscriptionPrice,
    DateTime? createdAt,
    AppUser? user,
    List<Service>? services,
    List<PortfolioImage>? portfolio,
    Shop? shop,
  }) {
    return BarberProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      shopId: shopId ?? this.shopId,
      isIndependent: isIndependent ?? this.isIndependent,
      bookingRequiresConfirmation: bookingRequiresConfirmation ?? this.bookingRequiresConfirmation,
      instantBookEnabled: instantBookEnabled ?? this.instantBookEnabled,
      subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      services: services ?? this.services,
      portfolio: portfolio ?? this.portfolio,
      shop: shop ?? this.shop,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BarberProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@immutable
class Service {
  final String id;
  final String barberId;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final bool isActive;

  const Service({
    required this.id,
    required this.barberId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    this.isActive = true,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      barberId: json['barber_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'price': price,
      'is_active': isActive,
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration => '${durationMinutes}min';
}

@immutable
class PortfolioImage {
  final String id;
  final String barberId;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;

  const PortfolioImage({
    required this.id,
    required this.barberId,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
  });

  factory PortfolioImage.fromJson(Map<String, dynamic> json) {
    return PortfolioImage(
      id: json['id'] as String,
      barberId: json['barber_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber_id': barberId,
      'image_url': imageUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
