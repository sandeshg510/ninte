import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:developer' as dev;
import '../services/daily_firestore_service.dart';
import '../models/daily_task.dart';
import 'daily_state.dart';

class DailyNotifier extends StateNotifier<DailyState> {
  final DailyFirestoreService _firestoreService;
  StreamSubscription? _dailiesSubscription;

  DailyNotifier(this._firestoreService) : super(const DailyState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      
      dev.log('Initializing daily tasks stream...');
      
      // Listen to dailies stream
      _dailiesSubscription = _firestoreService.getDailies().listen(
        (dailies) {
          dev.log('Received ${dailies.length} daily tasks from Firestore');
          state = state.copyWith(
            dailyTasks: dailies,
            isLoading: false,
            error: null,
          );
          _loadDailyStats();
        },
        onError: (error) {
          dev.log('Error in daily tasks stream: $error');
          state = state.copyWith(
            error: error.toString(),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      dev.log('Error initializing daily tasks: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createDaily(DailyTask daily) async {
    try {
      dev.log('Creating new daily task...');
      await _firestoreService.createDaily(daily);
      dev.log('Daily task created successfully');
    } catch (e) {
      dev.log('Error creating daily task: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDaily(DailyTask daily) async {
    try {
      await _firestoreService.updateDaily(daily);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDaily(String dailyId) async {
    try {
      await _firestoreService.deleteDaily(dailyId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDailyComplete(String dailyId) async {
    try {
      await _firestoreService.markDailyComplete(dailyId);
      await _loadDailyStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _loadDailyStats() async {
    try {
      final newStats = <String, Map<String, dynamic>>{};
      
      for (final daily in state.dailyTasks) {
        final stats = await _firestoreService.getDailyStats(daily.id);
        newStats[daily.id] = stats;
      }
      
      state = state.copyWith(dailyStats: newStats);
    } catch (e) {
      dev.log('Error loading daily stats: $e');
    }
  }

  Future<void> toggleDailyComplete(String dailyId, bool isCompleted) async {
    try {
      if (isCompleted) {
        await _firestoreService.markDailyComplete(dailyId);
      } else {
        await _firestoreService.unmarkDailyComplete(dailyId);
      }
      await _loadDailyStats();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _dailiesSubscription?.cancel();
    super.dispose();
  }
}

// Main provider
final dailyProvider = StateNotifierProvider<DailyNotifier, DailyState>((ref) {
  return DailyNotifier(DailyFirestoreService());
});

// Convenience providers
final dueDailiesProvider = Provider<List<DailyTask>>((ref) {
  return ref.watch(dailyProvider).dueTasks;
});

final completedDailiesProvider = Provider<List<DailyTask>>((ref) {
  return ref.watch(dailyProvider).completedTasks;
});

final overdueDailiesProvider = Provider<List<DailyTask>>((ref) {
  return ref.watch(dailyProvider).overdueTasks;
});

// Provider for dailies by category
final dailiesByCategoryProvider = Provider.family<List<DailyTask>, DailyCategory>((ref, category) {
  return ref.watch(dailyProvider).getTasksByCategory(category);
});

// Provider for daily statistics
final dailyStatsProvider = Provider.family<Map<String, dynamic>?, String>((ref, dailyId) {
  return ref.watch(dailyProvider).dailyStats[dailyId];
});

// Provider for loading state
final dailyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dailyProvider).isLoading;
});

// Provider for error state
final dailyErrorProvider = Provider<String?>((ref) {
  return ref.watch(dailyProvider).error;
});

// Provider for today's progress
final dailyProgressProvider = Provider<double>((ref) {
  return ref.watch(dailyProvider).completionRateToday;
});

// Add this provider
final dailySortOptionProvider = StateProvider<DailySortOption>((ref) {
  return DailySortOption.dueTime;
});

// Add this provider for sorted tasks
final sortedDailiesProvider = Provider<List<DailyTask>>((ref) {
  final sortOption = ref.watch(dailySortOptionProvider);
  return ref.watch(dailyProvider).getSortedTasks(sortOption);
}); 