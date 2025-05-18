import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int daysRequired;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.daysRequired,
    this.unlockedAt,
  });

  static const List<Achievement> streakMilestones = [
    Achievement(
      id: 'day_1',
      title: 'First Step',
      description: 'Maintained a habit for 1 day',
      icon: Icons.emoji_events,
      daysRequired: 1,
    ),
    Achievement(
      id: 'day_2',
      title: 'Getting Started',
      description: 'Maintained a habit for 2 days',
      icon: Icons.emoji_events,
      daysRequired: 2,
    ),
    Achievement(
      id: 'day_3',
      title: 'Three in a Row',
      description: 'Maintained a habit for 3 days',
      icon: Icons.emoji_events,
      daysRequired: 3,
    ),
    Achievement(
      id: 'day_5',
      title: 'High Five',
      description: 'Maintained a habit for 5 days',
      icon: Icons.emoji_events,
      daysRequired: 5,
    ),
    Achievement(
      id: 'week_1',
      title: 'Week Warrior',
      description: 'Maintained a habit for 7 days',
      icon: Icons.workspace_premium,
      daysRequired: 7,
    ),
    Achievement(
      id: 'day_10',
      title: 'Perfect Ten',
      description: 'Maintained a habit for 10 days',
      icon: Icons.workspace_premium,
      daysRequired: 10,
    ),
    Achievement(
      id: 'day_15',
      title: 'Unstoppable',
      description: 'Maintained a habit for 15 days',
      icon: Icons.military_tech,
      daysRequired: 15,
    ),
    Achievement(
      id: 'month_1',
      title: 'Habit Master',
      description: 'Maintained a habit for 30 days',
      icon: Icons.military_tech,
      daysRequired: 30,
    ),
  ];

  Achievement copyWith({DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      daysRequired: daysRequired,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'daysRequired': daysRequired,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      daysRequired: json['daysRequired'] as int,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}
