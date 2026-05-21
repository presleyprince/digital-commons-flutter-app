// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherLocationModel _$WeatherLocationModelFromJson(
        Map<String, dynamic> json) =>
    WeatherLocationModel(
      adm1: json['adm1'] as String?,
      adm2: json['adm2'] as String?,
      adm3: json['adm3'] as String?,
      adm4: json['adm4'] as String?,
      provinsi: json['provinsi'] as String?,
      kotkab: json['kotkab'] as String?,
      kecamatan: json['kecamatan'] as String?,
      desa: json['desa'] as String?,
      lon: (json['lon'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
      type: json['type'] as String?,
    );
