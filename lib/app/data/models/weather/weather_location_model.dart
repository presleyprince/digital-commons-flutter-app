import 'package:digital_shores/app/domain/entities/weather/weather_location.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_location_model.g.dart';

@JsonSerializable(createToJson: false)
class WeatherLocationModel {
  final String? adm1;
  final String? adm2;
  final String? adm3;
  final String? adm4;
  final String? provinsi;
  final String? kotkab;
  final String? kecamatan;
  final String? desa;
  final double? lon;
  final double? lat;
  final String? timezone;
  final String? type;

  factory WeatherLocationModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherLocationModelFromJson(json);

  const WeatherLocationModel({
    required this.adm1,
    required this.adm2,
    required this.adm3,
    required this.adm4,
    required this.provinsi,
    required this.kotkab,
    required this.kecamatan,
    required this.desa,
    required this.lon,
    required this.lat,
    required this.timezone,
    required this.type,
  });

  WeatherLocation toEntity() {
    return WeatherLocation(
      adm1: adm1,
      adm2: adm2,
      adm3: adm3,
      adm4: adm4,
      provinsi: provinsi,
      kotkab: kotkab,
      kecamatan: kecamatan,
      desa: desa,
      lon: lon,
      lat: lat,
      timezone: timezone,
      type: type,
    );
  }
}
