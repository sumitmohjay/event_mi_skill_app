import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'event_page.dart';
import '../../event_management/services/event_service.dart';
import '../../event_management/models/dashboard_response.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/dashboard_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  // API integration
  EventService? _eventService;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Dynamic data from API
  List<Map<String, dynamic>> _todayEvents = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _pastEvents = [];
  EventSummary? _summary;
  
  
  @override
  void initState() {
    super.initState();
    _initializeEventService();
  }

  Future<void> _initializeEventService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiClient = ApiClient(prefs);
      _eventService = EventService(apiClient);
      await _loadEvents();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (_eventService == null) return;
    
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    dashboardProvider.setLoading(true);

    try {
      final events = await _eventService!.getFormattedEvents();
      final summary = await _eventService!.getSummary();
      
      final todayEvents = events['today'] ?? [];
      final upcomingEvents = events['upcoming'] ?? [];
      final pastEvents = events['past'] ?? [];
      
      setState(() {
        _todayEvents = todayEvents;
        _upcomingEvents = upcomingEvents;
        _pastEvents = pastEvents;
        _summary = summary;
        _isLoading = false;
      });
      
      // Update the provider with the dashboard data
      dashboardProvider.updateDashboardData(
        summary: summary,
        todayEvents: todayEvents,
        upcomingEvents: upcomingEvents,
        pastEvents: pastEvents,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: $e';
        _isLoading = false;
      });
      dashboardProvider.setError('Failed to load events: $e');
    }
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading 
        ? _buildLoadingState()
        : _errorMessage != null 
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _refreshEvents,
              child: _buildResponsiveContent(),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading events...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading events',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEvents,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_summary == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Today', _summary!.todayCount.toString()),
          _buildSummaryItem('Upcoming', _summary!.upcomingCount.toString()),
          _buildSummaryItem('Past', _summary!.pastCount.toString()),
          _buildSummaryItem('Total', _summary!.totalActiveEvents.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }


  Widget _buildResponsiveContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradientHeader(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1, // 10% padding for better responsiveness
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                _buildSummaryCard(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildTodaySection(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                // _buildCreateEventSection(),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildUpcomingSection(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                _buildPastEventsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: double.infinity,
      height: screenHeight * 0.18, // Increased height for more spacing
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.1, // 10% left padding for better responsiveness
        MediaQuery.of(context).padding.top + screenHeight * 0.03, // Increased top padding
        screenWidth * 0.1, // 10% right padding
        screenHeight * 0.03 // Increased bottom padding
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center the title vertically
        children: [
          // Header with Discover Event title - left aligned
          Text(
            'Discover Event',
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(screenWidth, 32, 28, 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get responsive font sizes
  double _getResponsiveFontSize(double screenWidth, double webSize, double tabletSize, double mobileSize) {
    if (screenWidth > 900) return webSize;
    if (screenWidth > 600) return tabletSize;
    return mobileSize;
  }
  
  // Helper method to get responsive sizes
  double _getResponsiveSize(double screenWidth, double webSize, double tabletSize, double mobileSize) {
    if (screenWidth > 900) return webSize;
    if (screenWidth > 600) return tabletSize;
    return mobileSize;
  }

  // Widget _buildCreateEventSection() {
  //   final screenWidth = MediaQuery.of(context).size.width;
    
  //   return SizedBox(
  //     width: screenWidth * 0.8,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Create An Event',
  //           style: GoogleFonts.poppins(
  //             fontSize: _getResponsiveFontSize(screenWidth, 24, 20, 18),
  //             fontWeight: FontWeight.w600,
  //             color: const Color(0xFF2D3436),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Container(
  //           width: double.infinity,
  //           padding: EdgeInsets.all(_getResponsiveSize(screenWidth, 24, 20, 16)),
  //           decoration: BoxDecoration(
  //             gradient: const LinearGradient(
  //               colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], 
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             borderRadius: BorderRadius.circular(20),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
  //                 blurRadius: 15,
  //                 offset: const Offset(0, 8),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Create An Event',
  //                       style: GoogleFonts.poppins(
  //                         fontSize: _getResponsiveFontSize(screenWidth, 20, 18, 16),
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'New York, US',
  //                       style: GoogleFonts.poppins(
  //                         fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
  //                         color: Colors.white.withValues(alpha: 0.9),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 width: _getResponsiveSize(screenWidth, 60, 50, 45),
  //                 height: _getResponsiveSize(screenWidth, 60, 50, 45),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withValues(alpha: 0.2),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Icon(
  //                   Icons.add, 
  //                   color: Colors.white, 
  //                   size: _getResponsiveSize(screenWidth, 28, 24, 20)
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  Widget _buildTodaySection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = _getResponsiveSize(screenWidth, 220, 200, 180);
    
    return SizedBox(
      width: screenWidth * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 24, 20, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(
                        events: _todayEvents,
                        eventType: 'Today',
                      ),
                    ),
                  );
                },
                child: Text(
                  'View more',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
                    color: const Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _todayEvents.isEmpty
            ? _buildEmptyState('No events today')
            : SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _todayEvents.length,
                  itemBuilder: (context, index) {
                    final event = _todayEvents[index];
                    return _buildTodayEventCard(event);
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTodayEventCard(Map<String, dynamic> event) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.7; // Responsive card width
    
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to event detail page
        // Navigator functionality removed
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(event['image'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=600'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(_getResponsiveSize(screenWidth, 24, 20, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSize(screenWidth, 14, 12, 10), 
                    vertical: _getResponsiveSize(screenWidth, 8, 6, 5)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '23\nAUG',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Text(
              event['title'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: _getResponsiveFontSize(screenWidth, 20, 18, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event['time'],
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: _getResponsiveSize(screenWidth, 28, 24, 20),
                      height: _getResponsiveSize(screenWidth, 28, 24, 20),
                      decoration: BoxDecoration(
                        color: event['color'],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.person, 
                        color: Colors.white, 
                        size: _getResponsiveSize(screenWidth, 14, 12, 10)
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${event['attendees'] ?? '120'} Attending',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getResponsiveSize(screenWidth, 18, 16, 14), 
                    vertical: _getResponsiveSize(screenWidth, 10, 8, 6)
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Join',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                      fontWeight: FontWeight.w600,
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

  Widget _buildUpcomingSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      width: screenWidth * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 24, 20, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(
                        events: _upcomingEvents,
                        eventType: 'Upcoming',
                      ),
                    ),
                  );
                },
                child: Text(
                  'View more',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
                    color: const Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _upcomingEvents.isEmpty
            ? _buildEmptyState('No upcoming events found')
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = _upcomingEvents[index];
                    return _buildUpcomingEventCard(event);
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventCard(Map<String, dynamic> event) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to event detail page
        // Navigator functionality removed
      },
      child: Container(
        width: screenWidth * 0.7,
        margin: const EdgeInsets.only(right: 16),
        padding: EdgeInsets.all(_getResponsiveSize(screenWidth, 20, 16, 14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6).withValues(alpha: 0.1), Color(0xFFEC4899).withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (event['date'] ?? '25 AUG').split(' ')[0],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  Text(
                    (event['date'] ?? '25 AUG').split(' ')[1],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8B5CF6),
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
                    event['title'] ?? 'Event Title',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['time'] ?? '2:00 PM - 6:00 PM',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF636E72), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${event['attendees'] ?? '95'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildAnalyticsCard('Total Events', '156', Icons.event, const Color(0xFF6C5CE7))),
            const SizedBox(width: 16),
            Expanded(child: _buildAnalyticsCard('Attendees', '2.4K', Icons.people, const Color(0xFF00B894))),
            const SizedBox(width: 16),
            Expanded(child: _buildAnalyticsCard('Revenue', '\$12.5K', Icons.attach_money, const Color(0xFFE17055))),
          ],
        ),
        const SizedBox(height: 16),
        _buildEventChart(),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Icon(Icons.more_vert, color: Color(0xFF636E72), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Categories Distribution',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: const Color(0xFF6C5CE7),
                    title: 'Technical\n40%',
                    radius: 60,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 35,
                    color: const Color(0xFF00B894),
                    title: 'Cultural\n35%',
                    radius: 60,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: const Color(0xFFE17055),
                    title: 'Academic\n25%',
                    radius: 60,
                    titleStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use all past events without filtering
    final pastEvents = _pastEvents;
    
    return SizedBox(
      width: screenWidth * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Past Events',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 24, 20, 18),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(
                        events: _pastEvents,
                        eventType: 'Past',
                      ),
                    ),
                  );
                },
                child: Text(
                  'View more',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          pastEvents.isEmpty
            ? _buildEmptyState('No past events found')
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pastEvents.length,
                  itemBuilder: (context, index) {
                    final event = pastEvents[index];
                    return Container(
                      width: screenWidth * 0.7,
                      margin: const EdgeInsets.only(right: 16),
                      child: _buildPastEventCard(event),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to event detail page
        // Navigator functionality removed
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
            // Background Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(event['image'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=600'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(_getResponsiveSize(screenWidth, 16, 14, 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveSize(screenWidth, 10, 8, 6),
                        vertical: _getResponsiveSize(screenWidth, 6, 5, 4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['date'] ?? '20 AUG',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['title'] ?? 'Event Title',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(screenWidth, 18, 16, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['time'] ?? '2:00 PM - 6:00 PM',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: _getResponsiveSize(screenWidth, 16, 14, 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event['attendees'] ?? '85'} attended',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
