import 'package:dartz/dartz.dart';
import 'event.dart';
import 'event_repository.dart';
import 'event_local_datasource.dart';

class EventRepositoryImpl implements EventRepository {
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<String, List<Event>>> getAllEvents() async {
    try {
      final events = await localDataSource.getAllEvents();
      return Right(events);
    } catch (e) {
      return Left('Failed to get events: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Event>> getEventById(String id) async {
    try {
      final event = await localDataSource.getEventById(id);
      if (event != null) {
        return Right(event);
      } else {
        return const Left('Event not found');
      }
    } catch (e) {
      return Left('Failed to get event: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Event>>> getEventsByCategory(EventCategory category) async {
    try {
      final events = await localDataSource.getAllEvents();
      final filteredEvents = events.where((event) => event.category == category).toList();
      return Right(filteredEvents);
    } catch (e) {
      return Left('Failed to get events by category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Event>>> searchEvents(String query) async {
    try {
      final events = await localDataSource.getAllEvents();
      final filteredEvents = events.where((event) {
        final searchQuery = query.toLowerCase();
        return event.title.toLowerCase().contains(searchQuery) ||
               event.description.toLowerCase().contains(searchQuery) ||
               event.venue.toLowerCase().contains(searchQuery) ||
               event.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
      }).toList();
      return Right(filteredEvents);
    } catch (e) {
      return Left('Failed to search events: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Event>> createEvent(Event event) async {
    try {
      final newEvent = event.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await localDataSource.cacheEvent(newEvent);
      return Right(newEvent);
    } catch (e) {
      return Left('Failed to create event: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Event>> updateEvent(Event event) async {
    try {
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      await localDataSource.cacheEvent(updatedEvent);
      return Right(updatedEvent);
    } catch (e) {
      return Left('Failed to update event: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> deleteEvent(String id) async {
    try {
      await localDataSource.deleteEvent(id);
      return const Right(true);
    } catch (e) {
      return Left('Failed to delete event: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Event>>> getUpcomingEvents() async {
    try {
      final events = await localDataSource.getAllEvents();
      final now = DateTime.now();
      final upcomingEvents = events
          .where((event) => event.dateTime.isAfter(now) && event.isActive)
          .toList();
      upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return Right(upcomingEvents);
    } catch (e) {
      return Left('Failed to get upcoming events: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Event>>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final events = await localDataSource.getAllEvents();
      final filteredEvents = events.where((event) {
        return event.dateTime.isAfter(start) && event.dateTime.isBefore(end);
      }).toList();
      return Right(filteredEvents);
    } catch (e) {
      return Left('Failed to get events by date range: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, String>> uploadEventResource(String eventId, String filePath) async {
    try {
      final event = await localDataSource.getEventById(eventId);
      if (event != null) {
        final updatedResources = List<String>.from(event.resources)..add(filePath);
        final updatedEvent = event.copyWith(
          resources: updatedResources,
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheEvent(updatedEvent);
        return Right(filePath);
      } else {
        return const Left('Event not found');
      }
    } catch (e) {
      return Left('Failed to upload resource: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> removeEventResource(String eventId, String resourceUrl) async {
    try {
      final event = await localDataSource.getEventById(eventId);
      if (event != null) {
        final updatedResources = List<String>.from(event.resources)..remove(resourceUrl);
        final updatedEvent = event.copyWith(
          resources: updatedResources,
          updatedAt: DateTime.now(),
        );
        await localDataSource.cacheEvent(updatedEvent);
        return const Right(true);
      } else {
        return const Left('Event not found');
      }
    } catch (e) {
      return Left('Failed to remove resource: ${e.toString()}');
    }
  }
}
