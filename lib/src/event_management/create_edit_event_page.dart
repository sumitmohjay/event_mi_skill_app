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
    }
  }

  void _populateFields() {
    final event = widget.event!;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _venueController.text = event.venue;
    _maxAttendeesController.text = event.maxAttendees.toString();
    _priceController.text = event.price?.toString() ?? '';
    _contactEmailController.text = event.contactEmail ?? '';
    _contactPhoneController.text = event.contactPhone ?? '';
    _meetingLinkController.text = event.meetingLink ?? '';
    _tagsController.text = event.tags.join(', ');
    _selectedDateTime = event.dateTime;
    _selectedMode = event.mode;
    _selectedCategory = event.category;
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
              _buildContactSection(),
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
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Date & Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(_selectedDateTime),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
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
                    value: _selectedCategory,
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
                    value: _selectedMode,
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

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
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

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final event = Event(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: _selectedDateTime,
      venue: _venueController.text.trim(),
      mode: _selectedMode,
      category: _selectedCategory,
      resources: _resources,
      imageUrl: _imageUrl,
      price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : null,
      maxAttendees: int.parse(_maxAttendeesController.text),
      currentAttendees: widget.event?.currentAttendees ?? 0,
      organizerId: 'current_user_id', // Replace with actual user ID
      organizerName: 'Current User', // Replace with actual user name
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
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

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.event != null ? 'Event updated successfully' : 'Event created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventProvider.errorMessage ?? 'Failed to save event'),
          backgroundColor: Colors.red,
        ),
      );
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
