import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/user_profile.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/models/achievement.dart';
import 'dart:convert';

class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final String _storageKey = 'habits';
  final String _userKey = 'user_profile';

  List<Habit> _habits = [];
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadHabits();
      await _loadUserProfile();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_storageKey);
    if (habitsJson != null) {
      _habits =
          habitsJson.map((json) => Habit.fromJson(jsonDecode(json))).toList();
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _userProfile = UserProfile.fromJson(jsonDecode(userJson));
    } else {
      // Create a default user profile if none exists
      _userProfile = UserProfile(
        email: 'user@example.com',
        displayName: 'User',
        statistics: {
          'totalCompletions': 0,
          'bestStreak': 0,
          'activeHabits': 0,
        },
        achievements: [],
        preferences: {
          'theme': 'dark',
          'notifications': true,
        },
      );
      await _saveUserProfile();
    }
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson =
        _habits.map((habit) => jsonEncode(habit.toJson())).toList();
    await prefs.setStringList(_storageKey, habitsJson);
  }

  Future<void> _saveUserProfile() async {
    if (_userProfile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_userProfile!.toJson()));
    }
  }

  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      _userProfile = updatedProfile;
      await _saveUserProfile();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      _habits.add(habit);
      await _saveHabits();
      notifyListeners();

      // Schedule reminder if set
      if (habit.reminders.isNotEmpty) {
        for (var reminder in habit.reminders.entries) {
          await _notificationService.scheduleHabitReminder(
            habitId: habit.id,
            title: habit.title,
            scheduledTime: reminder.value,
          );
        }
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _checkAndUpdateAchievements(int streakDays) async {
    if (_userProfile == null) return;

    final currentAchievements = Set<String>.from(_userProfile!.achievements);
    bool achievementUnlocked = false;

    for (final milestone in Achievement.streakMilestones) {
      if (streakDays >= milestone.daysRequired &&
          !currentAchievements.contains(milestone.id)) {
        currentAchievements.add(milestone.id);
        achievementUnlocked = true;

        // Show achievement notification
        await _notificationService.createNotification(
          id: milestone.id.hashCode,
          title: '🏆 Achievement Unlocked!',
          body: '${milestone.title}: ${milestone.description}',
        );
      }
    }

    if (achievementUnlocked) {
      _userProfile = _userProfile!.copyWith(
        achievements: currentAchievements.toList(),
      );
      await _saveUserProfile();
      notifyListeners();
    }
  }

  Future<void> recordRelapse(String habitId, {String? note}) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final habit = _habits[index];
        final now = DateTime.now();

        // Calculate the streak before relapse
        final streakDuration = habit.getStreakDuration();
        final streakDays = streakDuration.inDays;

        // Update best streak if current streak is better
        final newBestStreak =
            streakDays > habit.bestStreak ? streakDays : habit.bestStreak;

        // Create a relapse note
        final relapseNote = HabitNote(
          date: now,
          content: note?.trim() ?? '',
          isRelapse: true,
        );

        final updatedHabit = habit.copyWith(
          lastRelapseDate: now,
          relapseDates: [...habit.relapseDates, now],
          notes: [...habit.notes, relapseNote],
          bestStreak: newBestStreak,
        );

        await updateHabit(updatedHabit);

        // Update user statistics
        if (_userProfile != null) {
          final stats = Map<String, int>.from(_userProfile!.statistics);
          if (streakDays > (stats['bestStreak'] ?? 0)) {
            stats['bestStreak'] = streakDays;
          }
          _userProfile = _userProfile!.copyWith(statistics: stats);
          await _saveUserProfile();
        }

        // Check for achievements based on the streak
        await _checkAndUpdateAchievements(streakDays);

        // Send a supportive notification
        await _notificationService.scheduleStreakNotification(
          habitId: habitId,
          title: 'Keep Going!',
          streak: 0,
        );
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> restartHabit(String habitId) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final habit = _habits[index];
        final now = DateTime.now();

        final updatedHabit = habit.copyWith(
          startDate: now,
          lastRelapseDate: null,
        );

        await updateHabit(updatedHabit);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  List<Habit> getHabitsByCategory(HabitCategory category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  List<Habit> getHabitsByPriority(HabitPriority priority) {
    return _habits.where((habit) => habit.priority == priority).toList();
  }

  double getOverallProgress() {
    if (_habits.isEmpty) return 0.0;
    var totalDuration = Duration.zero;
    for (var habit in _habits) {
      totalDuration += habit.getStreakDuration();
    }
    return totalDuration.inHours / (_habits.length * 24); // Average days
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        await _saveHabits();

        // Check for achievements based on current streak
        final streakDays = habit.getStreakDuration().inDays;
        await _checkAndUpdateAchievements(streakDays);

        notifyListeners();

        // Update reminders
        await _notificationService.cancelHabitReminder(habit.id);
        if (habit.reminders.isNotEmpty) {
          for (var reminder in habit.reminders.entries) {
            await _notificationService.scheduleHabitReminder(
              habitId: habit.id,
              title: habit.title,
              scheduledTime: reminder.value,
            );
          }
        }
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      _habits.removeWhere((h) => h.id == habitId);
      await _saveHabits();
      await _notificationService.cancelHabitReminder(habitId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
}
