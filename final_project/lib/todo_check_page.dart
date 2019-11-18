import 'package:flutter/material.dart';
import 'home.dart';

class TodoCheck extends StatefulWidget {
  final List<String> donedata;
  final List<String> notdonedata;
  TodoCheck({Key key, @required this.donedata, this.notdonedata}) : super(key: key);

  @override
  createState() => new TodoCheckState();
}

int doneCount = 0;
int notdoneCount = 0;
int percent = 0;

class TodoCheckState extends State<TodoCheck> {
  Widget build(BuildContext context) {

    doneCount = widget.donedata.length;
    notdoneCount = widget.notdonedata.length;
    percent = ((doneCount/(notdoneCount+doneCount))*100).toInt();

    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xFF91B3E7),
          title: new Text('Todo Check')
      ),
      body: Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(selectedDate.substring(0,10), style: TextStyle(color: Color(0xFF91B3E7), fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 30, right: 30, top: 10),
              margin: EdgeInsets.only(top: 30, right: 250),
              decoration: BoxDecoration(
              border: Border.all(width: 3, color: Color(0xFF91B3E7)),
              borderRadius: const BorderRadius.all(const Radius.circular(8)),
              ),
              child: Text("Done", style: TextStyle(color: Colors.black, fontSize: 20)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if(index < widget.donedata.length) {
                    return ListTile(title: Text(widget.donedata[index]));
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 30, right: 30, top: 10),
              margin: EdgeInsets.only(top: 30, right: 250),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Color(0xFF91B3E7)),
                borderRadius: const BorderRadius.all(const Radius.circular(8)),
              ),
              child: Text("To do", style: TextStyle(color: Colors.black, fontSize: 20)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if(index < widget.notdonedata.length) {
                    return ListTile(title: Text(widget.notdonedata[index]));
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 150),
                  margin: EdgeInsets.only(bottom: 30, left: 30, right: 30),
                  width: 350, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF91B3E7),
                    border: Border.all(width: 3, color: Color(0xFF91B3E7)),
                    borderRadius: const BorderRadius.all(const Radius.circular(8)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Center(child: Text("$percent", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      Center(child: Text("%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}