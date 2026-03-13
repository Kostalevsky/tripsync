import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/trips/domain/trip.dart';

final tripsControllerProvider =
    StateNotifierProvider<TripsController, List<Trip>>((ref) {
  return TripsController();
});

final selectedTripProvider = Provider<Trip?>((ref) {
  final trips = ref.watch(tripsControllerProvider);
  if (trips.isEmpty) return null;
  return trips.first;
});

class TripsController extends StateNotifier<List<Trip>> {
  TripsController() : super(_demoTrips);

  void addTrip(Trip trip) {
    state = [trip, ...state];
  }

  Trip? getById(String id) {
    try {
      return state.firstWhere((trip) => trip.id == id);
    } catch (_) {
      return null;
    }
  }

  static final List<Trip> _demoTrips = [
    Trip(
      id: 'trip_amsterdam',
      title: 'Весенний Амстердам',
      destination: 'Амстердам, Нидерланды',
      dateRange: '12–16 апр 2026',
      coverEmoji: '🌷',
      members: const [
        TripMember(id: '1', name: 'Джойти', avatar: '🧑🏽‍💻'),
        TripMember(id: '2', name: 'Анна', avatar: '👩🏻'),
        TripMember(id: '3', name: 'Лео', avatar: '🧔🏼'),
        TripMember(id: '4', name: 'Мия', avatar: '👩🏾'),
      ],
      totalBudget: 2200,
      spentBudget: 1480,
      votedPlacesCount: 12,
      plannedActivitiesCount: 9,
      colorSeed: 0,
    ),
    Trip(
      id: 'trip_barcelona',
      title: 'Барселона: еда и солнце',
      destination: 'Барселона, Испания',
      dateRange: '02–08 июн 2026',
      coverEmoji: '🌞',
      members: const [
        TripMember(id: '1', name: 'Джойти', avatar: '🧑🏽‍💻'),
        TripMember(id: '5', name: 'Крис', avatar: '🧑🏻'),
        TripMember(id: '6', name: 'София', avatar: '👱🏻‍♀️'),
      ],
      totalBudget: 1800,
      spentBudget: 620,
      votedPlacesCount: 8,
      plannedActivitiesCount: 5,
      colorSeed: 1,
    ),
    Trip(
      id: 'trip_tokyo',
      title: 'Огни Токио',
      destination: 'Токио, Япония',
      dateRange: '18–25 сен 2026',
      coverEmoji: '🗼',
      members: const [
        TripMember(id: '1', name: 'Джойти', avatar: '🧑🏽‍💻'),
        TripMember(id: '7', name: 'Ноа', avatar: '🧑🏾'),
        TripMember(id: '8', name: 'Эми', avatar: '👩🏻‍🦰'),
        TripMember(id: '9', name: 'Кай', avatar: '🧑🏻‍🎤'),
        TripMember(id: '10', name: 'Зои', avatar: '👩🏿'),
      ],
      totalBudget: 4200,
      spentBudget: 950,
      votedPlacesCount: 15,
      plannedActivitiesCount: 11,
      colorSeed: 2,
    ),
  ];
}