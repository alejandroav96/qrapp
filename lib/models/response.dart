import 'package:qrapp/models/data.dart';

class Response {
  final String title;
  final List<Data> data;

  Response(this.title, this.data);

  factory Response.fromJson(Map<String, dynamic> json) {
    List<Data> data = [];
    for (var i = 0; i < json['data'].length; i++) {
      data.add(Data.fromJson(json['data'][i]));
    }
    return Response(json['title'], data);
  }
}