import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;

  BookingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });
}

class NotificationNotifier extends StateNotifier<BookingNotification?> {
  NotificationNotifier() : super(null);

  void simulateIncomingRequest() {
    state = BookingNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Booking Request',
      body: 'Mike wants a Premium Fade on Friday at 5:00 PM',
      timestamp: DateTime.now(),
    );
  }

  void clearNotification() {
    state = null;
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, BookingNotification?>((ref) {
  return NotificationNotifier();
});
