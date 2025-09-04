import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import '../../event_management/event.dart';

class EventApiService {
  final ApiClient _apiClient;

  EventApiService(this._apiClient);

  /// Fetch all events from the API
  Future<EventsResponse> getAllEvents({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('/events?page=$page&limit=$limit');
      print('📡 Events API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Parsed events data: $data');
        
        if (data != null && data['success'] == true && data['data'] != null) {
          return EventsResponse.fromJson(data['data']);
        } else {
          throw Exception('Invalid response structure: $data');
        }
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error in getAllEvents: ${e.toString()}');
      throw Exception('Failed to load events: ${e.toString()}');
    }
  }

  /// Upload an image file to the server
  Future<String> uploadImage(String filePath) async {
    try {
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // For web, fetch the blob and convert to bytes
        final response = await http.get(Uri.parse(filePath));
        final bytes = response.bodyBytes;
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        // For mobile/desktop, use file path
        multipartFile = await MultipartFile.fromFile(filePath);
      }
      
      final formData = FormData.fromMap({
        'images': multipartFile,
      });
      
      // Get the access token
      final token = await _apiClient.getAccessToken();
      
      // Create a new Dio instance for file uploads with the base URL
      final dio = Dio(BaseOptions(
        baseUrl: 'https://lms-latest-dsrn.onrender.com/api',
        headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));
      
      print('📤 Uploading image: $filePath');
      final response = await dio.post<Map<String, dynamic>>(
        '/uploads/event/images',
        data: formData,
      );
      
      print('📥 Image upload response: ${response.statusCode} - ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          if (responseData['images'] != null && responseData['images'] is List) {
            final images = responseData['images'] as List;
            if (images.isNotEmpty && images[0]['url'] != null) {
              return images[0]['url'] as String;
            }
          }
        }
        throw Exception('Invalid response structure: $data');
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      print('🚨 Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload a video file to the server
  Future<String> uploadVideo(String filePath) async {
    try {
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // For web, fetch the blob and convert to bytes
        final response = await http.get(Uri.parse(filePath));
        final bytes = response.bodyBytes;
        final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        // For mobile/desktop, use file path
        multipartFile = await MultipartFile.fromFile(filePath);
      }
      
      final formData = FormData.fromMap({
        'videos': multipartFile,
      });
      
      // Get the access token
      final token = await _apiClient.getAccessToken();
      
      // Create a new Dio instance for file uploads with the base URL
      final dio = Dio(BaseOptions(
        baseUrl: 'https://lms-latest-dsrn.onrender.com/api',
        headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));
      
      print('📤 Uploading video: $filePath');
      final response = await dio.post<Map<String, dynamic>>(
        '/uploads/event/videos',
        data: formData,
      );
      
      print('📥 Video upload response: ${response.statusCode} - ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          if (responseData['videos'] != null && responseData['videos'] is List) {
            final videos = responseData['videos'] as List;
            if (videos.isNotEmpty && videos[0]['url'] != null) {
              return videos[0]['url'] as String;
            }
          }
        }
        throw Exception('Invalid response structure: $data');
      } else {
        throw Exception('Failed to upload video: ${response.statusMessage}');
      }
    } catch (e) {
      print('🚨 Error uploading video: $e');
      rethrow;
    }
  }

  /// Upload a file to the server (legacy method for backward compatibility)
  Future<String> uploadFile(String filePath) async {
    print('🔍 uploadFile called with: $filePath');
    print('🌐 kIsWeb: $kIsWeb');
    print('🔗 startsWith blob: ${filePath.startsWith('blob:')}');
    
    // Determine file type and use appropriate upload method
    final lower = filePath.toLowerCase();
    
    // For web blob URLs, we need to check differently or default to image
    if (kIsWeb && filePath.startsWith('blob:')) {
      print('📸 Routing blob URL to uploadImage');
      // For web blobs, default to image upload since we can't determine type from URL
      return await uploadImage(filePath);
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || 
        lower.endsWith('.png') || lower.endsWith('.gif')) {
      print('📸 Routing image file to uploadImage');
      return await uploadImage(filePath);
    } else if (lower.endsWith('.mp4') || lower.endsWith('.mov') || 
               lower.endsWith('.avi')) {
      print('🎥 Routing video file to uploadVideo');
      return await uploadVideo(filePath);
    } else {
      print('📄 Using generic upload for: $filePath');
      // For other files, use generic upload
      try {
        MultipartFile multipartFile;
        
        if (kIsWeb) {
          // For web, fetch the blob and convert to bytes
          final response = await http.get(Uri.parse(filePath));
          final bytes = response.bodyBytes;
          final fileName = 'file_${DateTime.now().millisecondsSinceEpoch}';
          multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
        } else {
          // For mobile/desktop, use file path
          multipartFile = await MultipartFile.fromFile(filePath);
        }
        
        final formData = FormData.fromMap({
          'file': multipartFile,
        });
        
        // Get the access token
        final token = await _apiClient.getAccessToken();
        
        // Create a new Dio instance for file uploads with the base URL
        final dio = Dio(BaseOptions(
          baseUrl: 'https://lms-latest-dsrn.onrender.com/api',
          headers: {
            'Content-Type': 'multipart/form-data',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ));
        
        print('📤 Uploading file: $filePath');
        final response = await dio.post<Map<String, dynamic>>(
          '/upload',
          data: formData,
        );
        
        print('📥 File upload response: ${response.statusCode} - ${response.data}');
        
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data!;
          if (data['success'] == true && data['url'] != null) {
            return data['url'] as String;
          } else {
            throw Exception('Invalid response structure: $data');
          }
        } else {
          throw Exception('Failed to upload file: ${response.statusMessage}');
        }
      } catch (e) {
        print('🚨 Error uploading file: $e');
        rethrow;
      }
    }
  }

  /// Upload multiple files and return their URLs
  Future<List<String>> uploadFiles(List<String> filePaths) async {
    final List<String> urls = [];
    
    for (final path in filePaths) {
      try {
        final url = await uploadFile(path);
        urls.add(url);
      } catch (e) {
        print('⚠️ Failed to upload file $path: $e');
        // Continue with other files if one fails
      }
    }
    
    return urls;
  }

  /// Create a new event
  Future<Event> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    EventMode mode = EventMode.offline,
    EventCategory category = EventCategory.other,
    double? price,
    int? maxParticipants,
    DateTime? registrationDeadline,
    List<String>? images,
    List<String>? videos,
    List<String>? tags,
  }) async {
    try {
      // Filter out non-local files (already uploaded URLs)
      final localImages = images?.where((path) => !path.startsWith('http') && !path.startsWith('/uploads')).toList() ?? [];
      final localVideos = videos?.where((path) => !path.startsWith('http') && !path.startsWith('/uploads')).toList() ?? [];
      
      // Get existing remote URLs
      final existingImageUrls = images?.where((path) => path.startsWith('http') || path.startsWith('/uploads')).toList() ?? [];
      final existingVideoUrls = videos?.where((path) => path.startsWith('http') || path.startsWith('/uploads')).toList() ?? [];
      
      // Upload new files
      final uploadedImageUrls = await uploadFiles(localImages);
      final uploadedVideoUrls = await uploadFiles(localVideos);
      
      // Combine existing and new URLs
      final allImageUrls = [...existingImageUrls, ...uploadedImageUrls];
      final allVideoUrls = [...existingVideoUrls, ...uploadedVideoUrls];
      
      final eventData = {
        'title': title,
        'description': description,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'mode': mode.toString().split('.').last,
        'category': category.toString().split('.').last,
        if (price != null) 'price': price,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
        if (registrationDeadline != null) 
          'registrationDeadline': registrationDeadline.toIso8601String(),
        if (allImageUrls.isNotEmpty) 'images': allImageUrls,
        if (allVideoUrls.isNotEmpty) 'videos': allVideoUrls,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      };

      print('📡 Creating event with data: $eventData');
      final response = await _apiClient.post('/events', eventData);
      
      print('📡 Create Event API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data != null && data['success'] == true && data['data'] != null) {
          return Event.fromApiJson(data['data']);
        } else {
          throw Exception('Invalid response structure: $data');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      print('🚨 Error in createEvent: ${e.toString()}');
      rethrow;
    }
  }

  /// Update an existing event
  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    EventMode mode = EventMode.offline,
    EventCategory category = EventCategory.other,
    double? price,
    int? maxParticipants,
    DateTime? registrationDeadline,
    List<String>? images,
    List<String>? videos,
    List<String>? tags,
    bool? isActive,
  }) async {
    try {
      // Filter out non-local files (already uploaded URLs)
      final localImages = images?.where((path) => !path.startsWith('http') && !path.startsWith('/uploads')).toList() ?? [];
      final localVideos = videos?.where((path) => !path.startsWith('http') && !path.startsWith('/uploads')).toList() ?? [];
      
      // Get existing remote URLs
      final existingImageUrls = images?.where((path) => path.startsWith('http') || path.startsWith('/uploads')).toList() ?? [];
      final existingVideoUrls = videos?.where((path) => path.startsWith('http') || path.startsWith('/uploads')).toList() ?? [];
      
      // Upload new files
      final uploadedImageUrls = await uploadFiles(localImages);
      final uploadedVideoUrls = await uploadFiles(localVideos);
      
      // Combine existing and new URLs
      final allImageUrls = [...existingImageUrls, ...uploadedImageUrls];
      final allVideoUrls = [...existingVideoUrls, ...uploadedVideoUrls];
      
      final eventData = {
        'title': title,
        'description': description,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'mode': mode.toString().split('.').last,
        'category': category.toString().split('.').last,
        if (price != null) 'price': price,
        if (maxParticipants != null) 'maxParticipants': maxParticipants,
        if (registrationDeadline != null) 
          'registrationDeadline': registrationDeadline.toIso8601String(),
        if (allImageUrls.isNotEmpty) 'images': allImageUrls,
        if (allVideoUrls.isNotEmpty) 'videos': allVideoUrls,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (isActive != null) 'isActive': isActive,
      };

      print('📡 Updating event $eventId with data: $eventData');
      final response = await _apiClient.patch('/events/$eventId', body: jsonEncode(eventData));
      
      print('📡 Update Event API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data != null && data['success'] == true && data['data'] != null) {
          return Event.fromApiJson(data['data']);
        } else {
          throw Exception('Invalid response structure: $data');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update event');
      }
    } catch (e) {
      print('🚨 Error in updateEvent: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    try {
      final response = await _apiClient.delete('/events/$eventId');
      print('📡 Delete Event API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error in deleteEvent: ${e.toString()}');
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }

  /// Get event by ID
  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _apiClient.get('/events/$eventId');
      print('📡 Get Event API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data != null && data['success'] == true && data['data'] != null) {
          return Event.fromApiJson(data['data']);
        } else {
          throw Exception('Invalid response structure: $data');
        }
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error in getEventById: ${e.toString()}');
      throw Exception('Failed to load event: ${e.toString()}');
    }
  }

  /// Get event by slug
  Future<Event> getEventBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/events/slug/$slug');
      print('📡 Get Event by Slug API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data != null && data['success'] == true && data['data'] != null) {
          return Event.fromApiJson(data['data']);
        } else {
          throw Exception('Invalid response structure: $data');
        }
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🚨 Error in getEventBySlug: ${e.toString()}');
      throw Exception('Failed to load event: ${e.toString()}');
    }
  }
}

/// Response model for events API
class EventsResponse {
  final List<Event> events;
  final EventsPagination pagination;

  EventsResponse({
    required this.events,
    required this.pagination,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      events: (json['events'] as List<dynamic>)
          .map((eventJson) => Event.fromApiJson(eventJson as Map<String, dynamic>))
          .toList(),
      pagination: EventsPagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// Pagination model for events
class EventsPagination {
  final int currentPage;
  final int totalPages;
  final int totalEvents;
  final bool hasNextPage;
  final bool hasPrevPage;

  EventsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalEvents,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory EventsPagination.fromJson(Map<String, dynamic> json) {
    return EventsPagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalEvents: json['totalEvents'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
