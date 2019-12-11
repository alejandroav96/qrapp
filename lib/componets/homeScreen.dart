import 'package:flutter/material.dart';
import 'package:qrapp/services/dataStorage.dart';
import 'package:qrapp/services/http.dart';
import 'package:qrapp/models/response.dart';
import 'dart:convert';
import 'package:qrapp/componets/detailScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Response>> data;
  final GlobalKey<ScaffoldState> _skey = GlobalKey<ScaffoldState>();

  void _logout() {
    removeLocal("company");
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<List<Response>> _getData() async {
    List<Response> dataResponse = [];
    String company = await getLocal("company");
    final response =
    await fetchGet("https://api.toopo.com.co/poll-service/data/" + company);
    final res = json.decode(response.body);
    for (var i = 0; i < res.length; i++) {
      dataResponse.add(Response.fromJson(res[i]));
    }
    return dataResponse;
  }
  @override
  void initState() {
    super.initState();
    data = _getData();
  }
  void notification(String texto) {
    _skey.currentState.showSnackBar(SnackBar(
      content: Text(texto),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _skey,
      appBar: AppBar(title: Text("DashBoard"), actions: <Widget>[
        IconButton(icon: Icon(Icons.close), onPressed: _logout),
      ]),
      body: FutureBuilder(
          future: data,
          builder: (context, responses){
            if (responses.hasData){
              return Container(
                child: ListView.builder(
                    itemCount: responses.data.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile( title: Text('${responses.data[index].title}'), onTap:() {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(data: responses.data[index].data, title: responses.data[index].title),
                        ),
                      );});
                    }),
              );
            } else if (responses.hasError){
              return Text('${responses.error}');
            }
            return CircularProgressIndicator();
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {setState(() {data=_getData();notification("Datos actualizados exitosamente");});},
        tooltip: 'Increment',
        child: Icon(Icons.update,color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }
}