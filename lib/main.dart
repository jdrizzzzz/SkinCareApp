import 'package:flutter/material.dart';
import 'package:skincare_project/pages/weather_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherPage(),
        routes:{
        '/loginpage' :(context) => LoginPage(),
        '/weatherpage' :(context) => WeatherPage(),
        }
    );
  }
}
