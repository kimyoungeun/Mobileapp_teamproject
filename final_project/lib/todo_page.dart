import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';

Future<String> _asyncInputDialog(BuildContext context) async {
  String to_do = '';
  return showDialog<String>(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter something to do...'),
        content: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
                  autofocus: true,
                  onChanged: (value) {
                    to_do = value;
                  },
                ))
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('ADD'),
            onPressed: () {
              if(to_do != '')
                createRecord(to_do);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void createRecord(String to_do) async {
  final databaseReference = Firestore.instance;

  await Firestore.instance.collection("todoList").document(to_do)
      .setData({
    'name' : to_do,
    'id': userID,
    'date': selectedDate.substring(0,10),
    'todo': [to_do],
    'done': [],
    'notdone': [to_do],
    'finish': 0
  });
}

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
            margin: EdgeInsets.only(top: 170, left: 250),
            child: Text(selectedDate.substring(0,10), style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              alignment: Alignment.center,
              child: SizedBox(
                width: 350,
                height: 40,
                child : RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: (){_asyncInputDialog(context);},
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add, color: Colors.white,),
                        Text("    Add  a  to-do ... ", style : TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    )
                ),
              )
          ),
          _buildBody(context),
          SizedBox(height: 100),
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
          padding: EdgeInsets.only(top: 0, bottom: 30, left: 10, right: 10), //for text
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: snapshot.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: ObjectKey(snapshot[index]),
                child: Container(
                  child: _buildListItem(context, snapshot[index]),
                ),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  var item = snapshot.elementAt(index);
                  final record1 = Record.fromSnapshot(snapshot[index]);
                  if(record1.id == userID) {
                    Firestore.instance.collection("todoList").document(record1.name).delete();
                  }
                },
              );
            },
          )
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
    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
      child: Container(
        width: 400,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Container(
                  padding: EdgeInsets.only(left:30),
                  child : Row(
                    children: <Widget>[
                      Container(
                        width: 140,
                        child : alreadySaved? new RichText(
                          text: new TextSpan(
                            text: record.name,
                            style: new TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ) : Text(record.name, style: TextStyle(fontSize: 20)),
                      ),
                      Container(
                        padding: EdgeInsets.only(left:120),
                        child : FittedBox(
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.check,
                                        color: alreadySaved ? Theme.of(context).primaryColor : Colors.grey[700],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (alreadySaved) {
                                            record.reference.updateData({'done': FieldValue.arrayRemove([record.name]), 'notdone': FieldValue.arrayUnion([record.name]), 'finish': 0});
                                          } else {
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
                  )
              ),
            ),
          ],
        ),
      ),
    );
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