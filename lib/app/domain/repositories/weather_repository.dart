import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/weather/weather.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';

abstract class WeatherRepository {
  Future<Either<Failure, Weather>> getWeather({required WeatherRegionCode weatherRegion});

  WeatherRegionCode? getCachedRegionCode();
  Future<void> cacheRegionCode({required WeatherRegionCode regionCode});
  Future<void> removeCachedRegionCode();
}
