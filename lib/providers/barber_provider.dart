import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../services/supabase_service.dart';
import '../services/google_places_service.dart';

// Search/filter state
class BarberSearchState {
// ... existing state class ...
  final String? query;
  final String? specialty;
  final double? minRating;
  final double? maxDistance;
  final bool isLoading;
  final List<BarberProfile> results;
  final String? error;

  const BarberSearchState({
    this.query,
    this.specialty,
    this.minRating,
    this.maxDistance,
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  BarberSearchState copyWith({
    String? query,
    String? specialty,
    double? minRating,
    double? maxDistance,
    bool? isLoading,
    List<BarberProfile>? results,
    String? error,
  }) {
    return BarberSearchState(
      query: query ?? this.query,
      specialty: specialty ?? this.specialty,
      minRating: minRating ?? this.minRating,
      maxDistance: maxDistance ?? this.maxDistance,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
    );
  }
}

final googlePlacesServiceProvider = Provider((ref) => GooglePlacesService());

// Search location provider (Default: Chicago)
final searchLocationProvider = StateProvider<({double lat, double lng})>((ref) {
  return (lat: 41.8781, lng: -87.6298);
});

// Featured/nearby barbers provider
final featuredBarbersProvider = FutureProvider<List<BarberProfile>>((ref) async {
  try {
    final location = ref.watch(searchLocationProvider);
    final service = ref.read(supabaseServiceProvider);
    final barbers = await service.getBarbers(
      latitude: location.lat,
      longitude: location.lng,
      limit: 10,
    );
    if (barbers.isNotEmpty) return barbers;
  } catch (e) {
    // Fallback to mock data on error or empty
  }
  return _mockBarbers;
});

// All barbers provider with pagination
final barbersProvider = FutureProvider.family<List<BarberProfile>, int>((ref, offset) async {
  try {
    final location = ref.read(searchLocationProvider); // Read once, don't watch for pagination
    final service = ref.read(supabaseServiceProvider);
    final barbers = await service.getBarbers(
      latitude: location.lat,
      longitude: location.lng,
      offset: offset, 
      limit: 20
    );
    if (barbers.isNotEmpty) return barbers;
  } catch (e) {}
  return _mockBarbers;
});

// Shops provider
final shopsProvider = FutureProvider<List<Shop>>((ref) async {
  final location = ref.watch(searchLocationProvider);
  final placesService = ref.read(googlePlacesServiceProvider);
  
  // Try to fetch real places around current location
  try {
    final realShops = await placesService.searchShops(
      latitude: location.lat,
      longitude: location.lng,
    );
    if (realShops.isNotEmpty) {
      return [..._mockShops, ...realShops];
    }
  } catch (e) {
    // Ignore errors and return mock
  }

  return _mockShops;
});

// Barbers by shop provider
final barbersByShopProvider = FutureProvider.family<List<BarberProfile>, String>((ref, shopId) async {
  try {
    final service = ref.read(supabaseServiceProvider);
    final barbers = await service.getBarbersByShop(shopId);
    if (barbers.isNotEmpty) return barbers;
  } catch (e) {}
  return _mockBarbers.where((b) => b.shopId == shopId).toList();
});

// Single barber by ID
final barberByIdProvider = FutureProvider.family<BarberProfile?, String>((ref, barberId) async {
  try {
    final service = ref.read(supabaseServiceProvider);
    final barber = await service.getBarberById(barberId);
    if (barber != null) return barber;
  } catch (e) {}
  return _mockBarbers.firstWhere((b) => b.id == barberId, orElse: () => _mockBarbers.first);
});

// Barber reviews provider
final barberReviewsProvider = FutureProvider.family<List<Review>, String>((ref, barberId) async {
  final service = ref.read(supabaseServiceProvider);
  return service.getBarberReviews(barberId);
});

// Barber services provider
final barberServicesProvider = FutureProvider.family<List<Service>, String>((ref, barberId) async {
  final service = ref.read(supabaseServiceProvider);
  return service.getBarberServices(barberId);
});

// Available time slots provider
final availableSlotsProvider = FutureProvider.family<List<DateTime>, ({String barberId, DateTime date, int duration})>((ref, params) async {
  final service = ref.read(supabaseServiceProvider);
  return service.getAvailableSlots(params.barberId, params.date, params.duration);
});

// Search state notifier
class BarberSearchNotifier extends StateNotifier<BarberSearchState> {
  final Ref _ref;

  BarberSearchNotifier(this._ref) : super(const BarberSearchState());

  Future<void> search({
    String? query,
    String? specialty,
    double? minRating,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      query: query,
      specialty: specialty,
      minRating: minRating,
      error: null,
    );

    try {
      final service = _ref.read(supabaseServiceProvider);
      // Use provided lat/long or fall back to provider state
      final location = (latitude != null && longitude != null) 
          ? (lat: latitude, lng: longitude)
          : _ref.read(searchLocationProvider);

      var results = await service.getBarbers(
        specialty: specialty,
        minRating: minRating,
        latitude: location.lat,
        longitude: location.lng,
      );

      if (results.isEmpty && query == null && specialty == null) {
        results = _mockBarbers;
      }

      // Client-side query filter
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        final searchSource = results.isEmpty ? _mockBarbers : results;
        results = searchSource.where((barber) {
          final name = barber.displayName.toLowerCase();
          final bio = barber.bio?.toLowerCase() ?? '';
          final specialties = barber.specialties.join(' ').toLowerCase();
          return name.contains(lowerQuery) ||
              bio.contains(lowerQuery) ||
              specialties.contains(lowerQuery);
        }).toList();
      }

      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, results: _mockBarbers);
    }
  }

  void clearFilters() {
    state = const BarberSearchState();
  }

  void setSpecialty(String? specialty) {
    search(
      query: state.query,
      specialty: specialty,
      minRating: state.minRating,
    );
  }

  void setMinRating(double? rating) {
    search(
      query: state.query,
      specialty: state.specialty,
      minRating: rating,
    );
  }
}

final barberSearchProvider = StateNotifierProvider<BarberSearchNotifier, BarberSearchState>((ref) {
  return BarberSearchNotifier(ref);
});

// Favorites providers
final favoriteBarbersProvider = FutureProvider.family<List<BarberProfile>, String>((ref, clientId) async {
  final service = ref.read(supabaseServiceProvider);
  return service.getFavorites(clientId);
});

final isFavoriteProvider = FutureProvider.family<bool, ({String clientId, String barberId})>((ref, params) async {
  final service = ref.read(supabaseServiceProvider);
  return service.isFavorite(params.clientId, params.barberId);
});

// Favorites notifier for toggling
class FavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  final String clientId;

  FavoritesNotifier(this._ref, this.clientId) : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final service = _ref.read(supabaseServiceProvider);
      final favorites = await service.getFavorites(clientId);
      state = favorites.map((b) => b.id).toSet();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggle(String barberId) async {
    final service = _ref.read(supabaseServiceProvider);

    if (state.contains(barberId)) {
      await service.removeFavorite(clientId, barberId);
      state = {...state}..remove(barberId);
    } else {
      await service.addFavorite(clientId, barberId);
      state = {...state, barberId};
    }
  }

  bool isFavorite(String barberId) => state.contains(barberId);
}

final favoritesNotifierProvider = StateNotifierProvider.family<FavoritesNotifier, Set<String>, String>((ref, clientId) {
  return FavoritesNotifier(ref, clientId);
});

// Specialty categories
final specialtiesProvider = Provider<List<String>>((ref) {
  return [
    'Haircut',
    'Beard Trim',
    'Shave',
    'Hair Color',
    'Kids Cut',
    'Fade',
    'Line Up',
    'Hot Towel',
  ];
});

// ======= MOCK DATA =======

final _mockShops = [
  const Shop(
    id: 'shop_1',
    name: 'The Gold Coast Fade',
    address: '100 E Walton St, Chicago, IL 60611',
    latitude: 41.9002,
    longitude: -87.6255,
    avatarUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=500&auto=format&fit=crop',
  ),
  const Shop(
    id: 'shop_2',
    name: 'Wicker Park Barbers',
    address: '1579 N Milwaukee Ave, Chicago, IL 60622',
    latitude: 41.9100,
    longitude: -87.6760,
    avatarUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&w=500&auto=format&fit=crop',
  ),
];

final _mockBarbers = [
  BarberProfile(
    id: 'barber_1',
    userId: 'u1',
    isIndependent: true,
    bio: 'Cutting out of my private studio in Logan Square. Precision fades and urban styles.',
    specialties: ['Fade', 'Line Up', 'Design'],
    yearsExperience: 8,
    rating: 4.9,
    reviewCount: 128,
    latitude: 41.9250,
    longitude: -87.6870,
    address: '2400 N Western Ave, Chicago, IL',
    instagramHandle: '@leoblade_cuts',
    bookingRequiresConfirmation: true,
    instantBookEnabled: false,
    subscriptionPrice: 9.99,
    createdAt: DateTime.now(),
    user: AppUser(
      id: 'u1',
      email: 'leo@example.com',
      fullName: 'Leo "The Blade" Rodriguez',
      userType: UserType.barber,
      avatarUrl: 'https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?q=80&w=200',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    services: [
      const Service(id: 's1', barberId: 'barber_1', name: 'Nano Fade', durationMinutes: 45, price: 45),
      const Service(id: 's2', barberId: 'barber_1', name: 'Beard Sculpt', durationMinutes: 30, price: 25),
    ],
    portfolio: [
      PortfolioImage(id: 'p1', barberId: 'barber_1', imageUrl: 'https://images.unsplash.com/photo-1599351431247-f10b21ce9634?q=80&w=400', createdAt: DateTime.now()),
      PortfolioImage(id: 'p2', barberId: 'barber_1', imageUrl: 'https://images.unsplash.com/photo-1621605815841-2ae606382a32?q=80&w=400', createdAt: DateTime.now()),
    ],
  ),
  BarberProfile(
    id: 'barber_2',
    userId: 'u2',
    isIndependent: false,
    shopId: 'shop_1',
    shop: _mockShops[0],
    bio: 'Senior barber at Gold Coast Fade. Executive grooming and classic scissor cuts.',
    specialties: ['Classic Cut', 'Shave', 'Hot Towel'],
    yearsExperience: 12,
    rating: 4.8,
    reviewCount: 256,
    latitude: 41.9002,
    longitude: -87.6255,
    address: '100 E Walton St, Chicago, IL',
    instagramHandle: '@marcust_cuts',
    bookingRequiresConfirmation: false,
    instantBookEnabled: true,
    subscriptionPrice: 0.0,
    createdAt: DateTime.now(),
    user: AppUser(
      id: 'u2',
      email: 'marcus@example.com',
      fullName: 'Marcus Thompson',
      userType: UserType.barber,
      avatarUrl: 'https://images.unsplash.com/photo-1531384441138-2736e62e0919?q=80&w=200',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    services: [
      const Service(id: 's3', barberId: 'barber_2', name: 'Executive Cut', durationMinutes: 45, price: 60),
    ],
  ),
  BarberProfile(
    id: 'barber_3',
    userId: 'u3',
    isIndependent: true,
    bio: 'Luxury mobile and penthouse services. Specialist in modern texture and color.',
    specialties: ['Styling', 'Color', 'Texture'],
    yearsExperience: 6,
    rating: 5.0,
    reviewCount: 45,
    latitude: 41.8870,
    longitude: -87.6390,
    address: '333 N Canal St, Chicago, IL',
    instagramHandle: '@sarahstyled_chi',
    bookingRequiresConfirmation: false,
    instantBookEnabled: true,
    subscriptionPrice: 19.99,
    createdAt: DateTime.now(),
    user: AppUser(
      id: 'u3',
      email: 'sarah@example.com',
      fullName: 'Sarah "Stylist" Chen',
      userType: UserType.barber,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ),
];
