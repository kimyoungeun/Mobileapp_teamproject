import 'package:flutter/material.dart';

class TodoCheck extends StatefulWidget {
  final List<String> donedata;
  final List<String> notdonedata;
  TodoCheck({Key key, @required this.donedata, this.notdonedata}) : super(key: key);

  @override
  createState() => new TodoCheckState();
}

class TodoCheckState extends State<TodoCheck> {
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xFF91B3E7),
          title: new Text('Todo Check')
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text("날짜", style: TextStyle(color: Color(0xFF91B3E7), fontSize: 40, fontWeight: FontWeight.bold)),
          ),
//          Row(
//            children: <Widget>[
//              Column(
//                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
//                    margin: EdgeInsets.only(left: 50, top: 30),
//                    decoration: BoxDecoration(
//                      border: Border.all(width: 3, color: Color(0xFF91B3E7)),
//                      borderRadius: const BorderRadius.all(const Radius.circular(8)),
//                    ),
//                    child: Text("Done", style: TextStyle(color: Colors.black, fontSize: 20)),
//                  ),
//                ],
//              ),
//              Column(
//                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
//                    margin: EdgeInsets.only(left: 70, top: 30),
//                    decoration: BoxDecoration(
//                      border: Border.all(width: 3, color: Color(0xFF91B3E7)),
//                      borderRadius: const BorderRadius.all(const Radius.circular(8)),
//                    ),
//                    child: Text("To do", style: TextStyle(color: Colors.black, fontSize: 20)),
//                  ),
//                ],
//              ),
//            ],
//          ),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
            margin: EdgeInsets.only(top: 30, right: 250),
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Color(0xFF91B3E7)),
              borderRadius: const BorderRadius.all(const Radius.circular(8)),
            ),
            child: Text("Done", style: TextStyle(color: Colors.black, fontSize: 20)),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if(index < widget.donedata.length) {
                    return _buildTodoItem(widget.donedata[index], index);
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
            margin: EdgeInsets.only(right: 250),
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Color(0xFF91B3E7)),
              borderRadius: const BorderRadius.all(const Radius.circular(8)),
            ),
            child: Text("To do", style: TextStyle(color: Colors.black, fontSize: 20)),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if(index < widget.notdonedata.length) {
                    return _buildTodoItem(widget.notdonedata[index], index);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(String todoText, int index) {
    return Container(
      child: ListTile(
        title: new Text(todoText),
      ),
    );
  }
}