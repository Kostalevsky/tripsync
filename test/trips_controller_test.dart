import 'package:flutter_test/flutter_test.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';
import 'package:tripsync/features/trips/domain/trip.dart';

void main() {
  // setUp(() {
  //   late TripsController controller = TripsController();
  // });

  test('addTrip adds new trip to the beginning of the list', () {
    final controller = TripsController();

    final trip = Trip(
      id: 'trip_test',
      title: 'Test Trip',
      destination: 'Paris',
      dateRange: '1–5 May',
      coverEmoji: '🗼',
      members: const [],
      totalBudget: 1000,
      spentBudget: 0,
      votedPlacesCount: 0,
      plannedActivitiesCount: 0,
      colorSeed: 1,
    );

    controller.addTrip(trip);

    expect(controller.state.first.id, 'trip_test');
  });

  test('deleteTrip removes trip by id', () {
    final controller = TripsController();

    final trip = Trip(
      id: 'delete_trip',
      title: 'Delete Me',
      destination: 'Rome',
      dateRange: '1–2 Jun',
      coverEmoji: '🏛',
      members: const [],
      totalBudget: 500,
      spentBudget: 0,
      votedPlacesCount: 0,
      plannedActivitiesCount: 0,
      colorSeed: 2,
    );

    controller.addTrip(trip);

    controller.deleteTrip('delete_trip');

    final found = controller.getById('delete_trip');

    expect(found, isNull);
  });

  test('getById returns correct trip', () {
    final controller = TripsController();

    final trip = Trip(
      id: 'find_trip',
      title: 'Find Me',
      destination: 'Berlin',
      dateRange: '10–12 Jul',
      coverEmoji: '🇩🇪',
      members: const [],
      totalBudget: 800,
      spentBudget: 0,
      votedPlacesCount: 0,
      plannedActivitiesCount: 0,
      colorSeed: 3,
    );

    controller.addTrip(trip);

    final result = controller.getById('find_trip');

    expect(result, isNotNull);
    expect(result!.title, 'Find Me');
  });
}
