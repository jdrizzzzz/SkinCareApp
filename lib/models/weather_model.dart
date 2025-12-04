//-------------------This is a data box-------------------
// it shows what the weather looks like in the app
// its the Weather class - converts the JSON into Weather object

class Weather {
  final String cityName;                   //variables
  final double temperature;
  final String mainCondition;

  Weather({
    required this.cityName,                //initialize
    required this.temperature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(                          //function - gets the cityname,temp,and condition
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}