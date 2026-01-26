import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/client/home_screen.dart';
import '../screens/client/search_screen.dart';
import '../screens/client/barber_detail_screen.dart';
import '../screens/client/booking_screen.dart';
import '../screens/client/appointments_screen.dart';
import '../screens/client/profile_screen.dart';
import '../screens/client/feed_screen.dart';
import '../screens/client/academy_screen.dart';
import '../screens/client/course_detail_screen.dart';
import '../screens/barber/dashboard_screen.dart';
import '../screens/barber/calendar_screen.dart';
import '../screens/barber/earnings_screen.dart';
import '../screens/barber/profile_edit_screen.dart';
import '../screens/barber/content_studio_screen.dart';
import '../screens/barber/stripe_connect_screen.dart';
import '../providers/auth_provider.dart';

// Route names
class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Client routes
  static const String clientHome = '/client/home';
  static const String feed = '/client/feed';
  static const String academy = '/client/academy';
  static const String courseDetail = '/client/course'; // append /:id
  static const String search = '/client/search';
  static const String barberDetail = '/client/barber'; // append /:id for navigation
  static const String booking = '/client/booking'; // append /:barberId for navigation
  static const String appointments = '/client/appointments';
  static const String clientAppointments = '/client/appointments'; // alias
  static const String clientProfile = '/client/profile';

  // Barber routes
  static const String barberDashboard = '/barber/dashboard';
  static const String barberCalendar = '/barber/calendar';
  static const String barberEarnings = '/barber/earnings';
  static const String barberProfile = '/barber/profile';
  static const String barberProfileEdit = '/barber/profile'; // alias
  static const String barberContentStudio = '/barber/studio';
  static const String barberStripeSetup = '/barber/stripe-setup';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register ||
          state.matchedLocation == Routes.onboarding;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != Routes.splash) {
        return Routes.login;
      }

      // If logged in and trying to access auth route
      if (isLoggedIn && isAuthRoute) {
        // TODO: Redirect based on user type
        return Routes.clientHome;
      }

      return null;
    },
    routes: [
      // Splash/Loading
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Client routes
      GoRoute(
        path: Routes.clientHome,
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: Routes.feed,
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: Routes.academy,
        builder: (context, state) => const AcademyScreen(),
      ),
      GoRoute(
        path: '/client/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/client/barber/:id',
        builder: (context, state) {
          final barberId = state.pathParameters['id']!;
          return BarberDetailScreen(barberId: barberId);
        },
      ),
      GoRoute(
        path: '/client/booking/:barberId',
        builder: (context, state) {
          final barberId = state.pathParameters['barberId']!;
          final serviceId = state.uri.queryParameters['serviceId'];
          return BookingScreen(barberId: barberId, initialServiceId: serviceId);
        },
      ),
      GoRoute(
        path: Routes.clientAppointments,
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: Routes.clientProfile,
        builder: (context, state) => const ClientProfileScreen(),
      ),

      // Barber routes
      GoRoute(
        path: Routes.barberDashboard,
        builder: (context, state) => const BarberDashboardScreen(),
      ),
      GoRoute(
        path: Routes.barberCalendar,
        builder: (context, state) => const BarberCalendarScreen(),
      ),
      GoRoute(
        path: Routes.barberEarnings,
        builder: (context, state) => const BarberEarningsScreen(),
      ),
      GoRoute(
        path: Routes.barberProfile,
        builder: (context, state) => const BarberProfileEditScreen(),
      ),
      GoRoute(
        path: Routes.barberContentStudio,
        builder: (context, state) => const ContentStudioScreen(),
      ),
      GoRoute(
        path: Routes.barberStripeSetup,
        builder: (context, state) => const StripeConnectScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

// Splash screen with auth check
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          context.go(Routes.clientHome);
        } else {
          context.go(Routes.login);
        }
      },
      loading: () {
        // Still loading, wait and check again
        Future.delayed(const Duration(milliseconds: 500), _checkAuthAndNavigate);
      },
      error: (_, __) {
        context.go(Routes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.content_cut,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fade',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find your perfect barber',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFE94560),
            ),
          ],
        ),
      ),
    );
  }
}
