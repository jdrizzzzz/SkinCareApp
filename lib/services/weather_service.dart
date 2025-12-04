import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

//-------------------This is the help / API tool -------------------
// it only knows http request, the gps and json parsing

class WeatherService{             //This fetches the weather data
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    //the function to get the weather
    final response = await http.get(
        Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body)); //calls the function from weather model
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
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;

    return city ?? "";
  }
}