import 'package:digital_shores/app/domain/entities/weather/weather_data.dart';
import 'package:digital_shores/app/domain/entities/weather/weather_location.dart';

class Weather {
  const Weather({
    required this.location,
    required this.weathers,
  });

  final WeatherLocation? location;
  final List<List<WeatherData>>? weathers;

  Weather copyWith({
    WeatherLocation? location,
    List<List<WeatherData>>? weathers,
  }) {
    return Weather(
      location: location ?? this.location,
      weathers: weathers ?? this.weathers,
    );
  }
}
