enum UserRole {
  learner,
  instructor,
  organizer,
  admin,
}

enum RegistrationStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role.name,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserRegistration {
  final String id;
  final String userId;
  final String eventId;
  final String? courseId;
  final String? groupId;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final Map<String, dynamic>? metadata;

  UserRegistration({
    required this.id,
    required this.userId,
    required this.eventId,
    this.courseId,
    this.groupId,
    this.status = RegistrationStatus.pending,
    required this.registeredAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.metadata,
  });

  UserRegistration copyWith({
    String? id,
    String? userId,
    String? eventId,
    String? courseId,
    String? groupId,
    RegistrationStatus? status,
    DateTime? registeredAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
  }) {
    return UserRegistration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      courseId: courseId ?? this.courseId,
      groupId: groupId ?? this.groupId,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'courseId': courseId,
      'groupId': groupId,
      'status': status.name,
      'registeredAt': registeredAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'metadata': metadata,
    };
  }

  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      courseId: json['courseId'] as String?,
      groupId: json['groupId'] as String?,
      status: RegistrationStatus.values.firstWhere((e) => e.name == json['status']),
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
