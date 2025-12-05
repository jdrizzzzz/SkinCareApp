import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

//-------------------This is the help / API tool -------------------
// it only knows http request, the gps and json parsing

class WeatherService {                //fetches the weather data
  static const BASE_URL = 'http://api.weatherapi.com/v1/current.json';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String locationQuery) async {
    final uri = Uri.parse(
      '$BASE_URL?key=$apiKey&q=$locationQuery&aqi=yes',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission(); //get permission from user
    if (permission == LocationPermission.denied) {                   //if its denied, ask for permission
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(            //fetch the current location
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    //Convert the raw coordinates into a readable location
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? city = placemarks.isNotEmpty ? placemarks[0].locality : null;

    return city ?? 'Unknown';
  }
}
