// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherDataModel _$WeatherDataModelFromJson(Map<String, dynamic> json) =>
    WeatherDataModel(
      datetime: json['datetime'] == null
          ? null
          : DateTime.parse(json['datetime'] as String),
      t: (json['t'] as num?)?.toInt(),
      tcc: (json['tcc'] as num?)?.toInt(),
      tp: (json['tp'] as num?)?.toDouble(),
      weather: (json['weather'] as num?)?.toInt(),
      weatherDesc: json['weather_desc'] as String?,
      weatherDescEn: json['weather_desc_en'] as String?,
      wdDeg: (json['wd_deg'] as num?)?.toInt(),
      windDirection: json['wd'] as String?,
      wdTo: json['wd_to'] as String?,
      windSpeed: (json['ws'] as num?)?.toDouble(),
      humidity: (json['hu'] as num?)?.toInt(),
      vs: (json['vs'] as num?)?.toInt(),
      visibilityText: json['vs_text'] as String?,
      timeIndex: json['time_index'] as String?,
      analysisDate: json['analysis_date'] == null
          ? null
          : DateTime.parse(json['analysis_date'] as String),
      image: json['image'] as String?,
      utcDatetime: json['utc_datetime'] == null
          ? null
          : DateTime.parse(json['utc_datetime'] as String),
      localDatetime: json['local_datetime'] == null
          ? null
          : DateTime.parse(json['local_datetime'] as String),
    );
