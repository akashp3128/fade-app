class AppConstants {
  // App Info
  static const String appName = 'Fade';
  static const String appTagline = 'Find your perfect barber';

  // Supabase - Use --dart-define or environment variables
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Stripe
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  // Google Maps
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Default values
  static const double defaultSearchRadius = 10.0; // km
  static const int defaultPageSize = 20;
  static const Duration sessionTimeout = Duration(hours: 24);

  // Appointment statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // User types
  static const String userTypeClient = 'client';
  static const String userTypeBarber = 'barber';

  // Storage buckets
  static const String avatarsBucket = 'avatars';
  static const String portfolioBucket = 'portfolio';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

class AppAssets {
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String emptyState = 'assets/images/empty_state.png';

  // Icons
  static const String iconGoogle = 'assets/icons/google.svg';
  static const String iconApple = 'assets/icons/apple.svg';
  static const String iconLocation = 'assets/icons/location.svg';
  static const String iconCalendar = 'assets/icons/calendar.svg';
  static const String iconScissors = 'assets/icons/scissors.svg';
}
