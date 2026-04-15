import 'package:digital_shores/app/domain/entities/weather/weather_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_data_model.g.dart';

@JsonSerializable(createToJson: false)
class WeatherDataModel {
  final DateTime? datetime;
  final int? t;
  final int? tcc;
  final double? tp;
  final int? weather;

  @JsonKey(name: 'weather_desc')
  final String? weatherDesc;

  @JsonKey(name: 'weather_desc_en')
  final String? weatherDescEn;

  @JsonKey(name: 'wd_deg')
  final int? wdDeg;
  @JsonKey(name: 'wd')
  final String? windDirection;

  @JsonKey(name: 'wd_to')
  final String? wdTo;
  @JsonKey(name: 'ws')
  final double? windSpeed;
  @JsonKey(name: 'hu')
  final int? humidity;
  final int? vs;
  @JsonKey(name: 'vs_text')
  final String? visibilityText;
  @JsonKey(name: 'time_index')
  final String? timeIndex;
  @JsonKey(name: 'analysis_date')
  final DateTime? analysisDate;
  final String? image;
  @JsonKey(name: 'utc_datetime')
  final DateTime? utcDatetime;
  @JsonKey(name: 'local_datetime')
  final DateTime? localDatetime;

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) => _$WeatherDataModelFromJson(json);

  const WeatherDataModel({
    required this.datetime,
    required this.t,
    required this.tcc,
    required this.tp,
    required this.weather,
    required this.weatherDesc,
    required this.weatherDescEn,
    required this.wdDeg,
    required this.windDirection,
    required this.wdTo,
    required this.windSpeed,
    required this.humidity,
    required this.vs,
    required this.visibilityText,
    required this.timeIndex,
    required this.analysisDate,
    required this.image,
    required this.utcDatetime,
    required this.localDatetime,
  });

  WeatherData toEntity() {
    return WeatherData(
      datetime: datetime,
      t: t,
      tcc: tcc,
      tp: tp,
      weather: weather,
      weatherDesc: weatherDesc,
      weatherDescEn: weatherDescEn,
      wdDeg: wdDeg,
      windDirection: windDirection,
      wdTo: wdTo,
      windSpeed: windSpeed,
      humidity: humidity,
      vs: vs,
      visibilityText: visibilityText,
      timeIndex: timeIndex,
      analysisDate: analysisDate,
      image: image,
      utcDatetime: utcDatetime,
      localDatetime: localDatetime,
    );
  }
}
