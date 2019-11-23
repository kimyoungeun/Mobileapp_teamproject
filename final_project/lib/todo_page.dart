import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
String a;

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
              a = uuid.v4();
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

  await Firestore.instance.collection("todoList").document(a)
      .setData({
    'name' : to_do,
    'uid': userID,
    'date': selectedDate.substring(0,10),
    'finish': 0,
    'docuID': a
  });
}


class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(selectedDate.substring(0,10), style: TextStyle(color: Colors.grey[700])),
        bottomOpacity: 1,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(top: 30),
              alignment: Alignment.center,
              child: SizedBox(
                width: 370,
                height: 40,
                child : RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: (){_asyncInputDialog(context);},
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add, color: Colors.white,),
                        Text("    Add a to-do ... ", style : TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    )
                ),
              )
          ),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todoList').where('date', isEqualTo: selectedDate.substring(0,10)).where('uid', isEqualTo: userID).snapshots(),
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
          padding: EdgeInsets.only(top: 20, bottom: 30, left: 10, right: 10), //for text
          child: ListView.builder(
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
                  if(record1.uid == userID) {
                    Firestore.instance.collection("todoList").document(record1.docuID).delete();
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child : Container(
          width: 370,
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
                          ) : Text(record.name, style: TextStyle(fontSize: 18)),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:100),
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
                                              record.reference.updateData({'finish': 0});
                                            } else {
                                              record.reference.updateData({'finish': 1});
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
        ),),
    );
  }
}

class Record {
  final String name;
  final String uid;
  final String date;
  final DocumentReference reference;
  final int finish;
  final String docuID;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['uid'] != null),
        assert(map['date'] != null),
        assert(map['finish'] != null),
        assert(map['docuID'] != null),
        name = map['name'],
        uid = map['uid'],
        date = map['date'],
        finish = map['finish'],
        docuID = map['docuID'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$uid:$date:$finish:$docuID>";
}