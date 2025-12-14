import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skincare_project/pages/create_account_page.dart';
import 'package:skincare_project/pages/weather_page.dart';
import 'pages/login_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CreateAccountPage(),
        routes:{
        '/loginpage' :(context) => LoginPage(),
          '/createaccountpage' :(context) => CreateAccountPage(),
        '/weatherpage' :(context) => WeatherPage(),
        }
    );
  }
}
