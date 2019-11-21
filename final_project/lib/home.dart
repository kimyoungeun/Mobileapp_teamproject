import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'todo_page.dart';
import 'diary_page.dart';
import 'travelogue_page.dart';
import 'review_page.dart';

String selectedDate = DateTime.now().toString();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarController _controller;
  int _page = 0;
  PageController _c;

  @override
  void initState(){
    _c =  new PageController(
      initialPage: _page,
    );
    super.initState();
    _controller = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _page,
        onTap: (index){
          this._c.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
        },
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: new Icon(Icons.calendar_today), title: new Text("Calendar")),
          new BottomNavigationBarItem(icon: new Icon(Icons.list), title: new Text("To do List")),
          new BottomNavigationBarItem(icon: new Icon(Icons.border_color), title: new Text("Diary")),
          new BottomNavigationBarItem(icon: new Icon(Icons.directions_walk), title: new Text("Travelogue")),
          new BottomNavigationBarItem(icon: new Icon(Icons.star), title: new Text("Review")),
        ],
      ),
      body: new PageView(
        controller: _c,
        onPageChanged: (newPage){
          setState((){
            this._page=newPage;
          });
        },
        children: <Widget>[
          new Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 0,),
                  TableCalendar(
                    calendarStyle: CalendarStyle(
                      todayColor: Color(0xFF91B3E7),
                    ),
                    onDaySelected: (date, events){
                      print(date.toIso8601String());
                      selectedDate = date.toIso8601String();
                    },
                    headerStyle: HeaderStyle(
                        headerPadding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                        centerHeaderTitle: true,
                        formatButtonVisible: false
                    ),
                    calendarController: _controller,
                  )
                ],
              ),
            ),
          ),
          new Scaffold(
            body: TodoList(),
          ),
          new Scaffold(
            body: DiaryPage(),
          ),
          new Scaffold(
            body: TraveloguePage(),
          ),
          new Scaffold(
            body: ReviewPage(),
          ),
        ],
      ),
    );
  }
}
