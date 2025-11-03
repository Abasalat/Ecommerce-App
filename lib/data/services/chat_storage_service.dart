import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/models/chat_message_model.dart';
import 'package:ecommerce_app/data/models/conversation_context.dart';

class ChatStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save message to Firestore
  Future<void> saveMessage(String userId, ChatMessageModel message) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  // Load chat history
  Future<List<ChatMessageModel>> loadChatHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  // Clear chat history
  Future<void> clearChatHistory(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  // Save conversation context
  Future<void> saveConversationContext(ConversationContext context) async {
    try {
      await _firestore
          .collection('users')
          .doc(context.userId)
          .collection('preferences')
          .doc('conversation_context')
          .set(context.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving context: $e');
    }
  }

  // Load conversation context
  Future<ConversationContext?> loadConversationContext(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('conversation_context')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return ConversationContext(
          userId: userId,
          recentlyViewedProductIds: List<String>.from(
            data['recentlyViewedProductIds'] ?? [],
          ),
          wishlistProductIds: List<String>.from(
            data['wishlistProductIds'] ?? [],
          ),
          cartProductIds: List<String>.from(data['cartProductIds'] ?? []),
          categoryPreferences: List<String>.from(
            data['categoryPreferences'] ?? [],
          ),
          minPricePreference: data['minPricePreference']?.toDouble(),
          maxPricePreference: data['maxPricePreference']?.toDouble(),
        );
      }
      return null;
    } catch (e) {
      print('Error loading context: $e');
      return null;
    }
  }
}
