import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/auth/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final bool isDoctor;

  const ChatPage({
    required this.receiverId,
    required this.receiverName,
    required this.isDoctor,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  late final String currentUserId;
  String? _error;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'User not authenticated';
      return;
    }

    currentUserId = user.uid;
    _chatId = _chatService.getChatId(currentUserId, widget.receiverId);
    _printDebugInfo();
    _verifyChatExists();
  }

  Future<void> _verifyChatExists() async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .get();

      if (!chatDoc.exists) {
        // Create chat document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(_chatId)
            .set({
          'participants': {
            currentUserId: true,
            widget.receiverId: true
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error verifying chat: $e');
      setState(() {
        _error = 'Failed to initialize chat';
      });
    }
  }

  void _printDebugInfo() {
    print('Chat Debug Info:');
    print('Current User ID: $currentUserId');
    print('Receiver ID: ${widget.receiverId}');
    print('Chat ID: $_chatId');
    print('Is Doctor: ${widget.isDoctor}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_chatId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Stream Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading messages: ${snapshot.error}'),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages yet'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == currentUserId;

            return _buildMessageBubble(data, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['message']?.toString() ?? ''),
            SizedBox(height: 4.h),
            Text(
              _formatTime(data['timestamp']?.toDate()),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': widget.receiverId,
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Update last message in chat references
      await _updateChatReferences();

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateChatReferences() async {
    final messageData = {
      'lastMessage': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    };

    // Update doctor's reference
    if (widget.isDoctor) {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(currentUserId)
          .collection('patient_chats')
          .doc(widget.receiverId)
          .set(messageData, SetOptions(merge: true));
    }
    // Update patient's reference
    else {
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUserId)
          .collection('doctor_chats')
          .doc(widget.receiverId)
          .set(messageData, SetOptions(merge: true));
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}