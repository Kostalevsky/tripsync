import 'dart:math';

class TripNameGenerator {
  static final _random = Random();

  static const _prefixes = [
    'Путешествие в',
    'Уикенд в',
    'Поездка в',
    'Открываем',
    'Приключение в',
  ];

  static const _seasonPrefixes = ['Весна в', 'Лето в', 'Осень в', 'Зима в'];

  static const _suffixes = [
    '— лучшие места',
    '— гастрономический тур',
    '— городские приключения',
    '— незабываемая поездка',
    '— исследуем город',
  ];

  static String generate(String destination) {
    final useSeason = _random.nextBool();

    if (useSeason) {
      return '${_seasonPrefixes[_random.nextInt(_seasonPrefixes.length)]} $destination';
    }

    final prefix = _prefixes[_random.nextInt(_prefixes.length)];
    final suffix = _suffixes[_random.nextInt(_suffixes.length)];

    if (_random.nextBool()) {
      return '$prefix $destination';
    }

    return '$destination $suffix';
  }
}
