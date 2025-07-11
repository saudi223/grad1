import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }
    return _auth.currentUser!.uid;
  }

  String getChatId(String userId1, String userId2) {
    if (userId1.isEmpty || userId2.isEmpty) {
      throw Exception('User IDs cannot be empty');
    }
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Stream<QuerySnapshot> getChatStream(String receiverId) {
    try {
      if (receiverId.isEmpty) {
        throw Exception('Receiver ID cannot be empty');
      }

      final chatId = getChatId(currentUserId, receiverId);
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
        throw Exception('Failed to load messages: ${error.toString()}');
      });
    } catch (e) {
      throw Exception('Failed to initialize chat stream: ${e.toString()}');
    }
  }

  Future<void> sendMessage(
      String receiverId, String message, bool isSendingAsPatient) async {
    try {
      if (receiverId.isEmpty) {
        throw Exception('Receiver ID cannot be empty');
      }
      if (message.isEmpty) {
        throw Exception('Message cannot be empty');
      }

      final senderId = currentUserId;
      final chatId = getChatId(senderId, receiverId);
      final timestamp = Timestamp.now();

      // Message document
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'read': false,
      });

      // Chat preview metadata
      final messageData = {
        'lastMessage': message,
        'timestamp': timestamp,
        'unreadCount': FieldValue.increment(1),
      };

      final collectionPath = isSendingAsPatient
          ? 'patients/$senderId/doctor_chats'
          : 'doctors/$senderId/patient_chats';

      await _firestore
          .collection(collectionPath)
          .doc(receiverId)
          .set(messageData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  Future<void> markMessagesAsRead(String chatId, String senderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: senderId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: ${e.toString()}');
    }
  }
}