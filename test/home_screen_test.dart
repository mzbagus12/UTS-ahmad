import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_now/models/weather_model.dart';
import 'package:weather_now/screens/home_screen.dart';
import 'package:weather_now/services/weather_service.dart';

// Fake WeatherService untuk widget test tanpa network
class FakeWeatherService extends WeatherService {
  final WeatherModel? returnModel;
  final Exception? throwError;

  FakeWeatherService({this.returnModel, this.throwError});

  @override
  Future<WeatherModel> fetchWeather(String cityName) {
    if (throwError != null) return Future.error(throwError!);
    return Future.value(returnModel!);
  }
}

final sampleWeather = WeatherModel(
  temperature: 30.0,
  weathercode: 0,
  windspeed: 10.0,
  relativehumidity: 75,
);

void main() {
  testWidgets('HomeScreen menampilkan AppBar WeatherNow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(service: FakeWeatherService(returnModel: sampleWeather)),
      ),
    );
    expect(find.text('WeatherNow'), findsOneWidget);
  });

  testWidgets('HomeScreen menampilkan TextField dan tombol Cari', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(service: FakeWeatherService(returnModel: sampleWeather)),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
  });

  testWidgets('HomeScreen menampilkan data cuaca setelah pencarian sukses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(service: FakeWeatherService(returnModel: sampleWeather)),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Jakarta');
    await tester.tap(find.text('Cari'));
    await tester.pump(); // loading state
    await tester.pump(const Duration(milliseconds: 100)); // future selesai

    expect(find.text('30.0°C'), findsOneWidget);
    expect(find.text('Cerah'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('10.0 km/h'), findsOneWidget);
  });

  testWidgets('HomeScreen menampilkan CircularProgressIndicator saat loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(service: FakeWeatherService(returnModel: sampleWeather)),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Jakarta');
    await tester.tap(find.text('Cari'));
    await tester.pump(); // hanya pump sekali — masih loading

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen tidak memanggil API jika input kosong', (tester) async {
    var callCount = 0;
    final service = FakeWeatherService(returnModel: sampleWeather);

    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(service: service)),
    );

    await tester.tap(find.text('Cari'));
    await tester.pump();

    // Tidak ada hasil tampil — FutureBuilder tidak dipanggil
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Card), findsNothing);
  });
}
