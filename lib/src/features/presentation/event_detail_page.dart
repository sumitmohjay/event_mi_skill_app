import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/app_header.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _selectedImageCategory = 0;
  final List<String> _imageCategories = ['All', 'Certificate', 'Behind Scene'];

  // Sample event images for different categories
  final List<String> _eventImages = [
    'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=400',
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
    'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
    'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=400',
    'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400',
    'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?w=400',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppHeader(
        title: widget.event['title'] ?? 'Event Details',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Main Image
            _buildEventMainImage(screenWidth, screenHeight),
            
            // Event Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title and Price
                  _buildEventHeader(screenWidth),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Participant Count
                  _buildParticipantCount(screenWidth),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // About Event Section
                  _buildAboutSection(screenWidth),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Event Details (Location, Time)
                  _buildEventDetails(screenWidth),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Event Images Section
                  _buildEventImagesSection(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Participant Engagement Section
                  _buildParticipantEngagementSection(screenWidth, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Location Map Section
                  _buildLocationMapSection(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventMainImage(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: screenHeight * 0.3,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        image: DecorationImage(
          image: NetworkImage(widget.event['image'] ?? 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=600'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEventHeader(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event['title'] ?? 'Event Title',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 24, 20, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.event['location'] ?? 'Event Location',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Start: ${widget.event['startTime'] ?? '9:00 AM'}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'End: ${widget.event['endTime'] ?? '11:00 AM'}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantCount(double screenWidth) {
    return Row(
      children: [
        Icon(
          Icons.people,
          color: Colors.grey[600],
          size: _getResponsiveSize(screenWidth, 20, 18, 16),
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.event['attendees'] ?? '250'} people',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          color: Colors.grey[600],
          size: _getResponsiveSize(screenWidth, 20, 18, 16),
        ),
        const SizedBox(width: 8),
        Text(
          widget.event['time'] ?? '7:00 PM - 11:00 PM',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Event',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 18, 16, 14),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.event['description'] ?? 
          'Planning an event can be a daunting task. Especially when you\'re not sure where to start. This comprehensive guide will help you plan and execute a successful event from start to finish.',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Participants Row
        Row(
          children: [
            // Profile images
            SizedBox(
              width: 80,
              height: 30,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100'),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '+20 Participants',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Location
        Text(
          'Location',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: const Color(0xFF8B5CF6),
              size: _getResponsiveSize(screenWidth, 20, 18, 16),
            ),
            const SizedBox(width: 8),
            Text(
              widget.event['location'] ?? 'California, USA',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventImagesSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category buttons
        Row(
          children: [
            Text(
              'Top Picks 🔥',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Category filter buttons
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageCategories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedImageCategory == index;
              return GestureDetector(
                onTap: () {
                  if (index == 1) {
                    // Show certificate dialog or navigate to certificate page
                    _showCertificateDialog(context);
                  } else {
                    setState(() {
                      _selectedImageCategory = index;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index == 1) // Certificate
                        Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        )
                      else if (index == 2) // Behind Scene
                        Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        )
                      else // All
                        Icon(
                          Icons.apps,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _imageCategories[index],
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(screenWidth, 12, 10, 8),
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Images slider
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _eventImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_eventImages[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantEngagementSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: const Color(0xFF3B82F6),
              size: _getResponsiveSize(screenWidth, 24, 22, 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Participant Engagement',
              style: GoogleFonts.poppins(
                fontSize: _getResponsiveFontSize(screenWidth, 20, 18, 16),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track participant engagement (Q&A, polls).',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        
        // Q&A Sessions Section
        Text(
          'Q&A Sessions',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 18, 16, 14),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildQACard(index, screenWidth);
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Polls Section
        Text(
          'Live Polls',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 18, 16, 14),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildPollCard(index, screenWidth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQACard(int index, double screenWidth) {
    final qaData = [
      {
        'question': 'What are the latest trends in AI development?',
        'author': 'Sarah Chen',
        'time': '2 min ago',
        'answers': '5',
      },
      {
        'question': 'How to implement machine learning in mobile apps?',
        'author': 'Mike Johnson',
        'time': '5 min ago',
        'answers': '3',
      },
      {
        'question': 'Best practices for cloud architecture?',
        'author': 'Alex Rivera',
        'time': '8 min ago',
        'answers': '7',
      },
    ];

    final qa = qaData[index];
    return Container(
      width: screenWidth * 0.85,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.question_answer,
                color: const Color(0xFF3B82F6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Q&A',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 11, 10),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${qa['answers']} answers',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(screenWidth, 10, 9, 8),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            qa['question']!,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(screenWidth, 14, 13, 12),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'by ${qa['author']}',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 11, 10),
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                qa['time']!,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 11, 10, 9),
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(int index, double screenWidth) {
    final pollData = [
      {
        'question': 'Which technology will dominate 2024?',
        'option1': 'AI/ML',
        'option2': 'Blockchain',
        'votes': '156',
        'percentage': '78%',
      },
      {
        'question': 'Preferred development framework?',
        'option1': 'React',
        'option2': 'Flutter',
        'votes': '89',
        'percentage': '65%',
      },
      {
        'question': 'Most important skill for developers?',
        'option1': 'Problem Solving',
        'option2': 'Communication',
        'votes': '203',
        'percentage': '82%',
      },
    ];

    final poll = pollData[index];
    return Container(
      width: screenWidth * 0.85,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.poll,
                color: const Color(0xFFEC4899),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Poll',
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 11, 10),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEC4899),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${poll['votes']} votes',
                  style: GoogleFonts.poppins(
                    fontSize: _getResponsiveFontSize(screenWidth, 10, 9, 8),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            poll['question']!,
            style: GoogleFonts.poppins(
              fontSize: _getResponsiveFontSize(screenWidth, 14, 13, 12),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    poll['option1']!,
                    style: GoogleFonts.poppins(
                      fontSize: _getResponsiveFontSize(screenWidth, 11, 10, 9),
                      color: const Color(0xFFEC4899),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                poll['percentage']!,
                style: GoogleFonts.poppins(
                  fontSize: _getResponsiveFontSize(screenWidth, 12, 11, 10),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEC4899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMapSection(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Map',
          style: GoogleFonts.poppins(
            fontSize: _getResponsiveFontSize(screenWidth, 20, 18, 16),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Google Maps with actual address
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://maps.googleapis.com/maps/api/staticmap?center=1600+Amphitheatre+Parkway,+Mountain+View,+CA&zoom=15&size=600x400&maptype=roadmap&markers=color:red%7Clabel:E%7C1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyBFw0Qbyq9zTFTd-tUY6dOWTgHz-TRU6Qg'
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Fallback to placeholder
                      },
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fallback content when map fails to load
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.map,
                          size: 32,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1600 Amphitheatre Parkway',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(screenWidth, 16, 14, 12),
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mountain View, CA 94043',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(screenWidth, 14, 12, 10),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to open in Maps',
                        style: GoogleFonts.poppins(
                          fontSize: _getResponsiveFontSize(screenWidth, 12, 11, 10),
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Location pin overlay
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: const Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCertificateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Certificate',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get a certificate of completion after attending this event. Perfect for your professional portfolio.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      const Color(0xFFEC4899).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CERTIFICATE OF COMPLETION',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B5CF6),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This is to certify that',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'John Doe',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'has successfully completed',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.event['title'] ?? 'Tech Conference 2024',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 20,
                                color: const Color(0xFF8B5CF6),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MohJay Infotech',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add download functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Download',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  double _getResponsiveFontSize(double screenWidth, double webSize, double tabletSize, double mobileSize) {
    if (screenWidth > 900) return webSize;
    if (screenWidth > 600) return tabletSize;
    return mobileSize + 2; // Increased mobile font size for better visibility
  }

  double _getResponsiveSize(double screenWidth, double webSize, double tabletSize, double mobileSize) {
    if (screenWidth > 900) return webSize;
    if (screenWidth > 600) return tabletSize;
    return mobileSize;
  }
}
