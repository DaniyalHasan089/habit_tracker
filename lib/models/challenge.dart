import 'package:uuid/uuid.dart';

enum ChallengeStatus { notStarted, inProgress, completed, failed }

class Challenge {
  final String id;
  final String title;
  final String description;
  final int durationInDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> habitIds;
  final ChallengeStatus status;
  final Map<String, List<DateTime>>
      completedDates; // habitId -> completion dates
  final String? motivationMessage;

  static const List<String> defaultChallenges = [
    "30 Days of Meditation 🧘‍♂️",
    "Fitness First - 21 Day Challenge 💪",
    "Reading Challenge - 2 Weeks 📚",
    "Healthy Eating - 30 Days 🥗",
    "Early Bird - 21 Days 🌅",
  ];

  Challenge({
    String? id,
    required this.title,
    required this.description,
    required this.durationInDays,
    this.startDate,
    this.endDate,
    List<String>? habitIds,
    this.status = ChallengeStatus.notStarted,
    Map<String, List<DateTime>>? completedDates,
    this.motivationMessage,
  })  : id = id ?? const Uuid().v4(),
        habitIds = habitIds ?? [],
        completedDates = completedDates ?? {};

  Challenge copyWith({
    String? title,
    String? description,
    int? durationInDays,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? habitIds,
    ChallengeStatus? status,
    Map<String, List<DateTime>>? completedDates,
    String? motivationMessage,
  }) {
    return Challenge(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationInDays: durationInDays ?? this.durationInDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      habitIds: habitIds ?? this.habitIds,
      status: status ?? this.status,
      completedDates: completedDates ?? this.completedDates,
      motivationMessage: motivationMessage ?? this.motivationMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationInDays': durationInDays,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'habitIds': habitIds,
      'status': status.name,
      'completedDates': completedDates.map(
        (key, value) => MapEntry(
          key,
          value.map((date) => date.toIso8601String()).toList(),
        ),
      ),
      'motivationMessage': motivationMessage,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationInDays: json['durationInDays'] as int,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      habitIds: (json['habitIds'] as List<dynamic>).cast<String>(),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.notStarted,
      ),
      completedDates: (json['completedDates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((date) => DateTime.parse(date as String))
              .toList(),
        ),
      ),
      motivationMessage: json['motivationMessage'] as String?,
    );
  }

  double getCompletionRate() {
    if (startDate == null || habitIds.isEmpty) return 0.0;

    final now = DateTime.now();
    final totalDays = now.difference(startDate!).inDays + 1;
    final totalPossibleCompletions = totalDays * habitIds.length;

    if (totalPossibleCompletions == 0) return 0.0;

    final totalCompletions = completedDates.values
        .expand((dates) => dates)
        .where((date) => date.isAfter(startDate!) && date.isBefore(now))
        .length;

    return totalCompletions / totalPossibleCompletions;
  }

  bool isActive() {
    if (startDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(startDate!) &&
        (endDate == null || now.isBefore(endDate!)) &&
        status == ChallengeStatus.inProgress;
  }

  int getDaysRemaining() {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  static Challenge createDefaultChallenge(
    String title, {
    int durationInDays = 30,
    String? description,
    String? motivationMessage,
  }) {
    return Challenge(
      title: title,
      description: description ??
          'Take on the $title challenge for $durationInDays days!',
      durationInDays: durationInDays,
      motivationMessage: motivationMessage,
    );
  }
}
