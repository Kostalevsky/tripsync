class PlaceSuggestion {
  const PlaceSuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.emoji,
    required this.votes,
    required this.votedBy,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String emoji;
  final int votes;
  final List<String> votedBy;

  PlaceSuggestion copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? emoji,
    int? votes,
    List<String>? votedBy,
  }) {
    return PlaceSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      votes: votes ?? this.votes,
      votedBy: votedBy ?? this.votedBy,
    );
  }
}
