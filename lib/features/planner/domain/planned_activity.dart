class PlannedActivity {
  const PlannedActivity({
    required this.id,
    required this.title,
    required this.location,
    required this.startTime,
    required this.durationMinutes,
    required this.emoji,
  });

  final String id;
  final String title;
  final String location;
  final String startTime;
  final int durationMinutes;
  final String emoji;

  PlannedActivity copyWith({
    String? id,
    String? title,
    String? location,
    String? startTime,
    int? durationMinutes,
    String? emoji,
  }) {
    return PlannedActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      emoji: emoji ?? this.emoji,
    );
  }
}