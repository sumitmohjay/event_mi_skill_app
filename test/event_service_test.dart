import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_mi_skill/src/core/api/api_client.dart';
import 'package:event_mi_skill/src/event_management/services/event_service.dart';

void main() {
  group('EventService Tests', () {
    late EventService eventService;
    late ApiClient apiClient;

    setUp(() async {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      apiClient = ApiClient(prefs);
      eventService = EventService(apiClient);
    });

    test('should create EventService instance', () {
      expect(eventService, isNotNull);
    });

    test('should return empty events when API fails', () async {
      // This test will fail gracefully when API is not available
      final events = await eventService.getFormattedEvents();
      
      expect(events, isNotNull);
      expect(events.containsKey('today'), true);
      expect(events.containsKey('upcoming'), true);
      expect(events.containsKey('past'), true);
    });

    test('should handle category filtering', () async {
      final events = await eventService.getEventsByCategory('Technical');
      
      expect(events, isNotNull);
      expect(events.containsKey('today'), true);
      expect(events.containsKey('upcoming'), true);
      expect(events.containsKey('past'), true);
    });
  });
}
