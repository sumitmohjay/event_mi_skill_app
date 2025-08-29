import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_model.dart';
import 'user_controller.dart';
import 'add_user_dialog.dart';
import 'role_change_dialog.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserController _userController = UserController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _userController.initializeAllDemoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: const Color(0xFF636E72),
          indicatorColor: const Color(0xFF8B5CF6),
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Registrations'),
            Tab(text: 'Roles'),
            Tab(text: 'Assignments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildRegistrationsTab(),
          _buildRolesTab(),
          _buildAssignmentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        // Users list
        Expanded(
          child: AnimatedBuilder(
            animation: _userController,
            builder: (context, child) {
              if (_userController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = _searchController.text.isEmpty
                  ? _userController.users
                  : _userController.searchUsers(_searchController.text);

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              child: Text(
                user.firstName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'role', child: Text('Change Role')),
                const PopupMenuItem(value: 'assign', child: Text('Assign')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationsTab() {
    return AnimatedBuilder(
      animation: _userController,
      builder: (context, child) {
        if (_userController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingRegistrations = _userController.getPendingRegistrations();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingRegistrations.length,
          itemBuilder: (context, index) {
            final registration = pendingRegistrations[index];
            return _buildRegistrationCard(registration);
          },
        );
      },
    );
  }

  Widget _buildRegistrationCard(UserRegistration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registration Request',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PENDING',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${registration.userId}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
            ),
            Text(
              'Event ID: ${registration.eventId}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRegistration(registration.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectRegistration(registration.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FutureBuilder<Map<String, int>>(
            future: _userController.getUserStatistics(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildStatsCard('Role Distribution', snapshot.data!);
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: UserRole.values.map((role) {
                final users = _userController.getUsersByRole(role);
                return _buildRoleCard(role, users.length);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(UserRole role, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getRoleIcon(role),
              size: 40,
              color: _getRoleColor(role),
            ),
            const SizedBox(height: 8),
            Text(
              role.name.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count users',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    return const Center(
      child: Text('Assignments management coming soon...'),
    );
  }

  Widget _buildStatsCard(String title, Map<String, int> stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            ...stats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.learner:
        return Colors.blue;
      case UserRole.instructor:
        return Colors.green;
      case UserRole.organizer:
        return Colors.orange;
      case UserRole.admin:
        return Colors.red;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.learner:
        return Icons.school;
      case UserRole.instructor:
        return Icons.person_outline;
      case UserRole.organizer:
        return Icons.event;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  // Action handlers
  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'role':
        _showChangeRoleDialog(user);
        break;
      case 'assign':
        _showAssignDialog(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(userController: _userController),
    );
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        userController: _userController,
        userToEdit: user,
      ),
    );
  }

  void _showChangeRoleDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => RoleChangeDialog(
        user: user,
        userController: _userController,
      ),
    );
  }

  void _showAssignDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign User'),
        content: Text('Assignment dialog for ${user.fullName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _userController.deleteUser(user.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _approveRegistration(String registrationId) {
    _userController.approveRegistration(registrationId, 'admin');
  }

  void _rejectRegistration(String registrationId) {
    _userController.rejectRegistration(registrationId, 'admin');
  }
}
