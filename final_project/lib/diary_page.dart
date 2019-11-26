import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';
import 'package:uuid/uuid.dart';

class DiaryPage extends StatefulWidget {
  @override
  createState() => new _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('diary').where('month', isEqualTo: selectedDate.substring(0,7)).where('uid', isEqualTo: userID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return
          _buildListCard(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildListCard(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<DocumentSnapshot> reviews = snapshot;

    snapshot.sort((a, b) {
      return a["date"].compareTo(b["date"]);
    });

    List<Card> _cards = reviews.map((product) {
      final record = Record.fromSnapshot(product);
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Container(
                  child : Text(record.date.substring(8,10), style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor)),
                ),

                title: record.noteTitle.length > 20 ?
                Container(
                    padding: EdgeInsets.all(10),
                    child:Text(record.noteTitle.substring(0,20), style: Theme.of(context).textTheme.title))
                    : Container(
                  padding: EdgeInsets.all(10),
                  child:Text(record.noteTitle, style: Theme.of(context).textTheme.title),),

                subtitle: record.note.length > 20 ?
                Container(
                    padding: EdgeInsets.only(left: 10),
                    child :Text(record.note.substring(0,20), style: Theme.of(context).textTheme.subtitle))
                    : Container(
                  padding: EdgeInsets.only(left: 10),
                  child :Text(record.note, style: Theme.of(context).textTheme.subtitle),),

              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 0),
                      child: FlatButton(
                        onPressed: () {
                          Firestore.instance.collection("diary").document(record.docuID).delete();
                        },
                        child: Container(
                            child: Text('DELETE', style: TextStyle(color: Theme.of(context).primaryColor))
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(record: record),
                            ),
                          );
                        },
                        child: Container(
                            child: Text('MORE', style: TextStyle(color: Theme.of(context).primaryColor))
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
        backgroundColor: Theme.of(context).accentColor,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text("    Add a diary", style : TextStyle(fontSize: 18, color: Colors.white)),
                        ],
                      )
                  ),
                )
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Center(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(8, 10, 8, 15),
                    children: reviews
                        .map((item) =>
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ExpansionPanelList(
                              animationDuration: Duration(seconds: 1),
                              children: [
                                ExpansionPanel(
                                  body: Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Column(
                                      children:<Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 30, right: 30),
                                          child: Divider(color: Colors.black54),
                                        ),
                                        SizedBox(height: 10,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 30, right: 30),
                                          child: Center(
                                            child : Text(
                                              Record.fromSnapshot(item).note,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 18,
                                              ),
                                            ),),
                                        ),
                                        SizedBox(height: 30,),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                                padding: EdgeInsets.only(left: 250, bottom: 10),
                                                child: GestureDetector(
                                                  child: Text("EDIT", style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),),
                                                  onTap: (){
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => DetailPage(record: Record.fromSnapshot(item)),
                                                      ),
                                                    );
                                                  },
                                                )
                                            ),
                                          ],
                                        )
                                      ],),
                                  ),
                                  headerBuilder: (BuildContext context, bool isExpanded) {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      child: ListTile(
                                        leading:
                                        Container(
                                          child : Text(Record.fromSnapshot(item).date.substring(8,10), style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor)),
                                        ),
                                        title : Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child : Text(
                                            Record.fromSnapshot(item).noteTitle,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18,
                                            ),
                                          ),),
                                      ),
                                    );
                                  },
                                  isExpanded: Record.fromSnapshot(item).check[0],
                                )
                              ],
                              expansionCallback: (int s, bool status) {
                                setState(() {
                                  Firestore.instance.collection('diary').document(Record.fromSnapshot(item).docuID).setData({
                                    'date': Record.fromSnapshot(item).date,
                                    'noteTitle': Record.fromSnapshot(item).noteTitle,
                                    'note': Record.fromSnapshot(item).note,
                                    'uid': userID,
                                    'docuID': Record.fromSnapshot(item).docuID,
                                    'month': selectedDate.substring(0,7),
                                    'check' : [!status, !status]
                                  });
                                });
                              },
                            ),
                          ),
                        ),)
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(selectedDate.substring(0, 7), style: TextStyle(color: Colors.grey[700])),
        bottomOpacity: 1,
      ),
      body: _buildBody(context),
    );
  }
}

class Record {
  final String date;
  final String month;
  final String note;
  final String noteTitle;
  final String uid;
  final DocumentReference reference;
  final String docuID;
  List check = List<bool>();

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['date'] != null),
        assert(map['month'] != null),
        assert(map['note'] != null),
        assert(map['noteTitle'] != null),
        assert(map['uid'] != null),
        assert(map['docuID'] != null),
        date = map['date'],
        month = map['month'],
        note = map['note'],
        noteTitle = map['noteTitle'],
        uid = map['uid'],
        docuID = map['docuID'],
        check = map['check'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$date:$month:$note:$noteTitle:$uid:$docuID>";
}

class AddPage extends StatefulWidget{
  @override
  AddPageState createState() {
    return AddPageState();
  }
}

class AddPageState extends State<AddPage>{

  final _noteController = TextEditingController();
  final _noteTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var uuid = Uuid();

    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text("Diary", style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            child: TextField(
              style: TextStyle(fontSize: 20),
              controller: _noteTitleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Title",
                contentPadding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
              ),
              margin: EdgeInsets.all(15.0),
              child: TextField(
                controller: _noteController,
                maxLines: 99,
                decoration: InputDecoration(
                  hintText: "Comment",
                  contentPadding: const EdgeInsets.all(20.0),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("SAVE", style: TextStyle(color: Colors.white),),
              onPressed: () {
                String a = uuid.v4();
                Firestore.instance.collection('diary').document(a).setData({
                  'date': selectedDate.substring(0,10),
                  'month': selectedDate.substring(0,7),
                  'note': _noteController.text,
                  'noteTitle': _noteTitleController.text,
                  'uid': userID,
                  'docuID': a,
                  'check': [false, false]
                });
                _noteController.clear();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final Record record;

  DetailPage({Key key, @required this.record}) : super(key: key);

  @override
  _DetailPageState createState() {
    return _DetailPageState();
  }
}

class _DetailPageState extends State<DetailPage> {

  final _noteController = TextEditingController();
  final _noteTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _noteController.text = widget.record.note;
    _noteTitleController.text = widget.record.noteTitle;

    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text(widget.record.date, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          Padding(
              padding : EdgeInsets.only(right : 20, top: 20),
              child : GestureDetector(
                child: Text("DELETE", style: TextStyle(color: Colors.white),),
                onTap: (){
                  Firestore.instance.collection('diary').document(widget.record.docuID).delete();
                  Navigator.of(context).pop();
                },
              )
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            child: TextField(
              style: TextStyle(fontSize: 20),
              controller: _noteTitleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Title",
                contentPadding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
              ),
              margin: EdgeInsets.all(15.0),
              child: TextField(
                controller: _noteController,
                maxLines: 99,
                decoration: InputDecoration(
                  hintText: "Comment",
                  contentPadding: const EdgeInsets.all(20.0),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("SAVE", style: TextStyle(color: Colors.white),),
              onPressed: () {
                widget.record.reference.updateData({
                  'note': _noteController.text,
                });
                _noteController.clear();

                widget.record.reference.updateData({
                  'noteTitle': _noteTitleController.text,
                });
                _noteTitleController.clear();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}