import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/bookings/domain/booking_item.dart';

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, Map<String, List<BookingItem>>>(
      (ref) => BookingsController(),
    );

class BookingsController extends StateNotifier<Map<String, List<BookingItem>>> {
  BookingsController() : super(_demoBookings);

  List<BookingItem> getBookingsForTrip(String tripId) {
    return state[tripId] ?? const <BookingItem>[];
  }

  void addBooking({required String tripId, required BookingItem booking}) {
    final current = [...(state[tripId] ?? const <BookingItem>[])];
    current.insert(0, booking);

    state = {...state, tripId: current};
  }

  void updateBooking({
    required String tripId,
    required BookingItem updatedBooking,
  }) {
    final current = [...(state[tripId] ?? const <BookingItem>[])];
    final index = current.indexWhere((b) => b.id == updatedBooking.id);
    if (index == -1) return;

    current[index] = updatedBooking;

    state = {...state, tripId: current};
  }

  void deleteBooking({required String tripId, required String bookingId}) {
    final current = [...(state[tripId] ?? const <BookingItem>[])];
    current.removeWhere((b) => b.id == bookingId);

    state = {...state, tripId: current};
  }

  static final Map<String, List<BookingItem>> _demoBookings = {
    'trip_amsterdam': const [
      BookingItem(
        id: 'bk1',
        title: 'Авиабилеты AMS',
        type: 'Авиабилеты',
        details: 'KLM • Москва → Амстердам',
        status: 'Забронировано',
        dateLabel: '12 апр 2026',
        emoji: '✈️',
      ),
      BookingItem(
        id: 'bk2',
        title: 'Апартаменты в центре',
        type: 'Жильё',
        details: '4 гостя • бесплатная отмена',
        status: 'Забронировано',
        dateLabel: '12–16 апр 2026',
        emoji: '🏠',
      ),
    ],
    'trip_barcelona': const [
      BookingItem(
        id: 'bk3',
        title: 'Отель у пляжа',
        type: 'Жильё',
        details: 'Barcelona Beach Stay',
        status: 'Ожидает',
        dateLabel: '2–8 июн 2026',
        emoji: '🏨',
      ),
    ],
    'trip_tokyo': const [
      BookingItem(
        id: 'bk4',
        title: 'Трансфер из аэропорта',
        type: 'Трансфер',
        details: 'Narita Express',
        status: 'Черновик',
        dateLabel: '18 сен 2026',
        emoji: '🚄',
      ),
    ],
  };
}
