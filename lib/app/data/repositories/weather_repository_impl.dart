import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/data/datasources/abstract/weather/weather_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/weather/weather_remote_data_source.dart';
import 'package:digital_shores/app/domain/entities/weather/weather.dart';
import 'package:digital_shores/app/domain/repositories/weather_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/parameters/weather_parameters.dart';
import 'package:http/http.dart';

class WeatherRepositoryImpl extends WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, Weather>> getWeather({required WeatherRegionCode weatherRegion}) async {
    try {
      final weather =
          await remoteDataSource.getWeather(GetWeatherParameter(regionCode: weatherRegion.regionCode));
      
      await cacheRegionCode(regionCode: weatherRegion);
      // remove all weather data where the date is less than the current date
      weather.weathers?[0]
          .removeWhere((element) => element.datetime?.isBefore(DateTime.now()) ?? false);
      return Right(weather.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengambil data cuaca',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<void> cacheRegionCode({required WeatherRegionCode regionCode}) async {
    await localDataSource.cacheRegionCode(CacheRegionCodeParameter(regionCode: regionCode.index));
  }

  @override
  WeatherRegionCode? getCachedRegionCode() {
    final index = localDataSource.getCachedRegionCode();
    if (index != null) {
      return WeatherRegionCode.values[index];
    }
    return null;
  }

  @override
  Future<void> removeCachedRegionCode() async {
    await localDataSource.removeCachedRegionCode();
  }
}
