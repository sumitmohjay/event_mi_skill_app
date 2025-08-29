import 'user_model.dart';

class RegistrationService {
  static final RegistrationService _instance = RegistrationService._internal();
  factory RegistrationService() => _instance;
  RegistrationService._internal();

  // In-memory storage for demo purposes
  final List<UserRegistration> _registrations = [];
  final List<Map<String, dynamic>> _registrationHistory = [];

  // Registration Management
  Future<UserRegistration> createRegistration({
    required String userId,
    required String eventId,
    String? courseId,
    String? groupId,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if user is already registered for this event
    final existingRegistration = _registrations.where((r) =>
        r.userId == userId &&
        r.eventId == eventId &&
        r.status != RegistrationStatus.cancelled).toList();

    if (existingRegistration.isNotEmpty) {
      throw Exception('User is already registered for this event');
    }

    final registration = UserRegistration(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventId: eventId,
      courseId: courseId,
      groupId: groupId,
      registeredAt: DateTime.now(),
      metadata: metadata,
    );

    _registrations.add(registration);
    _logRegistrationAction('CREATE', registration.id, 'Registration created');
    return registration;
  }

  Future<void> approveRegistration(String registrationId, String approvedBy) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _registrations.indexWhere((r) => r.id == registrationId);
    if (index == -1) {
      throw Exception('Registration not found');
    }

    _registrations[index] = _registrations[index].copyWith(
      status: RegistrationStatus.approved,
      approvedAt: DateTime.now(),
      approvedBy: approvedBy,
    );

    _logRegistrationAction('APPROVE', registrationId, 'Registration approved by $approvedBy');
  }

  Future<void> rejectRegistration(String registrationId, String rejectedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _registrations.indexWhere((r) => r.id == registrationId);
    if (index == -1) {
      throw Exception('Registration not found');
    }

    _registrations[index] = _registrations[index].copyWith(
      status: RegistrationStatus.rejected,
      approvedBy: rejectedBy,
      rejectionReason: reason,
    );

    _logRegistrationAction('REJECT', registrationId, 'Registration rejected by $rejectedBy');
  }

  Future<void> cancelRegistration(String registrationId) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _registrations.indexWhere((r) => r.id == registrationId);
    if (index == -1) {
      throw Exception('Registration not found');
    }

    _registrations[index] = _registrations[index].copyWith(
      status: RegistrationStatus.cancelled,
    );

    _logRegistrationAction('CANCEL', registrationId, 'Registration cancelled');
  }

  // Query Methods
  Future<List<UserRegistration>> getRegistrationsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _registrations.where((r) => r.userId == userId).toList();
  }

  Future<List<UserRegistration>> getRegistrationsByEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _registrations.where((r) => r.eventId == eventId).toList();
  }

  Future<List<UserRegistration>> getRegistrationsByStatus(RegistrationStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _registrations.where((r) => r.status == status).toList();
  }

  Future<List<UserRegistration>> getPendingRegistrations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _registrations.where((r) => r.status == RegistrationStatus.pending).toList();
  }

  Future<UserRegistration?> getRegistrationById(String registrationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _registrations.firstWhere((r) => r.id == registrationId);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserRegistration>> getAllRegistrations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_registrations);
  }

  // Bulk Operations
  Future<void> bulkApproveRegistrations(List<String> registrationIds, String approvedBy) async {
    await Future.delayed(const Duration(milliseconds: 300));

    for (final id in registrationIds) {
      final index = _registrations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _registrations[index] = _registrations[index].copyWith(
          status: RegistrationStatus.approved,
          approvedAt: DateTime.now(),
          approvedBy: approvedBy,
        );
      }
    }

    _logRegistrationAction('BULK_APPROVE', 'multiple', 'Bulk approval: ${registrationIds.length} registrations');
  }

  Future<void> bulkRejectRegistrations(List<String> registrationIds, String rejectedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    for (final id in registrationIds) {
      final index = _registrations.indexWhere((r) => r.id == id);
      if (index != -1) {
        _registrations[index] = _registrations[index].copyWith(
          status: RegistrationStatus.rejected,
          approvedBy: rejectedBy,
          rejectionReason: reason,
        );
      }
    }

    _logRegistrationAction('BULK_REJECT', 'multiple', 'Bulk rejection: ${registrationIds.length} registrations');
  }

  // Statistics
  Future<Map<String, int>> getRegistrationStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return {
      'total': _registrations.length,
      'pending': _registrations.where((r) => r.status == RegistrationStatus.pending).length,
      'approved': _registrations.where((r) => r.status == RegistrationStatus.approved).length,
      'rejected': _registrations.where((r) => r.status == RegistrationStatus.rejected).length,
      'cancelled': _registrations.where((r) => r.status == RegistrationStatus.cancelled).length,
    };
  }

  Future<Map<String, int>> getEventRegistrationCounts(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final eventRegistrations = _registrations.where((r) => r.eventId == eventId);
    return {
      'total': eventRegistrations.length,
      'pending': eventRegistrations.where((r) => r.status == RegistrationStatus.pending).length,
      'approved': eventRegistrations.where((r) => r.status == RegistrationStatus.approved).length,
      'rejected': eventRegistrations.where((r) => r.status == RegistrationStatus.rejected).length,
      'cancelled': eventRegistrations.where((r) => r.status == RegistrationStatus.cancelled).length,
    };
  }

  Future<List<Map<String, dynamic>>> getRegistrationTrends({int days = 30}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentRegistrations = _registrations.where((r) => r.registeredAt.isAfter(cutoffDate));

    final trends = <String, int>{};
    for (final registration in recentRegistrations) {
      final dateKey = '${registration.registeredAt.year}-${registration.registeredAt.month.toString().padLeft(2, '0')}-${registration.registeredAt.day.toString().padLeft(2, '0')}';
      trends[dateKey] = (trends[dateKey] ?? 0) + 1;
    }

    return trends.entries.map((e) => {'date': e.key, 'count': e.value}).toList();
  }

  // Utility Methods
  Future<bool> isUserRegistered(String userId, String eventId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _registrations.any((r) =>
        r.userId == userId &&
        r.eventId == eventId &&
        (r.status == RegistrationStatus.approved || r.status == RegistrationStatus.pending));
  }

  Future<int> getApprovedRegistrationCount(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _registrations.where((r) =>
        r.eventId == eventId && r.status == RegistrationStatus.approved).length;
  }

  Future<List<UserRegistration>> getRecentRegistrations({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final sortedRegistrations = _registrations.toList()
      ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

    return sortedRegistrations.take(limit).toList();
  }

  // History and Audit
  List<Map<String, dynamic>> getRegistrationHistory() {
    return List.from(_registrationHistory);
  }

  void _logRegistrationAction(String action, String registrationId, String description) {
    _registrationHistory.add({
      'action': action,
      'registrationId': registrationId,
      'description': description,
      'timestamp': DateTime.now(),
      'performedBy': 'system', // In real app, this would be current user
    });
  }

  // Demo data initialization
  Future<void> initializeDemoData() async {
    if (_registrations.isNotEmpty) return;

    final demoRegistrations = [
      UserRegistration(
        id: '1',
        userId: '1',
        eventId: 'event_1',
        status: RegistrationStatus.pending,
        registeredAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      UserRegistration(
        id: '2',
        userId: '2',
        eventId: 'event_1',
        status: RegistrationStatus.approved,
        registeredAt: DateTime.now().subtract(const Duration(days: 4)),
        approvedAt: DateTime.now().subtract(const Duration(days: 3)),
        approvedBy: 'admin',
      ),
      UserRegistration(
        id: '3',
        userId: '3',
        eventId: 'event_2',
        status: RegistrationStatus.pending,
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    _registrations.addAll(demoRegistrations);
    _logRegistrationAction('INIT', 'system', 'Demo registration data initialized');
  }

  // Clear all data (for testing)
  void clearAllData() {
    _registrations.clear();
    _registrationHistory.clear();
  }
}
