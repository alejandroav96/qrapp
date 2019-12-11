import 'package:flutter/material.dart';
import 'package:qrapp/componets/homeScreen.dart';
import 'package:qrapp/componets/loginScreen.dart';
import 'package:qrapp/componets/splashScreen.dart';

void main() => runApp(MyApp());
final routes = {
  '/': (BuildContext context) => new SplashScreen(),
  '/login': (BuildContext context) => new LoginScreen(),
  '/home': (BuildContext context) => new HomeScreen(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Rocket',
      theme: ThemeData.dark(),
      routes: routes,
    );
  }
}