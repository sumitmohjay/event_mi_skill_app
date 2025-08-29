
class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  factory AssignmentService() => _instance;
  AssignmentService._internal();

  // In-memory storage for demo purposes
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _assignmentHistory = [];

  // Assignment Management
  Future<void> assignUserToEvent(String userId, String eventId, String assignedBy, {String? role, Map<String, dynamic>? metadata}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if assignment already exists
    final existingAssignment = _assignments.where((a) =>
        a['userId'] == userId &&
        a['eventId'] == eventId &&
        a['type'] == 'event' &&
        a['isActive'] == true).toList();

    if (existingAssignment.isNotEmpty) {
      throw Exception('User is already assigned to this event');
    }

    final assignment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'eventId': eventId,
      'type': 'event',
      'role': role,
      'assignedBy': assignedBy,
      'assignedAt': DateTime.now(),
      'isActive': true,
      'metadata': metadata,
    };

    _assignments.add(assignment);
    _logAssignmentAction('ASSIGN_EVENT', assignment['id'] as String, 'User $userId assigned to event $eventId by $assignedBy');
  }

  Future<void> assignUserToCourse(String userId, String courseId, String assignedBy, {String? role, Map<String, dynamic>? metadata}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final existingAssignment = _assignments.where((a) =>
        a['userId'] == userId &&
        a['courseId'] == courseId &&
        a['type'] == 'course' &&
        a['isActive'] == true).toList();

    if (existingAssignment.isNotEmpty) {
      throw Exception('User is already assigned to this course');
    }

    final assignment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'courseId': courseId,
      'type': 'course',
      'role': role,
      'assignedBy': assignedBy,
      'assignedAt': DateTime.now(),
      'isActive': true,
      'metadata': metadata,
    };

    _assignments.add(assignment);
    _logAssignmentAction('ASSIGN_COURSE', assignment['id'] as String, 'User $userId assigned to course $courseId by $assignedBy');
  }

  Future<void> assignUserToGroup(String userId, String groupId, String assignedBy, {String? role, Map<String, dynamic>? metadata}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final existingAssignment = _assignments.where((a) =>
        a['userId'] == userId &&
        a['groupId'] == groupId &&
        a['type'] == 'group' &&
        a['isActive'] == true).toList();

    if (existingAssignment.isNotEmpty) {
      throw Exception('User is already assigned to this group');
    }

    final assignment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'groupId': groupId,
      'type': 'group',
      'role': role,
      'assignedBy': assignedBy,
      'assignedAt': DateTime.now(),
      'isActive': true,
      'metadata': metadata,
    };

    _assignments.add(assignment);
    _logAssignmentAction('ASSIGN_GROUP', assignment['id'] as String, 'User $userId assigned to group $groupId by $assignedBy');
  }

  // Remove Assignments
  Future<void> removeAssignment(String assignmentId, String removedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _assignments.indexWhere((a) => a['id'] == assignmentId);
    if (index == -1) {
      throw Exception('Assignment not found');
    }

    _assignments[index]['isActive'] = false;
    _assignments[index]['removedBy'] = removedBy;
    _assignments[index]['removedAt'] = DateTime.now();
    _assignments[index]['removalReason'] = reason;

    _logAssignmentAction('REMOVE', assignmentId, 'Assignment removed by $removedBy', reason);
  }

  Future<void> removeUserFromEvent(String userId, String eventId, String removedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final assignments = _assignments.where((a) =>
        a['userId'] == userId &&
        a['eventId'] == eventId &&
        a['type'] == 'event' &&
        a['isActive'] == true).toList();

    for (final assignment in assignments) {
      await removeAssignment(assignment['id'], removedBy, reason: reason);
    }
  }

  Future<void> removeUserFromCourse(String userId, String courseId, String removedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final assignments = _assignments.where((a) =>
        a['userId'] == userId &&
        a['courseId'] == courseId &&
        a['type'] == 'course' &&
        a['isActive'] == true).toList();

    for (final assignment in assignments) {
      await removeAssignment(assignment['id'], removedBy, reason: reason);
    }
  }

  Future<void> removeUserFromGroup(String userId, String groupId, String removedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final assignments = _assignments.where((a) =>
        a['userId'] == userId &&
        a['groupId'] == groupId &&
        a['type'] == 'group' &&
        a['isActive'] == true).toList();

    for (final assignment in assignments) {
      await removeAssignment(assignment['id'], removedBy, reason: reason);
    }
  }

  // Query Methods
  Future<List<Map<String, dynamic>>> getUserAssignments(String userId, {bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _assignments.where((a) =>
        a['userId'] == userId &&
        (includeInactive || a['isActive'] == true)).toList();
  }

  Future<List<Map<String, dynamic>>> getEventAssignments(String eventId, {bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _assignments.where((a) =>
        a['eventId'] == eventId &&
        a['type'] == 'event' &&
        (includeInactive || a['isActive'] == true)).toList();
  }

  Future<List<Map<String, dynamic>>> getCourseAssignments(String courseId, {bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _assignments.where((a) =>
        a['courseId'] == courseId &&
        a['type'] == 'course' &&
        (includeInactive || a['isActive'] == true)).toList();
  }

  Future<List<Map<String, dynamic>>> getGroupAssignments(String groupId, {bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _assignments.where((a) =>
        a['groupId'] == groupId &&
        a['type'] == 'group' &&
        (includeInactive || a['isActive'] == true)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllAssignments({bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return _assignments.where((a) =>
        includeInactive || a['isActive'] == true).toList();
  }

  // Bulk Operations
  Future<void> bulkAssignUsersToEvent(List<String> userIds, String eventId, String assignedBy, {String? role}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    for (final userId in userIds) {
      try {
        await assignUserToEvent(userId, eventId, assignedBy, role: role);
      } catch (e) {
        // Continue with other assignments even if one fails
        _logAssignmentAction('BULK_ASSIGN_ERROR', 'bulk', 'Failed to assign user $userId to event $eventId: $e');
      }
    }

    _logAssignmentAction('BULK_ASSIGN_EVENT', 'bulk', 'Bulk assignment: ${userIds.length} users to event $eventId');
  }

  Future<void> bulkAssignUsersToCourse(List<String> userIds, String courseId, String assignedBy, {String? role}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    for (final userId in userIds) {
      try {
        await assignUserToCourse(userId, courseId, assignedBy, role: role);
      } catch (e) {
        _logAssignmentAction('BULK_ASSIGN_ERROR', 'bulk', 'Failed to assign user $userId to course $courseId: $e');
      }
    }

    _logAssignmentAction('BULK_ASSIGN_COURSE', 'bulk', 'Bulk assignment: ${userIds.length} users to course $courseId');
  }

  Future<void> bulkRemoveUsersFromEvent(List<String> userIds, String eventId, String removedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    for (final userId in userIds) {
      try {
        await removeUserFromEvent(userId, eventId, removedBy, reason: reason);
      } catch (e) {
        _logAssignmentAction('BULK_REMOVE_ERROR', 'bulk', 'Failed to remove user $userId from event $eventId: $e');
      }
    }

    _logAssignmentAction('BULK_REMOVE_EVENT', 'bulk', 'Bulk removal: ${userIds.length} users from event $eventId');
  }

  // Statistics
  Future<Map<String, int>> getAssignmentStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final activeAssignments = _assignments.where((a) => a['isActive'] == true);

    return {
      'total': activeAssignments.length,
      'events': activeAssignments.where((a) => a['type'] == 'event').length,
      'courses': activeAssignments.where((a) => a['type'] == 'course').length,
      'groups': activeAssignments.where((a) => a['type'] == 'group').length,
    };
  }

  Future<Map<String, int>> getUserAssignmentCounts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final userAssignments = _assignments.where((a) => a['userId'] == userId && a['isActive'] == true);

    return {
      'total': userAssignments.length,
      'events': userAssignments.where((a) => a['type'] == 'event').length,
      'courses': userAssignments.where((a) => a['type'] == 'course').length,
      'groups': userAssignments.where((a) => a['type'] == 'group').length,
    };
  }

  Future<List<Map<String, dynamic>>> getAssignmentTrends({int days = 30}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentAssignments = _assignments.where((a) => 
        (a['assignedAt'] as DateTime).isAfter(cutoffDate));

    final trends = <String, int>{};
    for (final assignment in recentAssignments) {
      final assignedAt = assignment['assignedAt'] as DateTime;
      final dateKey = '${assignedAt.year}-${assignedAt.month.toString().padLeft(2, '0')}-${assignedAt.day.toString().padLeft(2, '0')}';
      trends[dateKey] = (trends[dateKey] ?? 0) + 1;
    }

    return trends.entries.map((e) => {'date': e.key, 'count': e.value}).toList();
  }

  // Utility Methods
  Future<bool> isUserAssignedToEvent(String userId, String eventId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    return _assignments.any((a) =>
        a['userId'] == userId &&
        a['eventId'] == eventId &&
        a['type'] == 'event' &&
        a['isActive'] == true);
  }

  Future<bool> isUserAssignedToCourse(String userId, String courseId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    return _assignments.any((a) =>
        a['userId'] == userId &&
        a['courseId'] == courseId &&
        a['type'] == 'course' &&
        a['isActive'] == true);
  }

  Future<bool> isUserAssignedToGroup(String userId, String groupId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    return _assignments.any((a) =>
        a['userId'] == userId &&
        a['groupId'] == groupId &&
        a['type'] == 'group' &&
        a['isActive'] == true);
  }

  Future<List<Map<String, dynamic>>> getRecentAssignments({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final sortedAssignments = _assignments.where((a) => a['isActive'] == true).toList()
      ..sort((a, b) => (b['assignedAt'] as DateTime).compareTo(a['assignedAt'] as DateTime));

    return sortedAssignments.take(limit).toList();
  }

  // History and Audit
  List<Map<String, dynamic>> getAssignmentHistory() {
    return List.from(_assignmentHistory);
  }

  void _logAssignmentAction(String action, String assignmentId, String description, [String? reason]) {
    _assignmentHistory.add({
      'action': action,
      'assignmentId': assignmentId,
      'description': description,
      'reason': reason,
      'timestamp': DateTime.now(),
      'performedBy': 'system', // In real app, this would be current user
    });
  }

  // Demo data initialization
  Future<void> initializeDemoData() async {
    if (_assignments.isNotEmpty) return;

    final demoAssignments = [
      {
        'id': '1',
        'userId': '1',
        'eventId': 'event_1',
        'type': 'event',
        'role': 'participant',
        'assignedBy': 'admin',
        'assignedAt': DateTime.now().subtract(const Duration(days: 10)),
        'isActive': true,
      },
      {
        'id': '2',
        'userId': '2',
        'eventId': 'event_1',
        'type': 'event',
        'role': 'instructor',
        'assignedBy': 'admin',
        'assignedAt': DateTime.now().subtract(const Duration(days: 8)),
        'isActive': true,
      },
      {
        'id': '3',
        'userId': '1',
        'courseId': 'course_1',
        'type': 'course',
        'role': 'student',
        'assignedBy': 'admin',
        'assignedAt': DateTime.now().subtract(const Duration(days: 5)),
        'isActive': true,
      },
    ];

    _assignments.addAll(demoAssignments);
    _logAssignmentAction('INIT', 'system', 'Demo assignment data initialized');
  }

  // Clear all data (for testing)
  void clearAllData() {
    _assignments.clear();
    _assignmentHistory.clear();
  }
}
