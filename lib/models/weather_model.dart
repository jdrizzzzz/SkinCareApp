//-------------------This is a data box-------------------
// it shows what the weather looks like in the app
// its the Weather class - converts the JSON into Weather object

class Weather {
  final String cityName;                   //variables
  final double temperature;
  final String mainCondition;
  final int humidity;
  final double uvIndex;
  final int airQualityIndex;

  Weather({
    required this.cityName,                //initialize
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.uvIndex,
    required this.airQualityIndex,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return Weather(
      cityName: location['name'],
      temperature: (current['temp_c'] as num).toDouble(),
      mainCondition: current['condition']['text'],
      humidity: current['humidity'],
      uvIndex: (current['uv'] as num).toDouble(),
      airQualityIndex: current['air_quality'] == null ? 0 : current['air_quality']['us-epa-index'] ?? 0,   // 1-6
    );
  }
}