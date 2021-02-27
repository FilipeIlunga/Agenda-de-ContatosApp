import 'package:agenda_de_contatos/View/homePage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'View/contactPage.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
