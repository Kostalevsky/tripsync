import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/planner/domain/planned_activity.dart';

final plannerControllerProvider = StateNotifierProvider<PlannerController,
    Map<String, Map<String, List<PlannedActivity>>>>(
  (ref) => PlannerController(),
);

class PlannerController
    extends StateNotifier<Map<String, Map<String, List<PlannedActivity>>>> {
  PlannerController() : super(_demoPlanner);

  Map<String, List<PlannedActivity>> getDaysForTrip(String tripId) {
    return state[tripId] ?? const <String, List<PlannedActivity>>{};
  }

  void ensureTripExists(String tripId) {
    if (state.containsKey(tripId)) return;

    state = {
      ...state,
      tripId: <String, List<PlannedActivity>>{},
    };
  }

  void addDay({
    required String tripId,
    required String dayTitle,
  }) {
    final trimmed = dayTitle.trim();
    if (trimmed.isEmpty) return;

    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };

    if (currentTrip.containsKey(trimmed)) return;

    currentTrip[trimmed] = <PlannedActivity>[];

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void deleteDay({
    required String tripId,
    required String dayKey,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };

    currentTrip.remove(dayKey);

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void addActivity({
    required String tripId,
    required String dayKey,
    required PlannedActivity activity,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };
    final activities = [...(currentTrip[dayKey] ?? const <PlannedActivity>[])];

    activities.add(activity);
    currentTrip[dayKey] = activities;

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void updateActivity({
    required String tripId,
    required String dayKey,
    required PlannedActivity updated,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };
    final activities = [...(currentTrip[dayKey] ?? const <PlannedActivity>[])];

    final index = activities.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;

    activities[index] = updated;
    currentTrip[dayKey] = activities;

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void deleteActivity({
    required String tripId,
    required String dayKey,
    required String activityId,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };
    final activities = [...(currentTrip[dayKey] ?? const <PlannedActivity>[])];

    activities.removeWhere((a) => a.id == activityId);
    currentTrip[dayKey] = activities;

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void reorderActivities({
    required String tripId,
    required String dayKey,
    required int oldIndex,
    required int newIndex,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };
    final activities = [...(currentTrip[dayKey] ?? const <PlannedActivity>[])];

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = activities.removeAt(oldIndex);
    activities.insert(newIndex, item);

    currentTrip[dayKey] = activities;
    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  void increaseDuration({
    required String tripId,
    required String dayKey,
    required String activityId,
  }) {
    _updateDuration(
      tripId: tripId,
      dayKey: dayKey,
      activityId: activityId,
      delta: 30,
    );
  }

  void decreaseDuration({
    required String tripId,
    required String dayKey,
    required String activityId,
  }) {
    _updateDuration(
      tripId: tripId,
      dayKey: dayKey,
      activityId: activityId,
      delta: -30,
    );
  }

  void _updateDuration({
    required String tripId,
    required String dayKey,
    required String activityId,
    required int delta,
  }) {
    final currentTrip = {
      ...(state[tripId] ?? const <String, List<PlannedActivity>>{})
    };
    final activities = [...(currentTrip[dayKey] ?? const <PlannedActivity>[])];
    final index = activities.indexWhere((a) => a.id == activityId);

    if (index == -1) return;

    final activity = activities[index];
    final nextDuration = (activity.durationMinutes + delta).clamp(30, 300);

    activities[index] = activity.copyWith(durationMinutes: nextDuration);
    currentTrip[dayKey] = activities;

    state = {
      ...state,
      tripId: currentTrip,
    };
  }

  static final Map<String, Map<String, List<PlannedActivity>>> _demoPlanner = {
    'trip_amsterdam': {
      '12 апр': const [
        PlannedActivity(
          id: 'a1',
          title: 'Завтрак в Bakers & Roasters',
          location: 'De Pijp',
          startTime: '09:00',
          durationMinutes: 90,
          emoji: '☕',
        ),
        PlannedActivity(
          id: 'a2',
          title: 'Rijksmuseum',
          location: 'Museumplein',
          startTime: '11:00',
          durationMinutes: 120,
          emoji: '🖼️',
        ),
        PlannedActivity(
          id: 'a3',
          title: 'Круиз по каналам',
          location: 'City Center',
          startTime: '15:00',
          durationMinutes: 90,
          emoji: '🛶',
        ),
      ],
      '13 апр': const [
        PlannedActivity(
          id: 'a4',
          title: 'Велопрогулка',
          location: 'Vondelpark',
          startTime: '10:00',
          durationMinutes: 60,
          emoji: '🚲',
        ),
        PlannedActivity(
          id: 'a5',
          title: 'Foodhallen',
          location: 'Oud-West',
          startTime: '13:00',
          durationMinutes: 90,
          emoji: '🍜',
        ),
      ],
    },
    'trip_barcelona': {
      '2 июн': const [
        PlannedActivity(
          id: 'b1',
          title: 'Sagrada Família',
          location: 'Eixample',
          startTime: '10:00',
          durationMinutes: 120,
          emoji: '⛪',
        ),
        PlannedActivity(
          id: 'b2',
          title: 'Обед на рынке',
          location: 'La Boqueria',
          startTime: '13:30',
          durationMinutes: 60,
          emoji: '🥘',
        ),
      ],
    },
    'trip_tokyo': {
      '18 сен': const [
        PlannedActivity(
          id: 't1',
          title: 'Завтрак на Tsukiji',
          location: 'Chuo City',
          startTime: '08:30',
          durationMinutes: 60,
          emoji: '🍣',
        ),
        PlannedActivity(
          id: 't2',
          title: 'teamLab Planets',
          location: 'Toyosu',
          startTime: '11:00',
          durationMinutes: 120,
          emoji: '✨',
        ),
        PlannedActivity(
          id: 't3',
          title: 'Shibuya Sky',
          location: 'Shibuya',
          startTime: '18:00',
          durationMinutes: 90,
          emoji: '🌃',
        ),
      ],
    },
  };
}