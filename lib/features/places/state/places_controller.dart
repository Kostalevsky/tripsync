import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsync/features/places/domain/place_suggestion.dart';

final placesControllerProvider =
    StateNotifierProvider<PlacesController, Map<String, List<PlaceSuggestion>>>(
      (ref) => PlacesController(),
    );

class PlacesController
    extends StateNotifier<Map<String, List<PlaceSuggestion>>> {
  PlacesController() : super(_demoPlaces);

  List<PlaceSuggestion> getPlacesForTrip(String tripId) {
    final places = state[tripId] ?? const <PlaceSuggestion>[];
    final sorted = [...places]..sort((a, b) => b.votes.compareTo(a.votes));
    return sorted;
  }

  void toggleVote({
    required String tripId,
    required String placeId,
    required String userId,
  }) {
    final current = [...(state[tripId] ?? const <PlaceSuggestion>[])];
    final index = current.indexWhere((place) => place.id == placeId);

    if (index == -1) return;

    final place = current[index];
    final hasVoted = place.votedBy.contains(userId);

    if (hasVoted) {
      final updatedVoters = [...place.votedBy]..remove(userId);
      current[index] = place.copyWith(
        votes: place.votes - 1,
        votedBy: updatedVoters,
      );
    } else {
      final updatedVoters = [...place.votedBy, userId];
      current[index] = place.copyWith(
        votes: place.votes + 1,
        votedBy: updatedVoters,
      );
    }

    state = {...state, tripId: current};
  }

  void addPlace({required String tripId, required PlaceSuggestion place}) {
    final current = [...(state[tripId] ?? const <PlaceSuggestion>[])];
    current.insert(0, place);

    state = {...state, tripId: current};
  }

  void updatePlace({
    required String tripId,
    required PlaceSuggestion updatedPlace,
  }) {
    final current = [...(state[tripId] ?? const <PlaceSuggestion>[])];
    final index = current.indexWhere((place) => place.id == updatedPlace.id);

    if (index == -1) return;

    current[index] = updatedPlace;

    state = {...state, tripId: current};
  }

  void deletePlace({required String tripId, required String placeId}) {
    final current = [...(state[tripId] ?? const <PlaceSuggestion>[])];
    current.removeWhere((place) => place.id == placeId);

    state = {...state, tripId: current};
  }

  static final Map<String, List<PlaceSuggestion>> _demoPlaces = {
    'trip_amsterdam': const [
      PlaceSuggestion(
        id: 'ams_1',
        title: 'Rijksmuseum',
        category: 'Музей',
        description: 'Классическое искусство и знаменитые голландские мастера.',
        emoji: '🖼️',
        votes: 4,
        votedBy: ['1', '2', '3', '4'],
      ),
      PlaceSuggestion(
        id: 'ams_2',
        title: 'Vondelpark Picnic',
        category: 'Отдых',
        description: 'Небольшой пикник и прогулка в центральном парке.',
        emoji: '🌿',
        votes: 3,
        votedBy: ['1', '2', '4'],
      ),
      PlaceSuggestion(
        id: 'ams_3',
        title: 'Canal Cruise',
        category: 'Активность',
        description: 'Вечерняя прогулка по каналам с видом на центр города.',
        emoji: '🛶',
        votes: 5,
        votedBy: ['1', '2', '3', '4', '5'],
      ),
      PlaceSuggestion(
        id: 'ams_4',
        title: 'Foodhallen',
        category: 'Еда',
        description: 'Фудмаркет с разными кухнями и живой атмосферой.',
        emoji: '🍜',
        votes: 2,
        votedBy: ['1', '3'],
      ),
    ],
    'trip_barcelona': const [
      PlaceSuggestion(
        id: 'bar_1',
        title: 'Sagrada Família',
        category: 'Архитектура',
        description: 'Главная достопримечательность Барселоны.',
        emoji: '⛪',
        votes: 3,
        votedBy: ['1', '5', '6'],
      ),
      PlaceSuggestion(
        id: 'bar_2',
        title: 'La Boqueria',
        category: 'Еда',
        description: 'Рынок для дегустации местной кухни и tapas.',
        emoji: '🥘',
        votes: 2,
        votedBy: ['1', '6'],
      ),
    ],
    'trip_tokyo': const [
      PlaceSuggestion(
        id: 'tok_1',
        title: 'Shibuya Sky',
        category: 'Видовая площадка',
        description: 'Панорамный вид на Токио вечером.',
        emoji: '🌃',
        votes: 5,
        votedBy: ['1', '7', '8', '9', '10'],
      ),
      PlaceSuggestion(
        id: 'tok_2',
        title: 'Tsukiji Market',
        category: 'Еда',
        description: 'Ранний завтрак и street food.',
        emoji: '🍣',
        votes: 4,
        votedBy: ['1', '7', '8', '10'],
      ),
      PlaceSuggestion(
        id: 'tok_3',
        title: 'teamLab Planets',
        category: 'Иммерсивный опыт',
        description: 'Интерактивный цифровой музей.',
        emoji: '✨',
        votes: 3,
        votedBy: ['1', '8', '9'],
      ),
    ],
  };
}
