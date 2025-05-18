import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum HabitCategory { health, work, learning, fitness, mindfulness, other }

enum HabitPriority { low, medium, high }

class HabitNote {
  final String id;
  final DateTime date;
  final String content;
  final double? rating;
  final bool isRelapse;

  HabitNote({
    String? id,
    required this.date,
    String? content,
    this.rating,
    this.isRelapse = false,
  })  : id = id ?? const Uuid().v4(),
        content = content?.trim() ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'rating': rating,
        'isRelapse': isRelapse,
      };

  factory HabitNote.fromJson(Map<String, dynamic> json) => HabitNote(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String? ?? '',
        rating: json['rating'] as double?,
        isRelapse: json['isRelapse'] as bool? ?? false,
      );
}

class Habit {
  final String id;
  final String title;
  final IconData icon;
  final String userId;
  final HabitCategory category;
  final HabitPriority priority;
  final DateTime startDate;
  final DateTime? lastRelapseDate;
  final Map<String, DateTime> reminders;
  final DateTime createdAt;
  final int currentStreak;
  final int bestStreak;
  final List<HabitNote> notes;
  final String? motivationMessage;
  final bool streakFrozen;
  final List<DateTime> relapseDates;

  static const List<String> defaultMotivationMessages = [
    "You're doing great! Keep going! 🚀",
    "Every small step counts towards your goal! 🎯",
    "Stay consistent, stay awesome! ✨",
    "You've got this! Keep pushing! 💪",
    "Building better habits, one day at a time! 🌱",
    "Your future self will thank you! 🙏",
    "Progress over perfection! 📈",
    "Keep that streak alive! 🔥",
  ];

  Habit({
    String? id,
    required this.title,
    required this.icon,
    required this.userId,
    required this.category,
    this.priority = HabitPriority.medium,
    DateTime? startDate,
    this.lastRelapseDate,
    Map<String, DateTime>? reminders,
    DateTime? createdAt,
    int? currentStreak,
    this.bestStreak = 0,
    List<HabitNote>? notes,
    this.motivationMessage,
    this.streakFrozen = false,
    List<DateTime>? relapseDates,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        reminders = reminders ?? {},
        createdAt = createdAt ?? DateTime.now(),
        notes = notes ?? [],
        relapseDates = relapseDates ?? [],
        currentStreak = currentStreak ??
            _calculateCurrentStreak(
              startDate ?? DateTime.now(),
              lastRelapseDate,
            );

  static int _calculateCurrentStreak(DateTime start, DateTime? lastRelapse) {
    final now = DateTime.now();
    if (lastRelapse != null && lastRelapse.isAfter(start)) {
      return now.difference(lastRelapse).inDays;
    }
    return now.difference(start).inDays;
  }

  Habit copyWith({
    String? title,
    IconData? icon,
    String? userId,
    HabitCategory? category,
    HabitPriority? priority,
    DateTime? startDate,
    DateTime? lastRelapseDate,
    Map<String, DateTime>? reminders,
    DateTime? createdAt,
    int? currentStreak,
    int? bestStreak,
    List<HabitNote>? notes,
    String? motivationMessage,
    bool? streakFrozen,
    List<DateTime>? relapseDates,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      lastRelapseDate: lastRelapseDate ?? this.lastRelapseDate,
      reminders: reminders ?? this.reminders,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      notes: notes ?? this.notes,
      motivationMessage: motivationMessage ?? this.motivationMessage,
      streakFrozen: streakFrozen ?? this.streakFrozen,
      relapseDates: relapseDates ?? this.relapseDates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon.codePoint,
      'userId': userId,
      'category': category.name,
      'priority': priority.name,
      'startDate': startDate.toIso8601String(),
      'lastRelapseDate': lastRelapseDate?.toIso8601String(),
      'reminders':
          reminders.map((key, value) => MapEntry(key, value.toIso8601String())),
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'notes': notes.map((note) => note.toJson()).toList(),
      'motivationMessage': motivationMessage,
      'streakFrozen': streakFrozen,
      'relapseDates':
          relapseDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      userId: json['userId'] as String,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HabitCategory.other,
      ),
      priority: HabitPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => HabitPriority.medium,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      lastRelapseDate: json['lastRelapseDate'] != null
          ? DateTime.parse(json['lastRelapseDate'] as String)
          : null,
      reminders: (json['reminders'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, DateTime.parse(value as String)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      notes: (json['notes'] as List<dynamic>?)
              ?.map((note) => HabitNote.fromJson(note as Map<String, dynamic>))
              .toList() ??
          [],
      motivationMessage: json['motivationMessage'] as String?,
      streakFrozen: json['streakFrozen'] as bool? ?? false,
      relapseDates: (json['relapseDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date as String))
              .toList() ??
          [],
    );
  }

  Duration getStreakDuration() {
    final now = DateTime.now();
    if (lastRelapseDate != null && lastRelapseDate!.isAfter(startDate)) {
      return now.difference(lastRelapseDate!);
    }
    return now.difference(startDate);
  }

  String getFormattedStreakDuration() {
    final duration = getStreakDuration();
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days days, $hours hrs';
    } else if (hours > 0) {
      return '$hours hrs, $minutes mins';
    } else {
      return '$minutes minutes';
    }
  }

  bool hasActiveStreak() {
    return getStreakDuration().inMinutes > 0;
  }

  String getRandomMotivationMessage() {
    if (motivationMessage != null) return motivationMessage!;
    final random = DateTime.now().millisecondsSinceEpoch %
        defaultMotivationMessages.length;
    return defaultMotivationMessages[random];
  }
}
