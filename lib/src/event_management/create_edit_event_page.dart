import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'event.dart';
import 'provider/event_provider.dart';

class CreateEditEventPage extends StatefulWidget {
  final Event? event;

  const CreateEditEventPage({super.key, this.event});

  @override
  State<CreateEditEventPage> createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _tagsController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _registrationDeadline;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  EventMode _selectedMode = EventMode.offline;
  EventCategory _selectedCategory = EventCategory.other;
  List<String> _resources = [];
  List<String> _selectedImages = [];
  List<String> _selectedVideos = [];
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFields();
    } else if (widget.event?.id != null) {
      // If we have an event ID but no event data, fetch it from API
      _fetchEventData();
    }
  }

  Future<void> _fetchEventData() async {
    if (widget.event?.id == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final result = await eventProvider.getEventById(widget.event!.id);
      
      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load event: $error')),
          );
        },
        (event) {
          // Update the widget.event and populate fields
          setState(() {
            _populateFieldsWithEvent(event);
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading event: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (widget.event != null) {
      _populateFieldsWithEvent(widget.event!);
    }
  }

  void _populateFieldsWithEvent(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _maxParticipantsController.text = event.maxAttendees?.toString() ?? '';
    _contactEmailController.text = event.contactEmail ?? '';
    _meetingLinkController.text = event.meetingLink ?? '';
    _priceController.text = event.price?.toString() ?? '';
    _tagsController.text = event.tags.join(', ');
    _selectedDateTime = event.dateTime ?? DateTime.now();
    
    // Populate separate date/time fields
    _selectedStartDate = event.startDate;
    _selectedEndDate = event.endDate;
    
    // Parse time strings to TimeOfDay
    if (event.startTime != null) {
      final startTimeParts = event.startTime!.split(':');
      if (startTimeParts.length >= 2) {
        _selectedStartTime = TimeOfDay(
          hour: int.tryParse(startTimeParts[0]) ?? 0,
          minute: int.tryParse(startTimeParts[1]) ?? 0,
        );
      }
    }
    
    if (event.endTime != null) {
      final endTimeParts = event.endTime!.split(':');
      if (endTimeParts.length >= 2) {
        _selectedEndTime = TimeOfDay(
          hour: int.tryParse(endTimeParts[0]) ?? 0,
          minute: int.tryParse(endTimeParts[1]) ?? 0,
        );
      }
    }
    
    _selectedMode = event.mode ?? EventMode.offline;
    _selectedCategory = event.category ?? EventCategory.other;
    _registrationDeadline = event.registrationDeadline;
    _resources = List.from(event.resources);
    _selectedImages = List.from(event.images);
    _selectedVideos = List.from(event.videos);
    _imageUrl = event.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Event' : 'Create Event',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildDateTimeSection(),
              const SizedBox(height: 20),
              _buildVenueSection(),
              const SizedBox(height: 20),
              _buildCategoryModeSection(),
              const SizedBox(height: 20),
              _buildCapacityPriceSection(),
              const SizedBox(height: 20),
              _buildContactSection(),
              const SizedBox(height: 20),
              _buildRegistrationDeadlineSection(),
              const SizedBox(height: 20),
              _buildMediaSection(),
              const SizedBox(height: 20),
              _buildResourcesSection(),
              const SizedBox(height: 20),
              _buildTagsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      'Basic Information',
      [
        _buildTextField(
          controller: _titleController,
          label: 'Event Title',
          hint: 'Enter event title',
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter event description',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return _buildSection(
      'Date & Time',
      [
        // Start Date & Time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectStartDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _selectedStartDate != null 
                            ? DateFormat('MMM dd, yyyy').format(_selectedStartDate!)
                            : 'Select date',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _selectStartTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _selectedStartTime != null 
                            ? _selectedStartTime!.format(context)
                            : 'Select time',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // End Date & Time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectEndDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _selectedEndDate != null 
                            ? DateFormat('MMM dd, yyyy').format(_selectedEndDate!)
                            : 'Select date',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _selectEndTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _selectedEndTime != null 
                            ? _selectedEndTime!.format(context)
                            : 'Select time',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVenueSection() {
    return _buildSection(
      'Venue',
      [
        _buildTextField(
          controller: _locationController,
          label: 'Venue/Location',
          hint: _selectedMode == EventMode.online 
              ? 'Platform name (e.g., Zoom, Google Meet)'
              : 'Enter venue address',
        ),
        if (_selectedMode == EventMode.online || _selectedMode == EventMode.hybrid) ...[
          const SizedBox(height: 15),
          _buildTextField(
            controller: _meetingLinkController,
            label: 'Meeting Link',
            hint: 'Enter meeting link for online participants',
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryModeSection() {
    return _buildSection(
      'Category & Mode',
      [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EventCategory>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: EventCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          context.read<EventProvider>().getCategoryDisplayName(category),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EventMode>(
                    initialValue: _selectedMode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: EventMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(
                          context.read<EventProvider>().getEventModeDisplayName(mode),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapacityPriceSection() {
    return _buildSection(
      'Capacity & Price',
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _maxParticipantsController,
                label: 'Max Attendees',
                hint: 'Enter maximum capacity',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price (Optional)',
                hint: 'Enter price or leave empty for free',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return _buildSection(
      'Event Media',
      [
        // Images Section
        Row(
          children: [
            Expanded(
              child: Text(
                'Event Images',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: Text(
                'Add Images',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.grey[600],
                                      size: 30,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Image\nSelected',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Image.file(
                                File(_selectedImages[index]),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        // Videos Section
        Row(
          children: [
            Expanded(
              child: Text(
                'Event Videos',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _pickVideos,
              icon: const Icon(Icons.video_library, size: 18),
              label: Text(
                'Add Videos',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
        if (_selectedVideos.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...List.generate(_selectedVideos.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.video_file, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedVideos[index].split('/').last,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeVideo(index),
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      'Contact Information',
      [
        _buildTextField(
          controller: _contactEmailController,
          label: 'Contact Email',
          hint: 'Enter contact email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _contactPhoneController,
          label: 'Contact Phone',
          hint: 'Enter contact phone number',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildRegistrationDeadlineSection() {
    return _buildSection(
      'Registration Deadline',
      [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Registration Deadline',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _registrationDeadline != null 
                ? DateFormat('MMM dd, yyyy - hh:mm a').format(_registrationDeadline!)
                : 'Select registration deadline',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.event_available,
            color: const Color(0xFF4F46E5),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _registrationDeadline ?? DateTime.now().add(const Duration(hours: 12)),
              firstDate: DateTime.now(),
              lastDate: _selectedStartDate ?? DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_registrationDeadline ?? DateTime.now()),
              );
              if (time != null) {
                setState(() {
                  _registrationDeadline = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return _buildSection(
      'Resources',
      [
        Row(
          children: [
            Expanded(
              child: Text(
                'Event Resources',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addResource,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add Resource',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
        if (_resources.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...List.generate(_resources.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attachment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _resources[index].split('/').last,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeResource(index),
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTagsSection() {
    return _buildSection(
      'Tags',
      [
        _buildTextField(
          controller: _tagsController,
          label: 'Tags (comma separated)',
          hint: 'e.g., technology, workshop, beginner',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedStartDate = date;
        // Update legacy field for backward compatibility
        if (_selectedStartTime != null) {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedStartTime!.hour,
            _selectedStartTime!.minute,
          );
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedStartTime = time;
        // Update legacy field for backward compatibility
        if (_selectedStartDate != null) {
          _selectedDateTime = DateTime(
            _selectedStartDate!.year,
            _selectedStartDate!.month,
            _selectedStartDate!.day,
            time.hour,
            time.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedEndDate = date;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? _selectedStartTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedEndTime = time;
      });
    }
  }

  void _addResource() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Resource',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text('Pick Image', style: GoogleFonts.poppins()),
              onTap: () => _pickImage(),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text('Add File URL', style: GoogleFonts.poppins()),
              onTap: () => _addFileUrl(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _resources.add(image.path);
      });
      
      // If this is a new event, set the first image as the main image
      if (_imageUrl == null) {
        setState(() {
          _imageUrl = image.path;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    print('📸 Starting image picker...');
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    
    print('📸 Picked ${images.length} images');
    for (int i = 0; i < images.length; i++) {
      print('📸 Image $i: ${images[i].path}');
    }
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => image.path));
      });
      
      print('📸 Total selected images now: ${_selectedImages.length}');
      print('📸 Selected images: $_selectedImages');
      
      // If this is a new event, set the first image as the main image
      if (_imageUrl == null && _selectedImages.isNotEmpty) {
        setState(() {
          _imageUrl = _selectedImages.first;
        });
      }
    } else {
      print('📸 No images were selected');
    }
  }

  Future<void> _pickVideos() async {
    print('🎥 Starting video picker...');
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    
    if (video != null) {
      print('🎥 Picked video: ${video.path}');
      setState(() {
        _selectedVideos.add(video.path);
      });
      print('🎥 Total selected videos now: ${_selectedVideos.length}');
      print('🎥 Selected videos: $_selectedVideos');
    } else {
      print('🎥 No video was selected');
    }
  }

  void _removeImage(int index) {
    setState(() {
      final removedImage = _selectedImages.removeAt(index);
      // If this was the main image, update it
      if (_imageUrl == removedImage && _selectedImages.isNotEmpty) {
        _imageUrl = _selectedImages.first;
      } else if (_imageUrl == removedImage) {
        _imageUrl = null;
      }
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  void _addFileUrl() {
    Navigator.pop(context);
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add File URL', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter file URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _resources.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeResource(int index) {
    setState(() {
      _resources.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Get existing images and videos if editing
      final existingImages = widget.event?.images ?? [];
      final existingVideos = widget.event?.videos ?? [];
      
      // Get new images from resources (filter by common image extensions)
      final resourceImages = _resources.where((resource) {
        final lower = resource.toLowerCase();
        return lower.endsWith('.jpg') || 
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.gif');
      }).toList();
      
      // Get new videos from resources (filter by common video extensions)
      final resourceVideos = _resources.where((resource) {
        final lower = resource.toLowerCase();
        return lower.endsWith('.mp4') || 
              lower.endsWith('.mov') ||
              lower.endsWith('.avi');
      }).toList();
      
      // Combine all image sources, removing duplicates
      final allImages = {...existingImages, ...resourceImages, ..._selectedImages}.toList();
      final allVideos = {...existingVideos, ...resourceVideos, ..._selectedVideos}.toList();
      
      // Debug logging
      print('🖼️ Selected Images: $_selectedImages');
      print('🎥 Selected Videos: $_selectedVideos');
      print('📁 Resource Images: $resourceImages');
      print('📁 Resource Videos: $resourceVideos');
      print('🔗 All Images: $allImages');
      print('🔗 All Videos: $allVideos');
      
      // Get the main image URL (first image if available, otherwise use existing or null)
      final mainImageUrl = allImages.isNotEmpty 
          ? allImages.first 
          : _imageUrl ?? (widget.event?.imageUrl);
      
      final event = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        images: allImages,
        videos: allVideos,
        createdBy: const CreatedBy(id: '', name: 'Current User', email: ''),
        isActive: true,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        slug: _titleController.text.trim().toLowerCase().replaceAll(' ', '-'),
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        startTime: _selectedStartTime != null ? '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}' : null,
        endTime: _selectedEndTime != null ? '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}' : null,
        dateTime: _selectedDateTime,
        venue: _locationController.text.trim(),
        mode: _selectedMode,
        category: _selectedCategory,
        resources: _resources,
        imageUrl: mainImageUrl,
        price: double.tryParse(_priceController.text.trim()),
        maxAttendees: int.tryParse(_maxParticipantsController.text.trim()) ?? 0,
        currentAttendees: widget.event?.currentAttendees ?? 0,
        organizerId: 'current_user_id',
        organizerName: 'Current User',
        tags: tags,
        meetingLink: _meetingLinkController.text.trim().isNotEmpty 
            ? _meetingLinkController.text.trim() 
            : null,
        contactEmail: _contactEmailController.text.trim().isNotEmpty ? _contactEmailController.text.trim() : null,
        contactPhone: _contactPhoneController.text.trim().isNotEmpty ? _contactPhoneController.text.trim() : null,
      );

      final eventProvider = context.read<EventProvider>();
      bool success;

      if (widget.event != null) {
        success = await eventProvider.updateEvent(event);
      } else {
        success = await eventProvider.createEvent(event);
      }

      if (success && mounted) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.event != null ? 'Event updated successfully' : 'Event created successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        throw Exception(eventProvider.errorMessage ?? 'Failed to save event');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _meetingLinkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
