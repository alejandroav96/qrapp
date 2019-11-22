import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;

Future<dynamic> fetchPost(String url, {Map body}) async {
  final response = await http.post(url, body: body);
  return response;
}

Future<dynamic> fetchGet(String url) async {
  final response = await http.get(url);
  return response;
}

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

void main() => runApp(MyApp());
final routes = {
  '/': (BuildContext context) => new MyHomePage(),
  '/login': (BuildContext context) => new LoginPage(),
  '/home': (BuildContext context) => new SecondScreen()
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel Rocket',
      theme: ThemeData.dark(),
      routes: routes,
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class Data {
  final String _id;
  final int count;

  Data(this._id, this.count);

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(json['_id'].toString(), int.parse(json['count'].toString()));
  }
}

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

class _SecondScreenState extends State<SecondScreen> {
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

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final List<Data> data;
  final String title;
  final bool animate = true;

  static List<charts.Series<Data, String>> _createSampleData(data, title) {
    return [
      new charts.Series<Data, String>(
        id: title,
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Data sales, _) => sales._id,
        measureFn: (Data sales, _) => sales.count,
        data: data,
      )
    ];
  }

  // In the constructor, require a Data.
  DetailScreen({Key key, @required this.data, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
            width: 450.0,
            height: 300.0,
            child: new charts.PieChart(
              _createSampleData(data, title),
              animate: animate,
              behaviors: [
                new charts.DatumLegend(
                  position: charts.BehaviorPosition.end,
                  horizontalFirst: false,
                  cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                  showMeasures: true,
                  legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
                  measureFormatter: (num value) {
                    return value == null ? '-' : '${value}';
                  },
                ),
              ],
            )),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _onShowLogin);
  }

  void _onShowLogin() async {
    String company = await getLocal("company");
    if (company != null)
      Navigator.pushReplacementNamed(context, '/home');
    else
      Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[600],
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 100.0,
          ),
          Flexible(
            flex: 2,
            child: SafeArea(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: Image.asset('assets/flutterwithlogo.png'),
              ),
            ),
          ),
          Text(
            'Bienvenido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          Flexible(
            flex: 2,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 64.0, horizontal: 16.0),
                alignment: Alignment.bottomCenter,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  RegExp emailRegExp =
      new RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$');
  String _email = "";
  String _password = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _skey = GlobalKey<ScaffoldState>();

  void notification(String texto) {
    _skey.currentState.showSnackBar(SnackBar(
      content: Text(texto),
    ));
  }

  void notificationLoading() {
    _skey.currentState.showSnackBar(SnackBar(
      duration: new Duration(seconds: 2),
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          Text("   Iniciando Sesión")
        ],
      ),
    ));
  }

  void login(String email, String password) {
    notificationLoading();
    fetchPost('https://api.toopo.com.co/poll-service/login',
        body: {"email": email, "password": password}).then((dynamic res) {
      if (res.statusCode != 200)
        notification("Datos invalidos");
      else {
        saveLocal("company", json.decode(res.body)['companyId']);
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _skey,
        appBar: AppBar(
          title: Text("Inicio"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/flutterwithlogo.png'),
              ],
            ),
            Container(
              width: 300.0,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      onChanged: (text) => _email = text,
                      validator: (text) {
                        if (text.isEmpty) {
                          return 'Por favor ingrese su email';
                        } else if (!emailRegExp.hasMatch(text)) {
                          return "El formato para correo no es correcto";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: "Escribe tu email",
                          labelText: "Email",
                          counterText: '',
                          icon: Icon(Icons.email,
                              size: 32.0, color: Colors.blue[800])),
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
                      textAlign: TextAlign.center,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      onChanged: (text) => _password = text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          hintText: "Escribe tu contraseña",
                          labelText: "Contraseña",
                          counterText: '',
                          icon: Icon(Icons.lock,
                              size: 32.0, color: Colors.blue[800])),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: IconButton(
                        onPressed: () {
                          // Validate returns true if the form is valid, or false
                          // otherwise.
                          if (_formKey.currentState.validate()) {
                            login(_email, _password);
                          }
                        },
                        icon: Icon(
                          Icons.check,
                          size: 42.0,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
