import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitSupportMessage({
    required String message,
    String? contactInfo,
  }) async {
    final user = _auth.currentUser;
    
    await _firestore.collection('support_messages').add({
      'userId': user?.uid ?? 'anonymous',
      'message': message,
      'contactInfo': contactInfo,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'isAnonymous': user == null,
    });
  }
} 