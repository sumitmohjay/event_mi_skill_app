import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'event.dart';
import 'provider/event_provider.dart';
import 'create_edit_event_page.dart';
import 'event_detail_page.dart';

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Event Management',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Create and manage your events',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
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
        body: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            if (eventProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (eventProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      eventProvider.errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.red[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => eventProvider.loadAllEvents(),
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
                  _buildCategoryFilter(eventProvider),
                  const SizedBox(height: 20),
                  _buildEventStats(eventProvider),
                  const SizedBox(height: 20),
                  _buildEventsList(eventProvider),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateEvent(),
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Event',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(fontSize: 14),
        onChanged: (value) {
          context.read<EventProvider>().searchEvents(value);
        },
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    context.read<EventProvider>().searchEvents('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(EventProvider eventProvider) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: EventCategory.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              'All',
              eventProvider.selectedCategory == null,
              () => eventProvider.filterByCategory(null),
              Colors.grey,
            );
          }
          
          final category = EventCategory.values[index - 1];
          final isSelected = eventProvider.selectedCategory == category;
          
          return _buildCategoryChip(
            eventProvider.getCategoryDisplayName(category),
            isSelected,
            () => eventProvider.filterByCategory(category),
            eventProvider.getCategoryColor(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEventStats(EventProvider eventProvider) {
    final totalEvents = eventProvider.events.length;
    final upcomingEvents = eventProvider.events
        .where((event) => event.dateTime.isAfter(DateTime.now()))
        .length;

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
          Text(
            'Event Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Events', totalEvents.toString(), Colors.blue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard('Upcoming', upcomingEvents.toString(), Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(EventProvider eventProvider) {
    final events = eventProvider.filteredEvents;

    if (events.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event to get started',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events (${events.length})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index], eventProvider);
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(Event event, EventProvider eventProvider) {
    final isUpcoming = event.dateTime.isAfter(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: InkWell(
        onTap: () => _navigateToEventDetail(event),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: eventProvider.getCategoryColor(event.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eventProvider.getCategoryDisplayName(event.category),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: eventProvider.getCategoryColor(event.category),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEventAction(value, event, eventProvider),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    child: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(event.dateTime),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    event.mode == EventMode.online ? Icons.videocam : Icons.location_on,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.venue,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUpcoming ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isUpcoming ? 'Upcoming' : 'Past',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isUpcoming ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEventAction(String action, Event event, EventProvider eventProvider) {
    switch (action) {
      case 'edit':
        _navigateToEditEvent(event);
        break;
      case 'delete':
        _showDeleteConfirmation(event, eventProvider);
        break;
    }
  }

  void _showDeleteConfirmation(Event event, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await eventProvider.deleteEvent(event.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Event deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditEventPage(),
      ),
    );
  }

  void _navigateToEditEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditEventPage(event: event),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailPage(event: event),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
