import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../event_management/event_management_page.dart';
import '../../reporting_analytics/reporting_analytics_page.dart';

class EventOrganizerProfilePage extends StatefulWidget {
  const EventOrganizerProfilePage({super.key});

  @override
  State<EventOrganizerProfilePage> createState() => _EventOrganizerProfilePageState();
}

class _EventOrganizerProfilePageState extends State<EventOrganizerProfilePage> {
  // Controllers for editing
  // Text controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  // late TextEditingController _collegeController;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _imageUrl;
  // Stats loading state - now using provider
  bool isLoadingStats = false;
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
    // _collegeController = TextEditingController();

    // Load user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      profileProvider.loadUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    // _collegeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        // Update controllers when profile data changes
        if (!_isEditing) {
          final user = profileProvider.user;
          if (user != null) {
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phoneNumber;
            _bioController.text = user.bio;
            _addressController.text = user.address;
            // _collegeController.text = user.college;
          }
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, profileProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profileProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (profileProvider.errorMessage != null)
                        _buildErrorWidget(profileProvider)
                      else
                        _buildProfileCard(context, profileProvider),
                      const SizedBox(height: 20),
                      _buildMenuOptions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(UserProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: GoogleFonts.poppins(
              color: Colors.red[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileProvider.errorMessage ?? 'Unknown error',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => profileProvider.refreshProfile(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, UserProfileProvider profileProvider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: const Color(0xFF6C63FF),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the collapse ratio
            final double collapseRatio = 
                (200.0 - constraints.maxHeight) / (200.0 - kToolbarHeight);
            
            // Only show title when collapsed (scrolled)
            return AnimatedOpacity(
              opacity: collapseRatio > 0.5 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            );
          },
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF4A3FDB),
                  ],
                ),
              ),
            ),
            // Profile info
            if (profileProvider.user != null) _buildProfileHeader(profileProvider.user!),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imageUrl != null 
                            ? NetworkImage(_imageUrl!) 
                            : (user.avatar != null 
                                ? NetworkImage(user.avatar!) 
                                : null),
                        child: (_imageUrl == null && user.avatar == null)
                            ? const Icon(Icons.person, size: 45, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (user.college.isNotEmpty)
                        Text(
                          user.college,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfileProvider profileProvider) {
    final user = profileProvider.user;
    if (user == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Profile Information',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const Spacer(),
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _nameController.text = user.name;
                      _phoneController.text = user.phoneNumber;
                      _bioController.text = user.bio;
                      _addressController.text = user.address;
                      // _collegeController.text = user.college ?? '';
                    });
                  },
                  icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!_isEditing) ...[
            _buildProfileField(Icons.person, 'Name', user.name, _nameController),
            if (user.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildProfileField(Icons.phone_outlined, 'Phone', user.phoneNumber, _phoneController),
            ],
          ] else ...[
            _buildProfileField(Icons.person, 'Name', user.name, _nameController),
            const SizedBox(height: 16),
            _buildProfileField(Icons.info_outline, 'Bio', user.bio, _bioController),
            const SizedBox(height: 16),
            _buildProfileField(Icons.phone_outlined, 'Phone', user.phoneNumber ?? '', _phoneController),
            const SizedBox(height: 16),
            _buildProfileField(Icons.location_on_outlined, 'Address', user.address, _addressController),
          ],
          const SizedBox(height: 16),
          // _buildProfileField(Icons.school_outlined, 'College', user.college ?? '', _collegeController),
          if (_isEditing) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _cancelEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value, TextEditingController controller, {bool isReadOnly = false}) {
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEditing ? Colors.grey[50] : Colors.grey[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isEditing)
                  TextFormField(
                    controller: controller,
                    enabled: !isReadOnly,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isReadOnly ? Colors.grey[500] : const Color(0xFF2D3748),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: _getHintText(label),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                else
                  Text(
                    value.isEmpty ? 'Not provided' : value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty ? Colors.grey[400] : const Color(0xFF2D3748),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: label == 'Bio' ? 3 : 1,
                  ),
              ],
            ),
          ),
          if (!_isEditing)
            Icon(Icons.edit_outlined, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }

  String _getHintText(String label) {
    switch (label) {
      case 'Name':
        return 'Enter your full name';
      case 'Bio':
        return 'Tell us about yourself';
      case 'Phone':
        return 'Enter your phone number';
      case 'Address':
        return 'Enter your address';
      default:
        return 'Enter $label';
    }
  }

  Widget _buildMenuOptions(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.event_note,
        'title': 'Event Management',
        'subtitle': 'Create, edit and manage your events',
        'color': Colors.blue,
        'onTap': () => _navigateToEventManagement(context),
      },
      // {
      //   'icon': Icons.notifications,
      //   'title': 'Add Notification',
      //   'subtitle': 'Create and manage notifications',
      //   'color': Colors.red,
      //   'onTap': () => _navigateToNotificationManagement(context),
      // },
      {
        'icon': Icons.analytics,
        'title': 'Reporting & Analytics',
        'subtitle': 'View and export event reports',
        'color': Colors.purple,
        'onTap': () => _navigateToReportingAnalytics(context),
      },
      {
        'icon': Icons.logout,
        'title': 'Logout',
        'subtitle': 'Sign out from your account',
        'color': Colors.red,
        'onTap': () => _showLogoutDialog(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organizer Tools',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        ...menuItems.map(
          (item) => _buildMenuItem(
            context,
            item['icon'] as IconData,
            item['title'] as String,
            item['subtitle'] as String,
            item['color'] as Color,
            item['onTap'] as VoidCallback,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }



  void _navigateToEventManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventManagementPage(),
      ),
    );
  }

  void _navigateToNotificationManagement(BuildContext context) {
    // TODO: Implement navigation to notification management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification Management')),
    );
  }

  void _navigateToReportingAnalytics(BuildContext context) {
   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportingAnalyticsPage(),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _isSaving = true;
      });

      if (kIsWeb) {
        // Web platform - use html package (will be imported conditionally)
        await _pickImageWeb();
      } else {
        // Mobile/Desktop platform - use image_picker
        await _pickImageMobile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickImageMobile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      final profileProvider = context.read<UserProfileProvider>();
      final String? imageUrl = await profileProvider.uploadProfileImageBytes(
        imageBytes, 
        image.name,
      );
      
      if (imageUrl != null) {
        setState(() {
          _imageUrl = imageUrl;
        });
        
        // Update profile with new avatar
        final success = await profileProvider.updateProfile(avatar: imageUrl);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImageWeb() async {
    // This will only be called on web, where dart:html is available
    // For now, show a message that web upload is not implemented
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Web image upload not implemented yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final profileProvider = context.read<UserProfileProvider>();
      
      // Call the API to update profile with editable fields only
      final success = await profileProvider.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        avatar: _imageUrl,
      );
      
      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    final profileProvider = context.read<UserProfileProvider>();
    final user = profileProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber;
      _bioController.text = user.bio;
      _addressController.text = user.address;
    }
    
    setState(() {
      _isEditing = false;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to logout? You will need to sign in again.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call AuthService logout to properly clear tokens and invalidate session
      final authService = context.read<UserProfileProvider>();
      // Clear user profile provider data first
      authService.clearProfile();

      // Clear ALL stored data including access tokens, refresh tokens, user data, and any cached session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This ensures complete cleanup - no token reuse possible

      // Additional cleanup to ensure no authentication state remains
      await prefs.remove('access_token');
      await prefs.remove('refresh_token'); 
      await prefs.remove('user_data');
      await prefs.remove('phone_number'); // Clear any cached phone number
      await prefs.remove('user_role'); // Clear any cached role
      await prefs.remove('login_timestamp'); // Clear any login session data

      // Navigate to login screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false, // Remove all previous routes - forces fresh login
        );
      }
    } catch (e) {
      // Handle logout error
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}