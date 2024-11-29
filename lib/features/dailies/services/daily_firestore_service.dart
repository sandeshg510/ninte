import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_task.dart';
import 'dart:developer' as dev;

class DailyFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _dailiesCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw 'User not authenticated';
    return _firestore.collection('users').doc(uid).collection('dailies');
  }

  // Create new daily task
  Future<void> createDaily(DailyTask daily) async {
    try {
      final data = daily.toJson();
      dev.log('Creating daily task with data: $data');
      await _dailiesCollection.doc(daily.id).set(data);
      dev.log('Successfully created daily task with ID: ${daily.id}');
    } catch (e) {
      dev.log('Error creating daily task: $e');
      throw 'Failed to create daily task: ${e.toString()}';
    }
  }

  // Get all daily tasks
  Stream<List<DailyTask>> getDailies() {
    try {
      dev.log('Starting to fetch dailies stream');
      final stream = _dailiesCollection
          .orderBy('dueTime')
          .snapshots()
          .map((snapshot) {
            dev.log('Received Firestore snapshot with ${snapshot.docs.length} documents');
            return snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              dev.log('Processing document: ${doc.id} with data: $data');
              return DailyTask.fromJson({...data, 'id': doc.id});
            }).toList();
          });
      return stream;
    } catch (e) {
      dev.log('Error getting daily tasks: $e');
      throw 'Failed to get daily tasks: ${e.toString()}';
    }
  }

  // Update daily task
  Future<void> updateDaily(DailyTask daily) async {
    try {
      await _dailiesCollection.doc(daily.id).update(daily.toJson());
      dev.log('Updated daily task: ${daily.title}');
    } catch (e) {
      dev.log('Error updating daily task: $e');
      throw 'Failed to update daily task';
    }
  }

  // Delete daily task
  Future<void> deleteDaily(String dailyId) async {
    try {
      await _dailiesCollection.doc(dailyId).delete();
      dev.log('Deleted daily task: $dailyId');
    } catch (e) {
      dev.log('Error deleting daily task: $e');
      throw 'Failed to delete daily task';
    }
  }

  // Mark daily as complete
  Future<void> markDailyComplete(String dailyId) async {
    try {
      final now = DateTime.now();
      await _dailiesCollection.doc(dailyId).update({
        'isCompleted': true,
        'completionHistory': FieldValue.arrayUnion([now.toIso8601String()]),
      });
      dev.log('Marked daily task complete: $dailyId');
    } catch (e) {
      dev.log('Error marking daily task complete: $e');
      throw 'Failed to mark daily task complete';
    }
  }

  // Unmark daily as complete
  Future<void> unmarkDailyComplete(String dailyId) async {
    try {
      await _dailiesCollection.doc(dailyId).update({
        'isCompleted': false,
      });
      dev.log('Unmarked daily task complete: $dailyId');
    } catch (e) {
      dev.log('Error unmarking daily task complete: $e');
      throw 'Failed to unmark daily task complete';
    }
  }

  // Get daily task statistics
  Future<Map<String, dynamic>> getDailyStats(String dailyId) async {
    try {
      final doc = await _dailiesCollection.doc(dailyId).get();
      final dailyData = doc.data() as Map<String, dynamic>;
      
      final completionHistory = (dailyData['completionHistory'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList() ?? [];
      
      final now = DateTime.now();
      
      final thisMonth = completionHistory.where((date) => 
        date.year == now.year && date.month == now.month
      ).length;
      
      return {
        'totalCompletions': completionHistory.length,
        'thisMonth': thisMonth,
        'currentStreak': dailyData['currentStreak'] ?? 0,
        'bestStreak': dailyData['bestStreak'] ?? 0,
      };
    } catch (e) {
      dev.log('Error getting daily task stats: $e');
      throw 'Failed to get daily task statistics';
    }
  }
} 