class BookingItem {
  const BookingItem({
    required this.id,
    required this.title,
    required this.type,
    required this.details,
    required this.status,
    required this.dateLabel,
    required this.emoji,
  });

  final String id;
  final String title;
  final String type;
  final String details;
  final String status;
  final String dateLabel;
  final String emoji;

  BookingItem copyWith({
    String? id,
    String? title,
    String? type,
    String? details,
    String? status,
    String? dateLabel,
    String? emoji,
  }) {
    return BookingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      details: details ?? this.details,
      status: status ?? this.status,
      dateLabel: dateLabel ?? this.dateLabel,
      emoji: emoji ?? this.emoji,
    );
  }
}