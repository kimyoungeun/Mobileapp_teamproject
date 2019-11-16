import 'package:flutter/material.dart';
import 'signin_page.dart';

class ShrineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      home: SignInPage(),
    );
  }
}