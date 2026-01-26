import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRole { client, barber }

class AppRoleNotifier extends StateNotifier<AppRole> {
  AppRoleNotifier() : super(AppRole.client);

  void switchToBarber() => state = AppRole.barber;
  void switchToClient() => state = AppRole.client;
  void toggleRole() => state = state == AppRole.client ? AppRole.barber : AppRole.client;
}

final appRoleProvider = StateNotifierProvider<AppRoleNotifier, AppRole>((ref) {
  return AppRoleNotifier();
});
