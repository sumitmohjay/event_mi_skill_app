import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Academic', 'Cultural', 'Technical'];
  
  // Filtered events based on selected category
  List<Map<String, dynamic>> get _filteredTodayEvents {
    if (_selectedCategory == 0) return _todayEvents; // All
    final categoryName = _categories[_selectedCategory];
    return _todayEvents.where((event) => event['category'] == categoryName).toList();
  }
  
  List<Map<String, dynamic>> get _filteredUpcomingEvents {
    if (_selectedCategory == 0) return _upcomingEvents; // All
    final categoryName = _categories[_selectedCategory];
    return _upcomingEvents.where((event) => event['category'] == categoryName).toList();
  }
  
  final List<Map<String, dynamic>> _todayEvents = [
    {
      'title': 'Tech Conference 2024',
      'time': '9:00 AM - 11:00 AM',
      'location': 'Los Angeles',
      'attendees': 120,
      'category': 'Technical',
      'color': const Color(0xFF6C5CE7),
    },
    {
      'title': 'Cultural Festival',
      'time': '2:00 PM - 6:00 PM',
      'location': 'New York',
      'attendees': 85,
      'category': 'Cultural',
      'color': const Color(0xFFE17055),
    },
    {
      'title': 'Academic Seminar',
      'time': '10:00 AM - 12:00 PM',
      'location': 'Boston',
      'attendees': 65,
      'category': 'Academic',
      'color': const Color(0xFF00B894),
    },
  ];

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'AI Workshop',
      'date': '25 AUG',
      'time': '2:00 PM - 6:00 PM',
      'attendees': 95,
      'category': 'Technical',
    },
    {
      'title': 'Art Exhibition',
      'date': '26 AUG',
      'time': '6:00 PM - 11:00 PM',
      'attendees': 150,
      'category': 'Cultural',
    },
  ];

  final List<Map<String, dynamic>> _pastEvents = [
    {
      'title': 'AI Workshop',
      'date': '25 AUG',
      'time': '2:00 PM - 6:00 PM',
      'attendees': 95,
      'category': 'Technical',
    },
    {
      'title': 'Art Exhibition',
      'date': '26 AUG',
      'time': '6:00 PM - 11:00 PM',
      'attendees': 150,
      'category': 'Cultural',
    },
    {
      'title': 'Business Summit',
      'date': '27 AUG',
      'time': '9:00 AM - 5:00 PM',
      'attendees': 200,
      'category': 'Academic',
    },
    {
      'title': 'Music Festival',
      'date': '28 AUG',
      'time': '7:00 PM - 12:00 AM',
      'attendees': 300,
      'category': 'Cultural',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: isWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(2, 0),
              ),
            ],
          ),
          child: _buildSidebar(),
        ),
        // Main content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildMainContent();
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Logo/Title
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Events',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Navigation items
        _buildNavItem(Icons.home, 'Dashboard', true),
        _buildNavItem(Icons.event, 'Events', false),
        _buildNavItem(Icons.calendar_today, 'Calendar', false),
        _buildNavItem(Icons.people, 'Attendees', false),
        _buildNavItem(Icons.analytics, 'Analytics', false),
        _buildNavItem(Icons.settings, 'Settings', false),
        const Spacer(),
        // Stats Chart
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildMiniChart(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C5CE7).withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF636E72),
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isActive ? const Color(0xFF6C5CE7) : const Color(0xFF636E72),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        dense: true,
      ),
    );
  }

  Widget _buildMiniChart() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Stats',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 3),
                      FlSpot(1, 1),
                      FlSpot(2, 4),
                      FlSpot(3, 2),
                      FlSpot(4, 5),
                    ],
                    isCurved: true,
                    color: const Color(0xFF6C5CE7),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGradientHeader(),
          Padding(
            padding: EdgeInsets.all(isWeb ? 32 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildLocationCard(),
                const SizedBox(height: 24),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                _buildTodaySection(),
                const SizedBox(height: 24),
                _buildUpcomingSection(),
                const SizedBox(height: 24),
                _buildPastEventsSection(),
                if (isWeb) ...[
                  const SizedBox(height: 24),
                  _buildAnalyticsSection(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6), // Purple matching first image
            Color(0xFFEC4899), // Pink accent from first image
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        isWeb ? 32 : 20, 
        MediaQuery.of(context).padding.top + 16, 
        isWeb ? 32 : 20, 
        32
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile - o
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white70, size: 24),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 24),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Discover Events Title
          Text(
            'Discover Events',
            style: GoogleFonts.poppins(
              fontSize: isWeb ? 42 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            'Find the best events near you',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 800 
        ? screenWidth * 0.6 
        : MediaQuery.of(context).size.width * 0.9;
    
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF472B6)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create An Event',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'New York, US',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth > 800 
        ? screenWidth * 0.8 
        : MediaQuery.of(context).size.width * 0.9;
    
    return SizedBox(
      width: containerWidth,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : const Color(0xFF636E72),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodaySection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF6C5CE7), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Los Angeles',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6C5CE7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right, color: Color(0xFF6C5CE7), size: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredTodayEvents.length,
            itemBuilder: (context, index) {
              final event = _filteredTodayEvents[index];
              return _buildTodayEventCard(event, isWeb);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEventCard(Map<String, dynamic> event, bool isWeb) {
    final cardWidth = isWeb ? 300.0 : MediaQuery.of(context).size.width * 0.8;
    
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/400/200?random=1'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '23\nAUG',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event['time'],
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: event['color'],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 12),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${event['attendees']} Attending',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      fontSize: 12,
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
    final isWeb = screenWidth > 800;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Past',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            Text(
              'View more',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6C5CE7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isWeb)
          Row(
            children: _filteredUpcomingEvents.map((event) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildUpcomingEventCard(event),
                ),
              );
            }).toList(),
          )
        else
          Column(
            children: _filteredUpcomingEvents.map((event) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildUpcomingEventCard(event),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildUpcomingEventCard(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  event['date'].split(' ')[0],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                Text(
                  event['date'].split(' ')[1],
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
                  event['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['time'],
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
                '${event['attendees']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
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
    final isWeb = screenWidth > 800;
    
    // Filter past events based on selected category
    final filteredPastEvents = _selectedCategory == 0 
        ? _pastEvents 
        : _pastEvents.where((event) => event['category'] == _categories[_selectedCategory]).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Past Events',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            Text(
              'View more',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: PageController(viewportFraction: isWeb ? 0.5 : 0.9),
            itemCount: filteredPastEvents.length,
            itemBuilder: (context, index) {
              final event = filteredPastEvents[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: _buildPastEventCard(event),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 50,
            height: 50,
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
                  event['date'].split(' ')[0],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                Text(
                  event['date'].split(' ')[1],
                  style: GoogleFonts.poppins(
                    fontSize: 10,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event['time'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
                '${event['attendees']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
