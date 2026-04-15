import 'dart:convert';

import 'package:digital_shores/app/data/datasources/abstract/weather/weather_remote_data_source.dart';
import 'package:digital_shores/app/data/models/weather/weather_model.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/parameters/weather_parameters.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherRemoteDataSourceImpl extends WeatherRemoteDataSource {
  final http.Client client;

  WeatherRemoteDataSourceImpl({required this.client});

  final bmkgApiUrl = dotenv.env['BMKG_API_URL'];

  @override
  Future<WeatherModel> getWeather(GetWeatherParameter params) async {
    try {
      final response =
          await client.get(Uri.parse('$bmkgApiUrl/prakiraan-cuaca?adm4=${params.regionCode}'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherModel.fromJson(json['data'][0]);
      } else if (response.statusCode == 404) {
        throw CustomException('Data cuaca tidak ditemukan.');
      } else {
        throw CustomException('Gagal mengambil data cuaca. Terjadi kesalahan pada server BMKG.');
      }
    } on CustomException catch (e) {
      throw CustomException(e.message);
    }
  }
}
