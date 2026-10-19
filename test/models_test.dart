import 'package:flutter_test/flutter_test.dart';
import 'package:weather_now/models/location_model.dart';
import 'package:weather_now/models/weather_model.dart';

void main() {
  group('LocationModel', () {
    test('fromJson parses name, latitude, longitude correctly', () {
      final json = {
        'name': 'Jakarta',
        'latitude': -6.2146,
        'longitude': 106.8451,
      };
      final model = LocationModel.fromJson(json);
      expect(model.name, 'Jakarta');
      expect(model.latitude, -6.2146);
      expect(model.longitude, 106.8451);
    });

    test('fromJson handles integer lat/lon (num cast)', () {
      final json = {
        'name': 'Surabaya',
        'latitude': -7,
        'longitude': 112,
      };
      final model = LocationModel.fromJson(json);
      expect(model.latitude, -7.0);
      expect(model.longitude, 112.0);
    });
  });

  group('WeatherModel', () {
    final sampleJson = {
      'current_weather': {
        'temperature': 28.5,
        'weathercode': 1,
        'windspeed': 12.3,
      },
      'hourly': {
        'relativehumidity_2m': [75, 80, 85],
      },
    };

    test('fromJson parses temperature correctly', () {
      final model = WeatherModel.fromJson(sampleJson);
      expect(model.temperature, 28.5);
    });

    test('fromJson parses weathercode correctly', () {
      final model = WeatherModel.fromJson(sampleJson);
      expect(model.weathercode, 1);
    });

    test('fromJson parses windspeed correctly', () {
      final model = WeatherModel.fromJson(sampleJson);
      expect(model.windspeed, 12.3);
    });

    test('fromJson picks relativehumidity index 0', () {
      final model = WeatherModel.fromJson(sampleJson);
      expect(model.relativehumidity, 75);
    });

    test('description returns Cerah for weathercode 0', () {
      final json = Map<String, dynamic>.from(sampleJson);
      (json['current_weather'] as Map<String, dynamic>)['weathercode'] = 0;
      final model = WeatherModel.fromJson(json);
      expect(model.description, 'Cerah');
    });

    test('description returns Hujan for weathercode 61', () {
      final json = Map<String, dynamic>.from(sampleJson);
      final current = Map<String, dynamic>.from(
          json['current_weather'] as Map<String, dynamic>);
      current['weathercode'] = 61;
      json['current_weather'] = current;
      final model = WeatherModel.fromJson(json);
      expect(model.description, 'Hujan');
    });

    test('description returns Badai petir for weathercode 95', () {
      final json = Map<String, dynamic>.from(sampleJson);
      final current = Map<String, dynamic>.from(
          json['current_weather'] as Map<String, dynamic>);
      current['weathercode'] = 95;
      json['current_weather'] = current;
      final model = WeatherModel.fromJson(json);
      expect(model.description, 'Badai petir');
    });
  });
}
