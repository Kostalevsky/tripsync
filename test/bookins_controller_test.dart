import 'package:flutter_test/flutter_test.dart';
import 'package:tripsync/features/bookings/state/bookings_controller.dart';
import 'package:tripsync/features/bookings/domain/booking_item.dart';

void main() {
  late BookingsController controller;

  setUp(() {
    controller = BookingsController();
  });

  test('getBookingsForTrip returns empty list for unknown trip', () {
    final result = controller.getBookingsForTrip('unknown_trip');

    expect(result, isEmpty);
  });

  test('addBooking adds booking to trip', () {
    final booking = BookingItem(
      id: 'test1',
      title: 'Test Booking',
      type: 'Hotel',
      details: 'Test details',
      status: 'Booked',
      dateLabel: '1 Jan',
      emoji: '🏨',
    );

    controller.addBooking(tripId: 'trip_test', booking: booking);

    final bookings = controller.getBookingsForTrip('trip_test');

    expect(bookings.length, 1);
    expect(bookings.first.id, 'test1');
  });

  test('updateBooking updates existing booking', () {
    final booking = BookingItem(
      id: 'test2',
      title: 'Old Title',
      type: 'Hotel',
      details: 'Test',
      status: 'Booked',
      dateLabel: '1 Jan',
      emoji: '🏨',
    );

    controller.addBooking(tripId: 'trip_test', booking: booking);

    final updated = BookingItem(
      id: 'test2',
      title: 'Updated Title',
      type: 'Hotel',
      details: 'Test',
      status: 'Booked',
      dateLabel: '1 Jan',
      emoji: '🏨',
    );

    controller.updateBooking(tripId: 'trip_test', updatedBooking: updated);

    final bookings = controller.getBookingsForTrip('trip_test');

    expect(bookings.first.title, 'Updated Title');
  });

  test('deleteBooking removes booking', () {
    final booking = BookingItem(
      id: 'test3',
      title: 'Delete me',
      type: 'Hotel',
      details: 'Test',
      status: 'Booked',
      dateLabel: '1 Jan',
      emoji: '🏨',
    );

    controller.addBooking(tripId: 'trip_test', booking: booking);

    controller.deleteBooking(tripId: 'trip_test', bookingId: 'test3');

    final bookings = controller.getBookingsForTrip('trip_test');

    expect(bookings, isEmpty);
  });
}
