import 'package:flutter/material.dart';
import 'package:qrapp/services/dataStorage.dart';
import 'package:qrapp/services/http.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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