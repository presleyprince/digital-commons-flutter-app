import 'package:digital_shores/core/parameters/weather_parameters.dart';

abstract class WeatherLocalDataSource {
  int? getCachedRegionCode();
  Future<void> cacheRegionCode(CacheRegionCodeParameter params);
  Future<void> removeCachedRegionCode();
}
