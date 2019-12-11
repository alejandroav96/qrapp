import 'dart:async';
import 'package:http/http.dart' as http;

Future<dynamic> fetchPost(String url, {Map body}) async {
  final response = await http.post(url, body: body);
  return response;
}

Future<dynamic> fetchGet(String url) async {
  final response = await http.get(url);
  return response;
}