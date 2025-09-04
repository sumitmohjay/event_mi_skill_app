import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/providers/user_profile_provider.dart';
import '../event_management/provider/event_provider.dart';
import '../event_management/event.dart';
import 'enrollment_api_service.dart';
import 'enrollment_provider.dart';
import 'enrollment_detail_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile();
      context.read<EventProvider>().loadAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'User Management',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Text(
                              'View and manage user profiles',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSearchBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Consumer<UserProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profileProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load user data',
                      style: GoogleFonts.poppins(
                        color: Colors.red[600],
                        fontSize: 16,
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.poppins(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: 'Search users...',
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.7),
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  // Widget _buildUserStats(UserProfileProvider profileProvider) {
  //   final user = profileProvider.user;
  //   if (user == null) return const SizedBox.shrink();

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     // child: Column(
  //     //   crossAxisAlignment: CrossAxisAlignment.start,
  //     //   children: [
  //     //     Text(
  //     //       'User Statistics',
  //     //       style: GoogleFonts.poppins(
  //     //         fontSize: 18,
  //     //         fontWeight: FontWeight.w600,
  //     //       ),
  //     //     ),
  //     //     const SizedBox(height: 15),
  //     //     Row(
  //     //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     //       children: [
  //     //         _buildStatCard('Events', '12', Colors.blue),
  //     //         _buildStatCard('Connections', '45', Colors.green),
  //     //         _buildStatCard('Groups', '5', Colors.orange),
  //     //       ],
  //     //     ),
  //     //   ],
  //     // ),
  //   );
  // }

  // Widget _buildStatCard(String title, String value, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           value,
  //           style: GoogleFonts.poppins(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: color,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           title,
  //           style: GoogleFonts.poppins(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEventsSection() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Events',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (eventProvider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              if (eventProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (eventProvider.errorMessage != null)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.red[300]),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load events',
                        style: GoogleFonts.poppins(
                          color: Colors.red[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => eventProvider.loadAllEvents(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (eventProvider.filteredEvents.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'No events available',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventProvider.filteredEvents.length > 5 
                      ? 5 
                      : eventProvider.filteredEvents.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = eventProvider.filteredEvents[index];
                    return _buildEventCard(event);
                  },
                ),
              if (eventProvider.filteredEvents.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      'Showing 5 of ${eventProvider.filteredEvents.length} events',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => _showEnrollmentDetails(event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category ?? EventCategory.other).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getCategoryDisplayName(event.category ?? EventCategory.other),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(event.category ?? EventCategory.other),
                  ),
                ),
              ),
              const Spacer(),
              if (event.dateTime != null)
                Text(
                  DateFormat('MMM dd, yyyy').format(event.dateTime!),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.location,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (event.mode != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getModeColor(event.mode!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getModeDisplayName(event.mode!),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getModeColor(event.mode!),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.academic:
        return Colors.blue;
      case EventCategory.cultural:
        return Colors.purple;
      case EventCategory.technical:
        return Colors.green;
      case EventCategory.workshop:
        return Colors.orange;
      case EventCategory.seminar:
        return Colors.red;
      case EventCategory.webinar:
        return Colors.teal;
      case EventCategory.conference:
        return Colors.indigo;
      case EventCategory.sports:
        return Colors.amber;
      case EventCategory.social:
        return Colors.pink;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(EventCategory category) {
    switch (category) {
      case EventCategory.academic:
        return 'Academic';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.technical:
        return 'Technical';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.webinar:
        return 'Webinar';
      case EventCategory.conference:
        return 'Conference';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.social:
        return 'Social';
      case EventCategory.other:
        return 'Other';
    }
  }

  Color _getModeColor(EventMode mode) {
    switch (mode) {
      case EventMode.online:
        return Colors.blue;
      case EventMode.offline:
        return Colors.green;
      case EventMode.hybrid:
        return Colors.orange;
    }
  }

  String _getModeDisplayName(EventMode mode) {
    switch (mode) {
      case EventMode.online:
        return 'Online';
      case EventMode.offline:
        return 'Offline';
      case EventMode.hybrid:
        return 'Hybrid';
    }
  }

  void _showEnrollmentDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEnrollmentBottomSheet(event),
    );
  }

  Widget _buildEnrollmentBottomSheet(Event event) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Event Enrollments',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Consumer<EnrollmentProvider>(
                  builder: (context, enrollmentProvider, child) {
                    // Load enrollments when sheet opens
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (enrollmentProvider.selectedEventId != event.id) {
                        enrollmentProvider.loadEventEnrollments(event.id);
                      }
                    });

                    return _buildEnrollmentContent(enrollmentProvider, scrollController);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnrollmentContent(EnrollmentProvider provider, ScrollController scrollController) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading enrollments...'),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load enrollments',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadEventEnrollments(provider.selectedEventId!),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.enrollments.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Show stats even when no enrollments
            if (provider.stats != null) ...[
              _buildEnrollmentStats(provider.stats!, provider.eventInfo),
              const SizedBox(height: 20),
            ],
            // Empty state
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No enrollments yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics
          if (provider.stats != null) _buildEnrollmentStats(provider.stats!, provider.eventInfo),
          const SizedBox(height: 20),
          // Enrollments list
          Text(
            'Enrolled Users (${provider.enrollments.length})',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.enrollments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final enrollment = provider.enrollments[index];
              return _buildEnrollmentCard(enrollment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentStats(EnrollmentStats stats, EventInfo? eventInfo) {
    final maxParticipants = eventInfo?.maxParticipants ?? 0;
    final availableSpots = maxParticipants > 0 ? maxParticipants - stats.totalEnrollments : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment Statistics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (eventInfo != null) ...[
            const SizedBox(height: 8),
            Text(
              '${eventInfo.title} (${eventInfo.category.toUpperCase()})',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Max Capacity: $maxParticipants participants',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', stats.totalEnrollments.toString(), Colors.blue),
              _buildStatItem('Approved', stats.approvedEnrollments.toString(), Colors.green),
              _buildStatItem('Pending', stats.pendingEnrollments.toString(), Colors.orange),
              _buildStatItem('Declined', stats.declinedEnrollments.toString(), Colors.red),
            ],
          ),
          if (maxParticipants > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: availableSpots > 0 ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    availableSpots > 0 ? Icons.event_seat : Icons.event_busy,
                    size: 16,
                    color: availableSpots > 0 ? Colors.green[700] : Colors.red[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    availableSpots > 0
                        ? '$availableSpots spots available'
                        : 'Event is full',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: availableSpots > 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment) {
    Color statusColor;
    IconData statusIcon;
    
    switch (enrollment.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return GestureDetector(
      onTap: () => _navigateToEnrollmentDetail(enrollment),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage: enrollment.userAvatar != null 
                  ? NetworkImage(enrollment.userAvatar!) 
                  : null,
              child: enrollment.userAvatar == null
                  ? Text(
                      enrollment.userName.isNotEmpty 
                          ? enrollment.userName[0].toUpperCase() 
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrollment.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enrollment.userEmail,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (enrollment.college != null && enrollment.college!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.school, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            enrollment.college!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (enrollment.phoneNumber != null && enrollment.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 10, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          enrollment.phoneNumber!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Requested: ${DateFormat('MMM dd, yyyy').format(enrollment.enrolledAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status and actions
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Three-dot menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  onSelected: (value) => _handleEnrollmentAction(enrollment, value),
                  itemBuilder: (context) => _buildMenuItems(enrollment.status),
                ),
                const SizedBox(height: 4),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        enrollment.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
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

  List<PopupMenuEntry<String>> _buildMenuItems(String currentStatus) {
    List<PopupMenuEntry<String>> items = [];
    
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        items.addAll([
          const PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text('Approve'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'decline',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Decline'),
              ],
            ),
          ),
        ]);
        break;
      case 'approved':
        items.add(
          const PopupMenuItem(
            value: 'decline',
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Decline'),
              ],
            ),
          ),
        );
        break;
      case 'declined':
        items.add(
          const PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text('Approve'),
              ],
            ),
          ),
        );
        break;
    }
    
    // Add view details option
    if (items.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }
    items.add(
      const PopupMenuItem(
        value: 'view_details',
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Text('View Details'),
          ],
        ),
      ),
    );
    
    return items;
  }

  Future<void> _handleEnrollmentAction(Enrollment enrollment, String action) async {
    switch (action) {
      case 'approve':
        await _updateEnrollmentStatus(enrollment, 'approved');
        break;
      case 'decline':
        await _updateEnrollmentStatus(enrollment, 'declined');
        break;
      case 'view_details':
        _navigateToEnrollmentDetail(enrollment);
        break;
    }
  }

  Future<void> _updateEnrollmentStatus(Enrollment enrollment, String newStatus) async {
    // Show confirmation dialog
    final confirmed = await _showStatusConfirmationDialog(enrollment, newStatus);
    if (!confirmed) return;

    try {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      await enrollmentProvider.updateEnrollmentStatus(
        enrollment.eventId,
        enrollment.id,
        newStatus,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${enrollment.userName} ${newStatus.toLowerCase()} successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update enrollment: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _showStatusConfirmationDialog(Enrollment enrollment, String action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          '${action == 'approved' ? 'Approve' : 'Decline'} Enrollment',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to ${action == 'approved' ? 'approve' : 'decline'} this enrollment?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      enrollment.userName.isNotEmpty 
                          ? enrollment.userName[0].toUpperCase() 
                          : 'U',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enrollment.userName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          enrollment.userEmail,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approved' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              action == 'approved' ? 'Approve' : 'Decline',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _navigateToEnrollmentDetail(Enrollment enrollment) async {
    // Get the event title from the current provider
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final eventTitle = enrollmentProvider.eventInfo?.title ?? 'Event';

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EnrollmentDetailPage(
          enrollment: enrollment,
          eventTitle: eventTitle,
        ),
      ),
    );

    // Refresh the enrollments list if status was updated
    if (result == true && enrollmentProvider.selectedEventId != null) {
      enrollmentProvider.loadEventEnrollments(enrollmentProvider.selectedEventId!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
