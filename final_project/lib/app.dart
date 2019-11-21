import 'package:flutter/material.dart';
import 'signin_page.dart';

class ShrineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF91B3E7),
        accentColor: Color(0x0091B3E7),

        fontFamily: 'Montserrat',

        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal),
          subtitle: TextStyle(fontSize: 15.0, fontStyle: FontStyle.normal),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: SignInPage(),
    );
  }
}