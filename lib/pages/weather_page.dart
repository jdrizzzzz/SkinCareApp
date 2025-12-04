import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

//-------------------This is the screen we see in the app (the ui)-------------------
// asks the weather service for the data, wait for it, stores the result and then updates the screen
// using setState() in _fetchWeather() function

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //Functions------------------------------------

  //apiKey
  final weatherService = WeatherService('5419a27e2204ddfa3db0ba34a8fddac2');
  Weather? _weather;

  //fetch weather
  _fetchWeather() async {
    //get the current city
    String cityName = await weatherService.getCurrentCity();

    //get weather for city
    try{
      final weather = await weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }

    //any errors
    catch (e){
      print(e);
    }
  }

  //weather animations
  String getWeatherAnimation(String? mainCondition){
    if (mainCondition == null)   //default to sunny
      return 'images/clear.json';

    switch (mainCondition.toLowerCase()){
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'ash':
      case 'squall':
        return 'images/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'images/rain.json';
      case 'thunderstorm':
        return 'images/thunder.json';
      case 'snow':
        return 'images/snow.json';
      case 'clear':
        return 'images/clear.json';
      default:
        return 'images/clear.json';
    }
  }

  //initial state
  @override
  void initState(){
    super.initState();

    //fetch the weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  //title and the city name
                  Text(
              _weather == null
              ? "Loading..." : "Today in ${_weather!.cityName}", //! null-assertion (assured its not null)
                style: TextStyle(
                    fontWeight: FontWeight.bold),
                  ),
                  //condition of weather
                  Text('${_weather?.mainCondition}'),
                  //animation for the weather
                  SizedBox(
                    height:300,
                      width:300,
                      child: Lottie.asset(getWeatherAnimation(_weather?.mainCondition))
                  ),

                  //temperature
                  //Text('${_weather?.temperature.round()}°C')
                ],
              ),
            ),

            //----------------------Temp/humidity boxes----------------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thermostat,
                          color: Colors.black,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Temperature",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Humidity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            //----------------------UV Index/AirQuality boxes----------------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined, // UV Icon
                          color: Colors.black,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "UV Index",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.air, // Air Quality Icon
                          color: Colors.black,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Air Quality",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),




          ],
        ),
      ),

    );
  }
}
