import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'provider/group_provider.dart';

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Map<String, dynamic>? _groupData;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroupMessages();
  }

  Future<void> _loadGroupMessages() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final groupProvider = context.read<GroupProvider>();
      final groupId = widget.group['_id']?.toString() ?? widget.group['id']?.toString();
      
      if (groupId == null) {
        throw Exception('Group ID is null');
      }

      print('Loading messages for group: $groupId');
      final response = await groupProvider.loadGroupMessages(groupId);
      
      if (response == null) {
        throw Exception('No data returned from API');
      }

      print('Processing messages from API: $response');
      
      // Handle the API response structure
      if (response['group'] == null || response['messages'] == null) {
        throw Exception('Invalid API response format');
      }

      // Update group data
      setState(() {
        _groupData = Map<String, dynamic>.from(response['group']);
      });

      // Process messages
      final messages = response['messages']?['items'] as List<dynamic>? ?? [];
      print('Found ${messages.length} messages');
      
      if (mounted) {
        setState(() {
          _messages = _processMessages(messages);
          _isLoading = false;
        });
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToBottom();
        });
      }
    } catch (e, stackTrace) {
      print('Error in _loadGroupMessages: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading messages: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _processMessages(List<dynamic> apiMessages) {
    try {
      if (apiMessages.isEmpty) {
        print('No messages to process');
        return [];
      }

      print('Processing ${apiMessages.length} messages');
      
      return apiMessages.map((msg) {
        if (msg == null) return null;
        
        try {
          print('Processing message: $msg');
          
          // Extract sender information
          final sender = msg['senderId'] is Map 
              ? msg['senderId'] as Map<String, dynamic>
              : {
                  '_id': msg['senderId']?.toString() ?? 'unknown',
                  'name': (msg['senderName']?.toString() ?? 'Unknown User').trim(),
                  'avatar': (msg['senderId'] is Map && (msg['senderId'] as Map).containsKey('avatar'))
                      ? (msg['senderId'] as Map)['avatar']
                      : null,
                };
          
          // Get message content, preferring decrypted content if available
          final content = msg['decryptedContent']?.toString() ?? 
                         msg['content']?.toString() ?? '';
          
          // Parse timestamp
          final timestamp = msg['createdAt'] != null 
              ? DateTime.tryParse(msg['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now();
              
          // Create message map
          final message = {
            'id': msg['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'sender': sender['name']?.toString() ?? 'Unknown User',
            'message': content,
            'timestamp': timestamp,
            'isMe': false, // TODO: Implement actual user check
            'avatar': sender['avatar'] ?? _getAvatarInitials(sender['name']?.toString() ?? 'UU'),
            'senderId': sender['_id']?.toString(),
            'isSystemMessage': msg['isSystemMessage'] == true,
            'isEdited': msg['isEdited'] == true,
            'readCount': (msg['readCount'] is int) ? msg['readCount'] : 0,
          };
          
          print('Processed message: $message');
          return message;
        } catch (e) {
          print('Error processing message $msg: $e');
          return null;
        }
      }).where((msg) => msg != null).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Error in _processMessages: $e');
      return [];
    }
  }

  String _getAvatarInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  int _getMemberCount() {
    if (_groupData != null) {
      final groupProvider = context.read<GroupProvider>();
      return groupProvider.getMemberCount(_groupData!);
    }
    return widget.group['memberCount'] ?? 0;
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading messages',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGroupMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to send a message!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.group['image'] != null && widget.group['image'].toString().isNotEmpty
                  ? Image.network(
                      widget.group['image'].toString(),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.group, color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.group, color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group['name']?.toString() ?? 'Unknown Group',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_getMemberCount()} members',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showGroupInfo(),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showGroupOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] ?? false;
    final timestamp = message['timestamp'] is DateTime 
        ? message['timestamp'] 
        : DateTime.tryParse(message['timestamp'].toString()) ?? DateTime.now();
    final isSystem = message['isSystemMessage'] == true;
    final isEdited = message['isEdited'] == true;
    final readCount = message['readCount'] as int? ?? 0;
    final senderName = message['sender']?.toString() ?? 'Unknown';
    final avatar = message['avatar'] is String 
        ? message['avatar']
        : _getAvatarInitials(senderName);

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          message['message']?.toString() ?? '',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              backgroundImage: (message['avatar'] is String && message['avatar'].startsWith('http'))
                  ? NetworkImage(message['avatar']) as ImageProvider<Object>?
                  : null,
              child: (message['avatar'] is String && message['avatar'].startsWith('http'))
                  ? null
                  : Text(
                      avatar,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 4),
                    child: Text(
                      senderName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message']?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTimestamp(timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          if (isEdited) ...[
                            const SizedBox(width: 4),
                            Text(
                              'edited',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: isMe ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                          ],
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              readCount > 0 ? Icons.done_all : Icons.done,
                              size: 12,
                              color: readCount > 0 
                                  ? Colors.blue[200] 
                                  : Colors.white54,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Text(
                _getAvatarInitials(senderName),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            onPressed: () {
              // Handle file attachment
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                maxLines: null,
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'sender': 'You',
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isMe': true,
        'avatar': 'ME',
      });
    });

    _messageController.clear();
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: widget.group['image'] != null && widget.group['image'].toString().isNotEmpty
                            ? Image.network(
                                widget.group['image'].toString(),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(Icons.group, size: 30),
                                  );
                                },
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.group, size: 30),
                              ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.group['name']?.toString() ?? 'Unknown Group',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.group['description']?.toString() ?? 'No description',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_getMemberCount()} members',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Group Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingItem(Icons.notifications, 'Notifications', true),
                  _buildSettingItem(Icons.volume_up, 'Sound', true),
                  _buildSettingItem(Icons.photo, 'Media & Files', false),
                  _buildSettingItem(Icons.people, 'Members', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, bool hasSwitch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          if (hasSwitch)
            Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: Theme.of(context).primaryColor,
            )
          else
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  void _showGroupOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text('Add to Favorites', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: Text('Mute Group', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text('Leave Group', style: GoogleFonts.poppins(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
