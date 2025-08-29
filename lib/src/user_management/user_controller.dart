import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_service.dart';
import 'registration_service.dart';
import 'role_service.dart';
import 'assignment_service.dart';

class UserController extends ChangeNotifier {
  final UserService _userService = UserService();
  final RegistrationService _registrationService = RegistrationService();
  final RoleService _roleService = RoleService();
  final AssignmentService _assignmentService = AssignmentService();

  // State management
  bool _isLoading = false;
  String? _error;
  List<User> _users = [];
  List<UserRegistration> _registrations = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> get users => List.from(_users);
  List<UserRegistration> get registrations => List.from(_registrations);

  // User Management
  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      await _userService.initializeDemoData();
      _users = await _userService.getAllUsers();
      _clearError();
    } catch (e) {
      _setError('Failed to load users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addUser(User user) async {
    _setLoading(true);
    try {
      await _userService.addUser(user);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to add user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    _setLoading(true);
    try {
      await _userService.updateUser(user);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to update user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeUser(String userId) async {
    _setLoading(true);
    try {
      await _userService.removeUser(userId);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to remove user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    try {
      await _userService.deleteUser(userId);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to delete user: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;
    
    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.firstName.toLowerCase().contains(lowerQuery) ||
             user.lastName.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery) ||
             user.fullName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<User> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Registration Management
  Future<void> loadRegistrations() async {
    _setLoading(true);
    try {
      await _registrationService.initializeDemoData();
      _registrations = await _registrationService.getAllRegistrations();
      _clearError();
    } catch (e) {
      _setError('Failed to load registrations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveRegistration(String registrationId, String approvedBy) async {
    try {
      await _registrationService.approveRegistration(registrationId, approvedBy);
      await loadRegistrations(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to approve registration: $e');
      rethrow;
    }
  }

  Future<void> rejectRegistration(String registrationId, String rejectedBy, {String? reason}) async {
    try {
      await _registrationService.rejectRegistration(registrationId, rejectedBy, reason: reason);
      await loadRegistrations(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to reject registration: $e');
      rethrow;
    }
  }

  List<UserRegistration> getPendingRegistrations() {
    return _registrations.where((reg) => reg.status == RegistrationStatus.pending).toList();
  }

  List<UserRegistration> getRegistrationsByStatus(RegistrationStatus status) {
    return _registrations.where((reg) => reg.status == status).toList();
  }

  // Role Management
  Future<void> changeUserRole(String userId, UserRole newRole, String changedBy, [String? reason]) async {
    _setLoading(true);
    try {
      // Find the user
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex == -1) {
        throw Exception('User not found');
      }

      final user = _users[userIndex];
      final updatedUser = user.copyWith(
        role: newRole,
        updatedAt: DateTime.now(),
      );

      await _userService.updateUser(updatedUser);
      await _roleService.changeUserRole(userId, newRole, changedBy, reason: reason);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to change user role: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getUserPermissions(UserRole role) async {
    return await _roleService.getUserPermissions(role);
  }

  Future<bool> hasPermission(UserRole role, String permission) async {
    return await _roleService.hasPermission(role, permission);
  }

  // Assignment Management
  Future<void> assignUserToEvent(String userId, String eventId, String assignedBy, {String? role}) async {
    try {
      await _assignmentService.assignUserToEvent(userId, eventId, assignedBy, role: role);
      _clearError();
    } catch (e) {
      _setError('Failed to assign user to event: $e');
      rethrow;
    }
  }

  Future<void> assignUserToCourse(String userId, String courseId, String assignedBy, {String? role}) async {
    try {
      await _assignmentService.assignUserToCourse(userId, courseId, assignedBy, role: role);
      _clearError();
    } catch (e) {
      _setError('Failed to assign user to course: $e');
      rethrow;
    }
  }

  Future<void> assignUserToGroup(String userId, String groupId, String assignedBy, {String? role}) async {
    try {
      await _assignmentService.assignUserToGroup(userId, groupId, assignedBy, role: role);
      _clearError();
    } catch (e) {
      _setError('Failed to assign user to group: $e');
      rethrow;
    }
  }

  Future<void> removeUserFromEvent(String userId, String eventId, String removedBy, {String? reason}) async {
    try {
      await _assignmentService.removeUserFromEvent(userId, eventId, removedBy, reason: reason);
      _clearError();
    } catch (e) {
      _setError('Failed to remove user from event: $e');
      rethrow;
    }
  }

  // Statistics and Analytics
  Future<Map<String, int>> getUserStatistics() async {
    return await _userService.getUserStatistics();
  }

  Future<Map<String, int>> getRegistrationStatistics() async {
    return await _registrationService.getRegistrationStatistics();
  }

  Future<Map<String, int>> getAssignmentStatistics() async {
    return await _assignmentService.getAssignmentStatistics();
  }

  // Utility methods
  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    return await _userService.isEmailAvailable(email);
  }

  // Bulk operations
  Future<void> bulkAddUsers(List<User> users) async {
    _setLoading(true);
    try {
      await _userService.bulkAddUsers(users);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to bulk add users: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bulkUpdateUserRoles(List<String> userIds, UserRole newRole) async {
    _setLoading(true);
    try {
      await _userService.bulkUpdateUserRoles(userIds, newRole);
      await loadUsers(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to bulk update user roles: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bulkApproveRegistrations(List<String> registrationIds, String approvedBy) async {
    try {
      await _registrationService.bulkApproveRegistrations(registrationIds, approvedBy);
      await loadRegistrations(); // Refresh the list
      _clearError();
    } catch (e) {
      _setError('Failed to bulk approve registrations: $e');
      rethrow;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize all services with demo data
  Future<void> initializeAllDemoData() async {
    _setLoading(true);
    try {
      await _userService.initializeDemoData();
      await _registrationService.initializeDemoData();
      await _roleService.initializeDemoData();
      await _assignmentService.initializeDemoData();
      
      await loadUsers();
      await loadRegistrations();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize demo data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear all data (for testing)
  void clearAllData() {
    _userService.clearAllData();
    _registrationService.clearAllData();
    _roleService.clearAllData();
    _assignmentService.clearAllData();
    
    _users.clear();
    _registrations.clear();
    _clearError();
    notifyListeners();
  }
}
