import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_now/models/weather_model.dart';
import 'package:weather_now/services/weather_service.dart';

import 'weather_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late WeatherService service;

  setUp(() {
    mockClient = MockClient();
    service = WeatherService(client: mockClient);
  });

  const geoResponse = '''
{
  "results": [
    {
      "name": "Jakarta",
      "latitude": -6.2146,
      "longitude": 106.8451
    }
  ]
}
''';

  const forecastResponse = '''
{
  "current_weather": {
    "temperature": 30.0,
    "weathercode": 2,
    "windspeed": 10.0
  },
  "hourly": {
    "relativehumidity_2m": [80, 82, 84]
  }
}
''';

  const emptyGeoResponse = '{"results": []}';

  bool isGeoUri(Uri uri) => uri.host == 'geocoding-api.open-meteo.com';
  bool isForecastUri(Uri uri) => uri.host == 'api.open-meteo.com';

  test('fetchWeather returns WeatherModel on success', () async {
    when(mockClient.get(argThat(predicate<Uri>(isGeoUri))))
        .thenAnswer((_) async => http.Response(geoResponse, 200));
    when(mockClient.get(argThat(predicate<Uri>(isForecastUri))))
        .thenAnswer((_) async => http.Response(forecastResponse, 200));

    final result = await service.fetchWeather('Jakarta');

    expect(result, isA<WeatherModel>());
    expect(result.temperature, 30.0);
    expect(result.relativehumidity, 80);
  });

  test('fetchWeather throws Exception when city not found', () async {
    when(mockClient.get(argThat(predicate<Uri>(isGeoUri))))
        .thenAnswer((_) async => http.Response(emptyGeoResponse, 200));

    await expectLater(
      () => service.fetchWeather('xyzxyzxyz'),
      throwsA(isA<Exception>().having(
          (e) => e.toString(), 'message', contains('Kota tidak ditemukan'))),
    );
  });

  test('fetchWeather throws Exception when geocoding HTTP fails', () async {
    when(mockClient.get(argThat(predicate<Uri>(isGeoUri))))
        .thenAnswer((_) async => http.Response('error', 500));

    await expectLater(
      () => service.fetchWeather('Jakarta'),
      throwsA(isA<Exception>()),
    );
  });

  test('fetchWeather throws Exception when forecast HTTP fails', () async {
    when(mockClient.get(argThat(predicate<Uri>(isGeoUri))))
        .thenAnswer((_) async => http.Response(geoResponse, 200));
    when(mockClient.get(argThat(predicate<Uri>(isForecastUri))))
        .thenAnswer((_) async => http.Response('error', 500));

    await expectLater(
      () => service.fetchWeather('Jakarta'),
      throwsA(isA<Exception>()),
    );
  });
}
