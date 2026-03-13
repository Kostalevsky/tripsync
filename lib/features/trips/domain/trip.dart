class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.dateRange,
    required this.coverEmoji,
    required this.members,
    required this.totalBudget,
    required this.spentBudget,
    required this.votedPlacesCount,
    required this.plannedActivitiesCount,
    required this.colorSeed,
  });

  final String id;
  final String title;
  final String destination;
  final String dateRange;
  final String coverEmoji;
  final List<TripMember> members;
  final double totalBudget;
  final double spentBudget;
  final int votedPlacesCount;
  final int plannedActivitiesCount;
  final int colorSeed;

  double get budgetProgress {
    if (totalBudget == 0) return 0;
    return (spentBudget / totalBudget).clamp(0, 1);
  }
}

class TripMember {
  const TripMember({
    required this.id,
    required this.name,
    required this.avatar,
  });

  final String id;
  final String name;
  final String avatar;
}