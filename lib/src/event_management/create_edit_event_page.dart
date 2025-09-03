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
  final _venueController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  EventMode _selectedMode = EventMode.offline;
  EventCategory _selectedCategory = EventCategory.other;
  List<String> _resources = [];
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
    _venueController.text = event.venue ?? '';
    _maxAttendeesController.text = event.maxAttendees.toString();
    _priceController.text = event.price?.toString() ?? '';
    _contactEmailController.text = event.contactEmail ?? '';
    _contactPhoneController.text = event.contactPhone ?? '';
    _meetingLinkController.text = event.meetingLink ?? '';
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
    _resources = List.from(event.resources);
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
              // _buildContactSection(),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event title';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter event description',
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event description';
            }
            return null;
          },
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
          controller: _venueController,
          label: 'Venue/Location',
          hint: _selectedMode == EventMode.online 
              ? 'Platform name (e.g., Zoom, Google Meet)'
              : 'Enter venue address',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter venue/location';
            }
            return null;
          },
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
                controller: _maxAttendeesController,
                label: 'Max Attendees',
                hint: 'Enter maximum capacity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max attendees';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'Price (Optional)',
                hint: 'Enter price or leave empty for free',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Please enter a valid price';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildContactSection() {
  //   return _buildSection(
  //     'Contact Information',
  //     [
  //       _buildTextField(
  //         controller: _contactEmailController,
  //         label: 'Contact Email',
  //         hint: 'Enter contact email',
  //         keyboardType: TextInputType.emailAddress,
  //       ),
  //       const SizedBox(height: 15),
  //       _buildTextField(
  //         controller: _contactPhoneController,
  //         label: 'Contact Phone',
  //         hint: 'Enter contact phone number',
  //         keyboardType: TextInputType.phone,
  //       ),
  //     ],
  //   );
  // }

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
      final newImages = _resources.where((resource) {
        final lower = resource.toLowerCase();
        return lower.endsWith('.jpg') || 
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.gif');
      }).toList();
      
      // Get new videos from resources (filter by common video extensions)
      final newVideos = _resources.where((resource) {
        final lower = resource.toLowerCase();
        return lower.endsWith('.mp4') || 
              lower.endsWith('.mov') ||
              lower.endsWith('.avi');
      }).toList();
      
      // Combine existing and new media, removing duplicates
      final allImages = {...existingImages, ...newImages}.toList();
      final allVideos = {...existingVideos, ...newVideos}.toList();
      
      // Get the main image URL (first image if available, otherwise use existing or null)
      final mainImageUrl = allImages.isNotEmpty 
          ? allImages.first 
          : _imageUrl ?? (widget.event?.imageUrl);
      
      final event = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _venueController.text.trim(),
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
        venue: _venueController.text.trim(),
        mode: _selectedMode,
        category: _selectedCategory,
        resources: _resources,
        imageUrl: mainImageUrl,
        price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : null,
        maxAttendees: int.tryParse(_maxAttendeesController.text) ?? 0,
        currentAttendees: widget.event?.currentAttendees ?? 0,
        organizerId: 'current_user_id',
        organizerName: 'Current User',
        tags: tags,
        meetingLink: _meetingLinkController.text.trim().isNotEmpty ? _meetingLinkController.text.trim() : null,
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
    _venueController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _meetingLinkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
