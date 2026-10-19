class WeatherModel {
  final double temperature;
  final int weathercode;
  final double windspeed;
  final int relativehumidity;

  WeatherModel({
    required this.temperature,
    required this.weathercode,
    required this.windspeed,
    required this.relativehumidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] as Map<String, dynamic>;
    final humidityList =
        json['hourly']['relativehumidity_2m'] as List<dynamic>;
    return WeatherModel(
      temperature: (current['temperature'] as num).toDouble(),
      weathercode: current['weathercode'] as int,
      windspeed: (current['windspeed'] as num).toDouble(),
      relativehumidity: humidityList[0] as int,
    );
  }

  /// Deskripsi kondisi cuaca berdasarkan WMO weather interpretation code
  String get description {
    if (weathercode == 0) return 'Cerah';
    if (weathercode <= 3) return 'Berawan sebagian';
    if (weathercode <= 48) return 'Berkabut';
    if (weathercode <= 57) return 'Gerimis';
    if (weathercode <= 67) return 'Hujan';
    if (weathercode <= 77) return 'Hujan salju';
    if (weathercode <= 82) return 'Hujan lebat';
    if (weathercode <= 99) return 'Badai petir';
    return 'Tidak diketahui';
  }
}
