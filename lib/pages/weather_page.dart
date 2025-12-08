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
  int _selectedIndex = 0; //------- for the bottomnavigationbar

  //apiKey
  final weatherService = WeatherService('70bfb62eb9754779b4305934250512');
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

  //Air quality status
  String getAirQualityStatus(int? airQualityIndex){
    if (airQualityIndex == null)
      return '--';

    switch (airQualityIndex){
      case 1:
      case 2:
      return 'Good';
      case 3:
      case 4:
        return 'Moderate';
      case 5:
      case 6:
        return 'Poor';
      default:
        return '--';

    }
  }

  //weather animations
  String getWeatherAnimation(String? condition) {
    if (condition == null) return 'images/clear.json';    //default to sun/moon

    final text = condition.toLowerCase();

    if (text.contains('cloud') || text.contains('mist') || text.contains('fog')|| text.contains('overcast')) {
      return 'images/cloudy.json';
    }
    if (text.contains('rain') || text.contains('drizzle')) {
      return 'images/rain.json';
    }
    if (text.contains('thunder')) {
      return 'images/thunder.json';
    }
    if (text.contains('snow') || text.contains('shower sleet') || text.contains('rain and snow')) {
      return 'images/snow.json';
    }
    if (text.contains('clear') || text.contains('sun')) {
      return 'images/clear.json';
    }
    return 'images/clear.json';
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Routine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  //title and the city name
                  Text(
              _weather == null ? "Loading..." : "Today in ${_weather!.cityName}",//! null-assertion(assured its not null)
                style: TextStyle(
                    fontWeight: FontWeight.bold),
                  ),
                  //condition of weather
                  Text('${_weather?.mainCondition}'),
                  //animation for the weather
                  SizedBox(
                    height:200,
                      width:200,
                      child: Lottie.asset(getWeatherAnimation(_weather?.mainCondition))       //weather icon
                  ),
                  SizedBox(
                      height:90,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                            child: Text("Today's Tip",
                              style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,), // -------USE AI RECOMMENDATION HERE
                            ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            //----------------------Temp/humidity boxes----------------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thermostat,
                          color: Colors.amber,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Temperature",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _weather == null ? "--°C" : "${_weather!.temperature.round()}°C",
                                style: TextStyle(fontWeight: FontWeight.w900,fontSize: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Humidity",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                _weather == null ? "--%" : "${_weather!.humidity}%",
                              style: TextStyle(fontWeight: FontWeight.w900,fontSize: 24)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            //----------------------UV Index/AirQuality boxes----------------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 45),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: Colors.amber,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            Text(
                              "UV Index",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                _weather == null ? "--" : "${_weather!.uvIndex}",
                                style: TextStyle(fontWeight: FontWeight.w900,fontSize: 24)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 35),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.air,
                          color: Colors.amber,
                          size: 24,
                        ),
                        Column(
                          children: [
                            Text(
                              "Air Quality",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                _weather == null ? "--" : "${_weather!.airQualityIndex}",
                                style: TextStyle(fontWeight: FontWeight.w900,fontSize: 24)
                            ),
                            Text(
                              _weather == null ? "--" : getAirQualityStatus(_weather!.airQualityIndex),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 70,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "View your progress",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
}
