class WeatherData {
  final DateTime? datetime;
  final int? t;
  final int? tcc;
  final double? tp;
  final int? weather;
  final String? weatherDesc;
  final String? weatherDescEn;
  final int? wdDeg;
  final String? windDirection;
  final String? wdTo;
  final double? windSpeed;
  final int? humidity;
  final int? vs;
  final String? visibilityText;
  final String? timeIndex;
  final DateTime? analysisDate;
  final String? image;
  final DateTime? utcDatetime;
  final DateTime? localDatetime;

  String parseWindDirection() {
    switch (windDirection) {
      case 'N':
        return 'Utara';
      case 'NE':
        return 'Timur Laut';
      case 'E':
        return 'Timur';
      case 'SE':
        return 'Tenggara';
      case 'S':
        return 'Selatan';
      case 'SW':
        return 'Barat Daya';
      case 'W':
        return 'Barat';
      case 'NW':
        return 'Barat Laut';
      default:
        return '-';
    }
  }

  const WeatherData({
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
}
