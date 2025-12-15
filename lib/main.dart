import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skincare_project/pages/create_account_page.dart';
import 'package:skincare_project/pages/weather_page.dart';
import 'pages/login_page.dart';


Future<void> main() async {   //waits for env and firebase to load until UI is started
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");              // load .env first
  await Firebase.initializeApp();                   //initialize firebase once globally
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
