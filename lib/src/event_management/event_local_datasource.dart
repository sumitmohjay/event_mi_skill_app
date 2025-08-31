import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'event.dart';

abstract class EventLocalDataSource {
  Future<List<Event>> getAllEvents();
  Future<Event?> getEventById(String id);
  Future<void> cacheEvents(List<Event> events);
  Future<void> cacheEvent(Event event);
  Future<void> deleteEvent(String id);
  Future<void> clearCache();
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  static const String _eventsKey = 'cached_events';
  final SharedPreferences sharedPreferences;

  EventLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      final jsonString = sharedPreferences.getString(_eventsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get cached events: $e');
    }
  }

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final events = await getAllEvents();
      return events.firstWhere(
        (event) => event.id == id,
        orElse: () => throw Exception('Event not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheEvents(List<Event> events) async {
    try {
      final jsonList = events.map((event) => event.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_eventsKey, jsonString);
    } catch (e) {
      throw Exception('Failed to cache events: $e');
    }
  }

  @override
  Future<void> cacheEvent(Event event) async {
    try {
      final events = await getAllEvents();
      final existingIndex = events.indexWhere((e) => e.id == event.id);
      
      if (existingIndex != -1) {
        events[existingIndex] = event;
      } else {
        events.add(event);
      }
      
      await cacheEvents(events);
    } catch (e) {
      throw Exception('Failed to cache event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final events = await getAllEvents();
      events.removeWhere((event) => event.id == id);
      await cacheEvents(events);
    } catch (e) {
      throw Exception('Failed to delete cached event: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_eventsKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }
}
