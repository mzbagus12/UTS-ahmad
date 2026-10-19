import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBase =
      'https://api.open-meteo.com/v1/forecast';

  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

  Future<WeatherModel> fetchWeather(String cityName) async {
    // Step 1: Geocoding — nama kota → koordinat
    final geoUri = Uri.parse(
      '$_geocodingBase?name=${Uri.encodeComponent(cityName)}&count=1&language=id&format=json',
    );
    final geoResponse = await client.get(geoUri);

    if (geoResponse.statusCode != 200) {
      throw Exception('Gagal mengambil data lokasi');
    }

    final geoData = jsonDecode(geoResponse.body) as Map<String, dynamic>;
    final results = geoData['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw Exception('Kota tidak ditemukan');
    }

    final location =
        LocationModel.fromJson(results[0] as Map<String, dynamic>);

    // Step 2: Forecast — koordinat → data cuaca
    final forecastUri = Uri.parse(
      '$_forecastBase?latitude=${location.latitude}&longitude=${location.longitude}'
      '&current_weather=true&hourly=relativehumidity_2m&forecast_days=1&timezone=auto',
    );
    final forecastResponse = await client.get(forecastUri);

    if (forecastResponse.statusCode != 200) {
      throw Exception('Gagal mengambil data cuaca');
    }

    final forecastData =
        jsonDecode(forecastResponse.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(forecastData);
  }
}
