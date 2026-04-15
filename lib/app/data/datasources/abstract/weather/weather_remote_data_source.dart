import 'package:digital_shores/app/data/models/weather/weather_model.dart';
import 'package:digital_shores/core/parameters/weather_parameters.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(GetWeatherParameter params);
}
