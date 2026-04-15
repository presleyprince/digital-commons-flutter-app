import 'package:digital_shores/app/data/datasources/abstract/weather/weather_local_data_source.dart';
import 'package:digital_shores/core/parameters/weather_parameters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherLocalDataSourceImpl extends WeatherLocalDataSource {
  final SharedPreferences _sharedPreferences;

  WeatherLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  Future<void> cacheRegionCode(CacheRegionCodeParameter params) async {
    await _sharedPreferences.setInt('region_code', params.regionCode);
  }

  @override
  int? getCachedRegionCode() {
    return _sharedPreferences.getInt('region_code');
  }

  @override
  Future<void> removeCachedRegionCode() async {
    await _sharedPreferences.remove('region_code');
  }
}
