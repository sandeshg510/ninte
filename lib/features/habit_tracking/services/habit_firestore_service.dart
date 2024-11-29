import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;
import '../models/habit.dart';

class HabitFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _habitsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw 'User not authenticated';
    
    return _firestore.collection('users')
        .doc(uid)
        .collection('habits');
  }

  // Create new habit
  Future<void> createHabit(Habit habit) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      await _habitsCollection.doc(habit.id).set(habit.toJson());
      dev.log('Created new habit: ${habit.name}');
    } catch (e) {
      dev.log('Error creating habit: $e');
      throw 'Failed to create habit: ${e.toString()}';
    }
  }

  // Get all habits
  Stream<List<Habit>> getHabits({bool includeArchived = false}) {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      Query query = _habitsCollection;
      
      if (!includeArchived) {
        query = query.where('isArchived', isEqualTo: false);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Habit.fromJson({...data, 'id': doc.id});
        }).toList();
      });
    } catch (e) {
      dev.log('Error getting habits: $e');
      throw 'Failed to get habits: ${e.toString()}';
    }
  }

  // Get archived habits
  Stream<List<Habit>> getArchivedHabits() {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      return _habitsCollection
          .where('isArchived', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Habit.fromJson({...data, 'id': doc.id});
        }).toList();
      });
    } catch (e) {
      dev.log('Error getting archived habits: $e');
      throw 'Failed to get archived habits: ${e.toString()}';
    }
  }

  // Update habit
  Future<void> updateHabit(Habit habit) async {
    try {
      await _habitsCollection.doc(habit.id).update(habit.toJson());
      dev.log('Updated habit: ${habit.name}');
    } catch (e) {
      dev.log('Error updating habit: $e');
      throw 'Failed to update habit';
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsCollection.doc(habitId).delete();
      dev.log('Deleted habit: $habitId');
    } catch (e) {
      dev.log('Error deleting habit: $e');
      throw 'Failed to delete habit';
    }
  }

  // Archive habit
  Future<void> archiveHabit(String habitId) async {
    try {
      await _habitsCollection.doc(habitId).update({'isArchived': true});
      dev.log('Archived habit: $habitId');
    } catch (e) {
      dev.log('Error archiving habit: $e');
      throw 'Failed to archive habit';
    }
  }

  // Mark habit as complete for today
  Future<void> markHabitComplete(String habitId) async {
    try {
      final now = DateTime.now();
      await _habitsCollection.doc(habitId).update({
        'completedDates': FieldValue.arrayUnion([now.toIso8601String()]),
        'lastCompletionDate': now.toIso8601String(),
      });
      
      // Also update user's streak data
      final userDoc = _firestore.collection('users').doc(_auth.currentUser?.uid);
      await userDoc.set({
        'lastCompletionDate': now.toIso8601String(),
      }, SetOptions(merge: true));
      
      dev.log('Marked habit complete: $habitId');
    } catch (e) {
      dev.log('Error marking habit complete: $e');
      throw 'Failed to mark habit complete';
    }
  }

  // Get habit statistics
  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    try {
      final doc = await _habitsCollection.doc(habitId).get();
      final habitData = doc.data() as Map<String, dynamic>;
      
      final completedDates = (habitData['completedDates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList() ?? [];
      
      final now = DateTime.now();
      
      final thisMonth = completedDates.where((date) => 
        date.year == now.year && date.month == now.month
      ).length;
      
      final lastMonth = completedDates.where((date) => 
        (date.year == now.year && date.month == now.month - 1) ||
        (now.month == 1 && date.year == now.year - 1 && date.month == 12)
      ).length;

      return {
        'totalCompletions': completedDates.length,
        'thisMonth': thisMonth,
        'lastMonth': lastMonth,
        'currentStreak': habitData['currentStreak'] ?? 0,
        'bestStreak': habitData['bestStreak'] ?? 0,
        'lastCompletionDate': habitData['lastCompletionDate'],
      };
    } catch (e) {
      dev.log('Error getting habit stats: $e');
      throw 'Failed to get habit statistics';
    }
  }

  // Add this method to HabitFirestoreService
  Future<void> unarchiveHabit(String habitId) async {
    try {
      await _habitsCollection.doc(habitId).update({'isArchived': false});
      dev.log('Unarchived habit: $habitId');
    } catch (e) {
      dev.log('Error unarchiving habit: $e');
      throw 'Failed to unarchive habit';
    }
  }

  // Add this method
  Future<void> updateStreaks({
    required int currentStreak,
    required int bestStreak,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'currentStreak': currentStreak,
          'bestStreak': bestStreak,
        });
    } catch (e) {
      dev.log('Error updating streaks: $e');
      throw 'Failed to update streaks';
    }
  }
} 