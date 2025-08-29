import 'package:equatable/equatable.dart';

enum EventMode { online, offline, hybrid }

enum EventCategory { 
  academic, 
  cultural, 
  technical, 
  workshop, 
  seminar, 
  webinar, 
  conference,
  sports,
  social,
  other
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String venue;
  final EventMode mode;
  final EventCategory category;
  final List<String> resources; // URLs or file paths for brochures, schedules, recordings
  final String? imageUrl;
  final double? price;
  final int maxAttendees;
  final int currentAttendees;
  final String organizerId;
  final String organizerName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? meetingLink; // For online events
  final String? contactEmail;
  final String? contactPhone;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.venue,
    required this.mode,
    required this.category,
    this.resources = const [],
    this.imageUrl,
    this.price,
    required this.maxAttendees,
    this.currentAttendees = 0,
    required this.organizerId,
    required this.organizerName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.meetingLink,
    this.contactEmail,
    this.contactPhone,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? venue,
    EventMode? mode,
    EventCategory? category,
    List<String>? resources,
    String? imageUrl,
    double? price,
    int? maxAttendees,
    int? currentAttendees,
    String? organizerId,
    String? organizerName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? meetingLink,
    String? contactEmail,
    String? contactPhone,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      mode: mode ?? this.mode,
      category: category ?? this.category,
      resources: resources ?? this.resources,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      meetingLink: meetingLink ?? this.meetingLink,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'mode': mode.name,
      'category': category.name,
      'resources': resources,
      'imageUrl': imageUrl,
      'price': price,
      'maxAttendees': maxAttendees,
      'currentAttendees': currentAttendees,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'meetingLink': meetingLink,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      venue: json['venue'],
      mode: EventMode.values.firstWhere((e) => e.name == json['mode']),
      category: EventCategory.values.firstWhere((e) => e.name == json['category']),
      resources: List<String>.from(json['resources'] ?? []),
      imageUrl: json['imageUrl'],
      price: json['price']?.toDouble(),
      maxAttendees: json['maxAttendees'],
      currentAttendees: json['currentAttendees'] ?? 0,
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      meetingLink: json['meetingLink'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dateTime,
        venue,
        mode,
        category,
        resources,
        imageUrl,
        price,
        maxAttendees,
        currentAttendees,
        organizerId,
        organizerName,
        isActive,
        createdAt,
        updatedAt,
        tags,
        meetingLink,
        contactEmail,
        contactPhone,
      ];
}
