import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_model.dart';
import 'user_controller.dart';

class RoleChangeDialog extends StatefulWidget {
  final User user;
  final UserController userController;

  const RoleChangeDialog({
    super.key,
    required this.user,
    required this.userController,
  });

  @override
  State<RoleChangeDialog> createState() => _RoleChangeDialogState();
}

class _RoleChangeDialogState extends State<RoleChangeDialog> {
  late UserRole _selectedRole;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Change User Role',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E6ED)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    child: Text(
                      widget.user.firstName[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                        Text(
                          widget.user.email,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF636E72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Current Role
            Text(
              'Current Role',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getRoleColor(widget.user.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getRoleColor(widget.user.role).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(widget.user.role),
                    color: _getRoleColor(widget.user.role),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getRoleDisplayName(widget.user.role),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(widget.user.role),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // New Role Selection
            Text(
              'New Role',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserRole.values.map((role) {
                final isSelected = _selectedRole == role;
                final isCurrent = role == widget.user.role;
                
                return GestureDetector(
                  onTap: isCurrent ? null : () {
                    setState(() {
                      _selectedRole = role;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent 
                          ? Colors.grey.withValues(alpha: 0.1)
                          : isSelected 
                              ? _getRoleColor(role).withValues(alpha: 0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? Colors.grey.withValues(alpha: 0.3)
                            : isSelected
                                ? _getRoleColor(role)
                                : const Color(0xFFE0E6ED),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(role),
                          color: isCurrent 
                              ? Colors.grey
                              : isSelected 
                                  ? _getRoleColor(role)
                                  : const Color(0xFF636E72),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getRoleDisplayName(role),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isCurrent 
                                ? Colors.grey
                                : isSelected 
                                    ? _getRoleColor(role)
                                    : const Color(0xFF636E72),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Reason (Optional)
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for role change (Optional)',
                hintText: 'Provide a reason for this role change...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                labelStyle: GoogleFonts.poppins(
                  color: const Color(0xFF636E72),
                ),
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading || _selectedRole == widget.user.role 
                          ? null 
                          : _changeRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Change Role',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.learner:
        return 'Learner';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  Future<void> _changeRole() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.userController.changeUserRole(
        widget.user.id,
        _selectedRole,
        'admin',
        _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Role changed from ${_getRoleDisplayName(widget.user.role)} to ${_getRoleDisplayName(_selectedRole)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
