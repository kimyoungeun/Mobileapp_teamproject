import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_check_page.dart';
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
      appBar: new AppBar(
        backgroundColor: Color(0xFF91B3E7),
        title: new Text('Todo List')
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30),
            child: Text(selectedDate.substring(0,10), style: TextStyle(color: Color(0xFF91B3E7), fontSize: 40, fontWeight: FontWeight.bold)),
          ),
          _buildBody(context),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 50, bottom: 50),
                child: FittedBox(
                  child: FloatingActionButton(
                    backgroundColor: Color(0xFF91B3E7),
                    child: new Icon(Icons.add),
                    onPressed: _pushAddTodoScreen,
                  )
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 100, bottom: 50),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
                  child: RaisedButton(
                    child: new Text('CHECK', style: TextStyle(fontSize: 20, color: Colors.white)),
                    color: Color(0xFF91B3E7),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TodoCheck(donedata: _doneItems, notdonedata: _notdoneItems)),
                      );
                    }
                  ),
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
      stream: Firestore.instance.collection('todoList').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10), //for text
        margin: EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20), //for border
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
    final bool alreadySaved = _doneItems.contains(record.name);
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
                  Firestore.instance.collection("todoList").document(record.name).delete();
                  setState(() => _doneItems.remove(record.name));
                  setState(() => _notdoneItems.remove(record.name));
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
                              record.reference.updateData({'notdone': FieldValue.arrayUnion([record.name])});
                              setState(() => _doneItems.remove(record.name));
                              record.reference.updateData({'done': FieldValue.arrayRemove([record.name])});
                            } else {
                              setState(() => _doneItems.add(record.name));
                              record.reference.updateData({'done': FieldValue.arrayUnion([record.name])});
                              setState(() => _notdoneItems.remove(record.name));
                              record.reference.updateData({'notdone': FieldValue.arrayRemove([record.name])});
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
                    .setData({'name' : val, 'id': userID, 'todo': [val], 'done': [""], 'notdone': [val]});
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
  List todo = List<String>();
  List done = List<String>();
  List notdone = List<String>();
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['id'] != null),
        assert(map['todo'] != null),
        assert(map['done'] != null),
        assert(map['notdone'] != null),
        name = map['name'],
        id = map['id'],
        todo = map['todo'],
        done = map['done'],
        notdone = map['notdone'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$id:$todo:$done:$notdone>";
}