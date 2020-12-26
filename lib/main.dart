import 'package:flutter/material.dart';

import './config/application.dart';

import './views/pages/home.dart';

void main() {
  Application.initApp();

  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: new PagesHome(),
      onGenerateRoute: Application.router.generator,
    );
  }

}
