
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';




class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CalendarController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 200,),
            TableCalendar(calendarController: _controller,)
          ],
        ),
      )
      //_buildBody(context),
    );
  }
}

