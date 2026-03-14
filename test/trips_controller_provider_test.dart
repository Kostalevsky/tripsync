import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/trips/state/trips_controller.dart';
import 'package:tripsync/features/trips/domain/trip.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  Trip createTestTrip(String id, String title) {
    return Trip(
      id: id,
      title: title,
      destination: 'Test Destination',
      dateRange: '1–5 May',
      coverEmoji: '🌍',
      members: const [],
      totalBudget: 1000,
      spentBudget: 0,
      votedPlacesCount: 0,
      plannedActivitiesCount: 0,
      colorSeed: 1,
    );
  }

  test('initial state contains seed trips', () {
    final trips = container.read(tripsControllerProvider);

    expect(trips.length, greaterThan(0));
  });

  test('addTrip increases number of trips', () {
    final controller = container.read(tripsControllerProvider.notifier);

    final initialLength = container.read(tripsControllerProvider).length;

    final trip = createTestTrip('trip1', 'Paris Trip');

    controller.addTrip(trip);

    final trips = container.read(tripsControllerProvider);

    expect(trips.length, initialLength + 1);
  });

  test('addTrip inserts trip at beginning of list', () {
    final controller = container.read(tripsControllerProvider.notifier);

    final trip = createTestTrip('new_trip', 'Newest Trip');

    controller.addTrip(trip);

    final trips = container.read(tripsControllerProvider);

    expect(trips.first.id, 'new_trip');
  });

  test('getById returns correct trip', () {
    final controller = container.read(tripsControllerProvider.notifier);

    final trip = createTestTrip('find_me', 'Find Me');

    controller.addTrip(trip);

    final found = controller.getById('find_me');

    expect(found, isNotNull);
    expect(found!.title, 'Find Me');
  });

  test('getById returns null for unknown trip', () {
    final controller = container.read(tripsControllerProvider.notifier);

    final result = controller.getById('unknown_trip');

    expect(result, isNull);
  });

  test('deleteTrip removes trip from state', () {
    final controller = container.read(tripsControllerProvider.notifier);

    final trip = createTestTrip('delete_me', 'Delete Me');

    controller.addTrip(trip);

    controller.deleteTrip('delete_me');

    final trips = container.read(tripsControllerProvider);

    final found = trips.where((t) => t.id == 'delete_me');

    expect(found, isEmpty);
  });
}
