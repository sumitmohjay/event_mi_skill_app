import 'user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // In-memory storage for demo purposes
  final List<User> _users = [];
  final List<Map<String, dynamic>> _userHistory = [];

  // CRUD Operations
  Future<void> addUser(User user) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if user with same email already exists
    if (_users.any((u) => u.email == user.email)) {
      throw Exception('User with this email already exists');
    }
    
    _users.add(user);
    _logUserAction('CREATE', user.id, 'User created');
  }

  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      throw Exception('User not found');
    }
    
    _users[index] = user;
    _logUserAction('UPDATE', user.id, 'User updated');
  }

  Future<void> removeUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw Exception('User not found');
    }
    
    _users[index] = _users[index].copyWith(isActive: false);
    _logUserAction('DEACTIVATE', userId, 'User deactivated');
  }

  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final initialLength = _users.length;
    _users.removeWhere((u) => u.id == userId);
    if (_users.length == initialLength) {
      throw Exception('User not found');
    }
    
    _logUserAction('DELETE', userId, 'User permanently deleted');
  }

  Future<User?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getAllUsers({bool includeInactive = false}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (includeInactive) {
      return List.from(_users);
    }
    return _users.where((u) => u.isActive).toList();
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    return _users.where((u) => u.role == role && u.isActive).toList();
  }

  Future<List<User>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final lowerQuery = query.toLowerCase();
    return _users.where((u) {
      return u.isActive && (
        u.firstName.toLowerCase().contains(lowerQuery) ||
        u.lastName.toLowerCase().contains(lowerQuery) ||
        u.email.toLowerCase().contains(lowerQuery) ||
        u.fullName.toLowerCase().contains(lowerQuery)
      );
    }).toList();
  }

  // Statistics
  Future<Map<String, int>> getUserStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final activeUsers = _users.where((u) => u.isActive);
    return {
      'total': activeUsers.length,
      'learners': activeUsers.where((u) => u.role == UserRole.learner).length,
      'instructors': activeUsers.where((u) => u.role == UserRole.instructor).length,
      'organizers': activeUsers.where((u) => u.role == UserRole.organizer).length,
      'admins': activeUsers.where((u) => u.role == UserRole.admin).length,
    };
  }

  // Bulk operations
  Future<void> bulkAddUsers(List<User> users) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (final user in users) {
      if (_users.any((u) => u.email == user.email)) {
        throw Exception('Duplicate email found: ${user.email}');
      }
    }
    
    _users.addAll(users);
    _logUserAction('BULK_CREATE', 'multiple', 'Bulk user creation: ${users.length} users');
  }

  Future<void> bulkUpdateUserRoles(List<String> userIds, UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    for (final userId in userIds) {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          role: newRole,
          updatedAt: DateTime.now(),
        );
      }
    }
    
    _logUserAction('BULK_ROLE_UPDATE', 'multiple', 'Bulk role update: ${userIds.length} users to $newRole');
  }

  // User history and audit
  List<Map<String, dynamic>> getUserHistory() {
    return List.from(_userHistory);
  }

  void _logUserAction(String action, String userId, String description) {
    _userHistory.add({
      'action': action,
      'userId': userId,
      'description': description,
      'timestamp': DateTime.now(),
      'performedBy': 'system', // In real app, this would be current user
    });
  }

  // Utility methods
  Future<bool> isEmailAvailable(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return !_users.any((u) => u.email == email);
  }

  Future<int> getTotalUserCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _users.where((u) => u.isActive).length;
  }

  Future<List<User>> getRecentUsers({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final sortedUsers = _users.where((u) => u.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedUsers.take(limit).toList();
  }

  // Demo data initialization
  Future<void> initializeDemoData() async {
    if (_users.isNotEmpty) return;

    final demoUsers = [
      User(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        role: UserRole.learner,
        phoneNumber: '+1234567890',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      User(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        role: UserRole.instructor,
        phoneNumber: '+1234567891',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      User(
        id: '3',
        firstName: 'Mike',
        lastName: 'Johnson',
        email: 'mike.johnson@example.com',
        role: UserRole.organizer,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      User(
        id: '4',
        firstName: 'Sarah',
        lastName: 'Wilson',
        email: 'sarah.wilson@example.com',
        role: UserRole.admin,
        phoneNumber: '+1234567893',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];

    _users.addAll(demoUsers);
    _logUserAction('INIT', 'system', 'Demo data initialized');
  }

  // Clear all data (for testing)
  void clearAllData() {
    _users.clear();
    _userHistory.clear();
  }
}
