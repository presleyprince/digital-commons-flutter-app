// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
      location: WeatherModel.locationFromJson(
          json['lokasi'] as Map<String, dynamic>?),
      weathers: (json['cuaca'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>)
              .map((e) => WeatherDataModel.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
    );
