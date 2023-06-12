import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final apiKey = 'f654e20fc3cc12e4ffc3c3c223669f3e';
  String location = 'Lusaka';
  late Future<WeatherData> _weatherData;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Get the weather data for the current location.
    _weatherData = _fetchWeatherData();
    _searchController = TextEditingController(text: location);
  }

  Future<WeatherData> _fetchWeatherData() async {
    // Make an HTTP request to the OpenWeatherMap API.
    var response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey'),
    );

    // Check the response status code.
    if (response.statusCode == 200) {
      // Parse the JSON response.
      var weatherDataJson = json.decode(response.body)['main'];

      // Create a new WeatherData object.
      return WeatherData(
        name: location,
        description: '',
        temperature: (weatherDataJson['temp'] - 273.15),
      );
    } else {
      // Throw an error.
      throw Exception('Error fetching weather data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
        ),
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            
            title: SizedBox(
              height: 50,

              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: FutureBuilder<WeatherData>(
            future: _weatherData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data!.name),
                    Text(snapshot.data!.description),
                    Text('${snapshot.data!.temperature.toStringAsFixed(1)}°C'),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}

class WeatherData {
  final String name;
  final String description;
  final double temperature;

  WeatherData({
    required this.name,
    required this.description,
    required this.temperature,
  });
}
