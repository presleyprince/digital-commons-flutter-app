import 'package:digital_shores/app/domain/entities/weather/weather.dart';
import 'package:digital_shores/app/domain/entities/weather/weather_data.dart';
import 'package:digital_shores/app/domain/repositories/weather_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class WeatherNotifier extends ChangeNotifier {
  // state
  NotifierState<Weather> fetchDataState = NotifierState();

  // data
  ValueNotifier<WeatherRegionCode?> regionCodeController = ValueNotifier(null);
  List<WeatherData> weathers = [];

  final WeatherRepository _repository;

  WeatherNotifier({required WeatherRepository repository}) : _repository = repository;

  void init() {
    regionCodeController = ValueNotifier<WeatherRegionCode?>(getCachedRegionCode());
    if (regionCodeController.value != null) {
      Future.microtask(() => fetchWeather());
    }

    regionCodeController.addListener(() {
      if (regionCodeController.value != null) {
        fetchWeather();
      }
    });
  }

  void reset() {
    regionCodeController.dispose();
    fetchDataState.reset();
  }

  void setRegionCode(WeatherRegionCode regionCode) {
    regionCodeController.value = regionCode;
    // notifyListeners();
  }

  WeatherRegionCode? getCachedRegionCode() {
    return _repository.getCachedRegionCode();
  }

  Future<void> fetchWeather() async {
    fetchDataState.setLoading();
    notifyListeners();

    final result = await _repository.getWeather(weatherRegion: regionCodeController.value!);

    result.fold(
      (failure) {
        fetchDataState.setError(failure: failure);
      },
      (data) {
        for (final list in data.weathers!) {
          // for 
          weathers.addAll(list);
        }
        fetchDataState.setSuccess(value: data);
      },
    );

    notifyListeners();
  }

  Future<void> clearInformationsFromLocal() async {
    await _repository.removeCachedRegionCode();
  }
}
