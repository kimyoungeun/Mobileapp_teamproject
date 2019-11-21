import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';

class TraveloguePage extends StatefulWidget {
  @override
  createState() => new _TraveloguePageState();
}

class _TraveloguePageState extends State<TraveloguePage> {
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text("TraveloguePage", style: TextStyle(color: Colors.grey[700])),
        bottomOpacity: 1,
      ),
    );
  }
}