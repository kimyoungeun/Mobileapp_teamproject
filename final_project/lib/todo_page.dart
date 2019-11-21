import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';

List<String> _todoItems = [];
List<String> _doneItems = [];
List<String> _notdoneItems = [];

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Text(selectedDate.substring(0,10), style: TextStyle(color: Color(0xFF91B3E7), fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildBody(context),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 175, bottom: 30),
                child: FittedBox(
                    child: FloatingActionButton(
                      backgroundColor: Color(0xFF91B3E7),
                      child: new Icon(Icons.add),
                      onPressed: _pushAddTodoScreen,
                    )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todoList').where('date', isEqualTo: selectedDate.substring(0,10)).where('id', isEqualTo: userID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {

      snapshot.sort((a, b) {
        return a["finish"].compareTo(b["finish"]);
      });

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10), //for text
        margin: EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20), //for border
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: Color(0xFF91B3E7)),
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: snapshot.map((data) => _buildListItem(context, data)).toList(),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    bool alreadySaved;
    if(record.finish == 0)
      alreadySaved = false;
    else if(record.finish == 1)
      alreadySaved = true;
    //final bool alreadySaved = _doneItems.contains(record.name);
    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      child: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: IconButton(
                  icon: Icon(Icons.delete),
                  color: Color(0xFF91B3E7),
                  onPressed: () {
                    if(record.id == userID) {
                      Firestore.instance.collection("todoList").document(record.name).delete();
                      setState(() => _doneItems.remove(record.name));
                      setState(() => _notdoneItems.remove(record.name));
                    }
                  }
              ),
              title: Text(record.name),
              trailing: FittedBox(
                child: Row(
                  children: [
                    Column(
                      children: <Widget>[
                        SizedBox(width: 30),
                        IconButton(
                            icon: Icon(
                              alreadySaved ? Icons.favorite : Icons.favorite_border,
                              color: alreadySaved ? Color(0xFF91B3E7) : null,
                            ),
                            onPressed: () {
                              setState(() {
                                if (alreadySaved) {
                                  setState(() => _notdoneItems.add(record.name));
                                  setState(() => _doneItems.remove(record.name));
                                  record.reference.updateData({'done': FieldValue.arrayRemove([record.name]), 'notdone': FieldValue.arrayUnion([record.name]), 'finish': 0});
                                } else {
                                  setState(() => _doneItems.add(record.name));
                                  setState(() => _notdoneItems.remove(record.name));
                                  record.reference.updateData({'notdone': FieldValue.arrayRemove([record.name]), 'done': FieldValue.arrayUnion([record.name]), 'finish': 1});
                                }
                              });
                            }
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
              appBar: new AppBar(
                  backgroundColor: Color(0xFF91B3E7),
                  title: new Text('Add a new task')
              ),
              body: new TextField(
                autofocus: true,
                onSubmitted: (val) {
                  String docu = val;
                  Firestore.instance.collection("todoList").document(docu)
                      .setData({
                    'name' : val,
                    'id': userID,
                    'date': selectedDate.substring(0,10),
                    'todo': [val],
                    'done': [],
                    'notdone': [val],
                    'finish': 0
                      });
                  _addTodoItem(val);
                  Navigator.pop(context);
                },
                decoration: new InputDecoration(
                    hintText: 'Enter something to do...',
                    contentPadding: const EdgeInsets.all(16.0)
                ),
              )
          );
        }
      )
    );
  }

  void _addTodoItem(String task) {
    if(task.length > 0) {
      setState(() => _todoItems.add(task));
      setState(() => _notdoneItems.add(task));
    }
  }
}

class Record {
  final String name;
  final String id;
  final String date;
  List todo = List<String>();
  List done = List<String>();
  List notdone = List<String>();
  final DocumentReference reference;
  final int finish;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['id'] != null),
        assert(map['date'] != null),
        assert(map['todo'] != null),
        assert(map['done'] != null),
        assert(map['notdone'] != null),
        assert(map['finish'] != null),
        name = map['name'],
        id = map['id'],
        date = map['date'],
        todo = map['todo'],
        done = map['done'],
        notdone = map['notdone'],
        finish = map['finish'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$id:$date:$todo:$done:$notdone:$finish>";
}





int doneCount = 0;
int notdoneCount = 0;
int percent = 0;

class TodoCheck extends StatefulWidget {
  //final List<String> donedata;
  //final List<String> notdonedata;
  //TodoCheck({Key key, @required this.donedata, this.notdonedata}) : super(key: key);
  final Record record;
  TodoCheck({Key key, @required this.record}) : super(key: key);

  @override
  createState() => new TodoCheckState();
}

class TodoCheckState extends State<TodoCheck> {
  Widget build(BuildContext context) {

    //doneCount = widget.donedata.length;
    //notdoneCount = widget.notdonedata.length;
    doneCount = widget.record.done.length;
    notdoneCount = widget.record.notdone.length;
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
//                  if(index < widget.donedata.length) {
//                    return ListTile(title: Text(widget.donedata[index]));
//                  }
                  if(index < widget.record.done.length) {
                    return ListTile(title: Text(widget.record.done[index]));
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
//                  if(index < widget.notdonedata.length) {
//                    return ListTile(title: Text(widget.notdonedata[index]));
//                  }
                  if(index < widget.record.notdone.length) {
                    return ListTile(title: Text(widget.record.notdone[index]));
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