import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

Future<String> getLocal(String name) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(name);
}

void saveLocal(String name, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(name, value);
}

void removeLocal(String name) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(name);
}