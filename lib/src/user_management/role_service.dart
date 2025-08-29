import 'user_model.dart';

class RoleService {
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  // In-memory storage for demo purposes
  final List<Map<String, dynamic>> _roleHistory = [];
  final Map<UserRole, List<String>> _rolePermissions = {
    UserRole.learner: ['view_events', 'register_events', 'view_profile'],
    UserRole.instructor: ['view_events', 'register_events', 'view_profile', 'create_courses', 'manage_courses'],
    UserRole.organizer: ['view_events', 'register_events', 'view_profile', 'create_events', 'manage_events', 'view_registrations'],
    UserRole.admin: ['all_permissions'],
  };

  // Role Management
  Future<void> changeUserRole(String userId, UserRole newRole, String changedBy, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _logRoleAction('ROLE_CHANGE', userId, 'Role changed to ${newRole.name} by $changedBy', reason);
  }

  Future<List<String>> getUserPermissions(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (role == UserRole.admin) {
      // Admin has all permissions
      return [
        'view_events', 'register_events', 'view_profile', 'create_courses', 
        'manage_courses', 'create_events', 'manage_events', 'view_registrations',
        'manage_users', 'manage_roles', 'view_analytics', 'system_admin'
      ];
    }
    
    return _rolePermissions[role] ?? [];
  }

  Future<bool> hasPermission(UserRole role, String permission) async {
    await Future.delayed(const Duration(milliseconds: 30));
    
    if (role == UserRole.admin) return true;
    
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  Future<List<UserRole>> getAvailableRoles() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return UserRole.values;
  }

  Future<Map<String, String>> getRoleDescriptions() async {
    await Future.delayed(const Duration(milliseconds: 30));
    
    return {
      UserRole.learner.name: 'Can view and register for events, manage personal profile',
      UserRole.instructor.name: 'Can create and manage courses, plus all learner permissions',
      UserRole.organizer.name: 'Can create and manage events, view registrations, plus all learner permissions',
      UserRole.admin.name: 'Full system access including user management and system administration',
    };
  }

  // Role Statistics
  Future<Map<String, int>> getRoleStatistics(List<Map<String, dynamic>> users) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final stats = <String, int>{};
    for (final role in UserRole.values) {
      stats[role.name] = users.where((u) => u['role'] == role.name).length;
    }
    
    return stats;
  }

  Future<List<Map<String, dynamic>>> getRoleDistribution(List<Map<String, dynamic>> users) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final total = users.length;
    if (total == 0) return [];
    
    final distribution = <Map<String, dynamic>>[];
    for (final role in UserRole.values) {
      final count = users.where((u) => u['role'] == role.name).length;
      final percentage = (count / total * 100).round();
      
      distribution.add({
        'role': role.name,
        'count': count,
        'percentage': percentage,
      });
    }
    
    return distribution;
  }

  // Role Validation
  Future<bool> canChangeRole(UserRole currentRole, UserRole newRole, UserRole changerRole) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Admin can change any role
    if (changerRole == UserRole.admin) return true;
    
    // Organizers can promote learners to instructors
    if (changerRole == UserRole.organizer && 
        currentRole == UserRole.learner && 
        newRole == UserRole.instructor) {
      return true;
    }
    
    // Users cannot change their own role to admin
    if (newRole == UserRole.admin) return false;
    
    return false;
  }

  Future<List<UserRole>> getPromotableRoles(UserRole currentRole, UserRole changerRole) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final promotableRoles = <UserRole>[];
    
    for (final role in UserRole.values) {
      if (role != currentRole && await canChangeRole(currentRole, role, changerRole)) {
        promotableRoles.add(role);
      }
    }
    
    return promotableRoles;
  }

  // Role History and Audit
  Future<List<Map<String, dynamic>>> getRoleHistory({String? userId, int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    var history = _roleHistory.toList();
    
    if (userId != null) {
      history = history.where((h) => h['userId'] == userId).toList();
    }
    
    // Sort by timestamp (most recent first)
    history.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    if (limit != null && limit > 0) {
      history = history.take(limit).toList();
    }
    
    return history;
  }

  Future<Map<String, dynamic>> getRoleChangeStats({int days = 30}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentChanges = _roleHistory.where((h) => 
        (h['timestamp'] as DateTime).isAfter(cutoffDate) && 
        h['action'] == 'ROLE_CHANGE').toList();
    
    final stats = <String, int>{};
    for (final change in recentChanges) {
      final description = change['description'] as String;
      final roleMatch = RegExp(r'Role changed to (\w+)').firstMatch(description);
      if (roleMatch != null) {
        final role = roleMatch.group(1)!;
        stats[role] = (stats[role] ?? 0) + 1;
      }
    }
    
    return {
      'totalChanges': recentChanges.length,
      'roleDistribution': stats,
      'period': days,
    };
  }

  // Utility Methods
  Future<String> getRoleDisplayName(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 10));
    
    switch (role) {
      case UserRole.learner:
        return 'Learner';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.organizer:
        return 'Event Organizer';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  Future<int> getRoleLevel(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 10));
    
    switch (role) {
      case UserRole.learner:
        return 1;
      case UserRole.instructor:
        return 2;
      case UserRole.organizer:
        return 3;
      case UserRole.admin:
        return 4;
    }
  }

  Future<bool> isHigherRole(UserRole role1, UserRole role2) async {
    final level1 = await getRoleLevel(role1);
    final level2 = await getRoleLevel(role2);
    return level1 > level2;
  }

  // Permission Management
  Future<void> addPermissionToRole(UserRole role, String permission) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (role == UserRole.admin) return; // Admin already has all permissions
    
    _rolePermissions[role] ??= [];
    if (!_rolePermissions[role]!.contains(permission)) {
      _rolePermissions[role]!.add(permission);
      _logRoleAction('PERMISSION_ADD', role.name, 'Added permission: $permission');
    }
  }

  Future<void> removePermissionFromRole(UserRole role, String permission) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (role == UserRole.admin) return; // Cannot remove permissions from admin
    
    _rolePermissions[role]?.remove(permission);
    _logRoleAction('PERMISSION_REMOVE', role.name, 'Removed permission: $permission');
  }

  // Private helper methods
  void _logRoleAction(String action, String targetId, String description, [String? reason]) {
    _roleHistory.add({
      'action': action,
      'userId': targetId,
      'description': description,
      'reason': reason,
      'timestamp': DateTime.now(),
      'performedBy': 'system', // In real app, this would be current user
    });
  }

  // Demo data initialization
  Future<void> initializeDemoData() async {
    if (_roleHistory.isNotEmpty) return;

    // Add some demo role change history
    _logRoleAction('ROLE_CHANGE', '2', 'Role changed to instructor by admin', 'Promoted due to excellent performance');
    _logRoleAction('ROLE_CHANGE', '3', 'Role changed to organizer by admin', 'Assigned to manage events');
    _logRoleAction('INIT', 'system', 'Demo role data initialized');
  }

  // Clear all data (for testing)
  void clearAllData() {
    _roleHistory.clear();
    // Reset to default permissions
    _rolePermissions.clear();
    _rolePermissions.addAll({
      UserRole.learner: ['view_events', 'register_events', 'view_profile'],
      UserRole.instructor: ['view_events', 'register_events', 'view_profile', 'create_courses', 'manage_courses'],
      UserRole.organizer: ['view_events', 'register_events', 'view_profile', 'create_events', 'manage_events', 'view_registrations'],
      UserRole.admin: ['all_permissions'],
    });
  }
}
