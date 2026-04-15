import 'package:digital_shores/app/data/models/weather/weather_data_model.dart';
import 'package:digital_shores/app/data/models/weather/weather_location_model.dart';
import 'package:digital_shores/app/domain/entities/weather/weather.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable(createToJson: false)
class WeatherModel {
  @JsonKey(name: 'lokasi', fromJson: locationFromJson)
  final WeatherLocationModel? location;
  @JsonKey(name: 'cuaca')
  final List<List<WeatherDataModel>>? weathers;

  factory WeatherModel.fromJson(Map<String, dynamic> json) => _$WeatherModelFromJson(json);

  static WeatherLocationModel? locationFromJson(Map<String, dynamic>? json) {
    return WeatherLocationModel.fromJson(json ?? {});
  }

  const WeatherModel({
    required this.location,
    required this.weathers,
  });

  Weather toEntity() {
    return Weather(
      location: location?.toEntity(),
      weathers: weathers?.map((e) => e.map((e) => e.toEntity()).toList()).toList(),
    );
  }
}
