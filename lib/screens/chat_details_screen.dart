import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final bool isDoctor;
  final String receiverRole; // 'doctor' or 'patient'

  const ChatPage({
    required this.receiverId,
    required this.receiverName,
    required this.isDoctor,
    required this.receiverRole,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final String currentUserId;
  String? _error;
  String? _chatId;
  bool _isLoading = true;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'User not authenticated';
      _isLoading = false;
      return;
    }

    currentUserId = user.uid;
    _currentUserRole = widget.isDoctor ? 'doctor' : 'patient';
    _chatId = _generateChatId(currentUserId, widget.receiverId);
    _initializeChat();
  }

  String _generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  Future<void> _initializeChat() async {
    try {
      await _verifyChatExists();
      await _markMessagesAsRead();
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize chat';
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyChatExists() async {
    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .get();

    if (!chatDoc.exists) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .set({
        'participants': {
          currentUserId: _currentUserRole,
          widget.receiverId: widget.receiverRole,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_chatId == null) return;

    try {
      // Mark messages as read
      final unreadMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.receiverId)
          .where('read', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      // Update unread count for current user
      await _updateUnreadCount(0);
    } catch (e) {
      print('Error marking messages as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update read status')),
      );
    }
  }

  Future<void> _updateUnreadCount(int newCount) async {
    try {
      final collection = widget.isDoctor ? 'doctors' : 'patients';
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(currentUserId)
          .collection('chats')
          .doc(widget.receiverId)
          .update({
        'unreadCount': newCount,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading messages'),
                TextButton(
                  onPressed: _initializeChat,
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
            final isDoctorMessage = data['senderType'] == 'doctor';

            return _buildMessageBubble(data, isMe, isDoctorMessage);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> data, bool isMe, bool isDoctorMessage) {
    final bubbleColor = isDoctorMessage
        ? Colors.blue[200]
        : Colors.green[200];
    final textColor = isDoctorMessage
        ? Colors.blue[900]
        : Colors.green[900];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey[300] : bubbleColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                widget.receiverName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
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
      // Add message to chat
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
        'senderType': _currentUserRole,
      });

      // Update chat references for both users
      await _updateChatReferences();

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  Future<void> _updateChatReferences() async {
    final messageData = {
      'lastMessage': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'lastMessageSender': currentUserId,
    };

    // Update current user's reference
    final currentUserCollection = widget.isDoctor ? 'doctors' : 'patients';
    await FirebaseFirestore.instance
        .collection(currentUserCollection)
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.receiverId)
        .set(messageData, SetOptions(merge: true));

    // Update receiver's reference with incremented unread count
    final receiverCollection = widget.receiverRole == 'doctor' ? 'doctors' : 'patients';
    await FirebaseFirestore.instance
        .collection(receiverCollection)
        .doc(widget.receiverId)
        .collection('chats')
        .doc(currentUserId)
        .set({
      ...messageData,
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
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