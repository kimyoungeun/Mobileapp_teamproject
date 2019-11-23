import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';

File _image;

String startday = "";
String lastday = "";
int difference = 0;

Future<String> _asyncInputDialog(BuildContext context) async {

  var uuid = Uuid();
  DateTime _date = DateTime.now();
  String date1 = DateTime.now().toString().substring(0,10);
  String date2 = DateTime.now().toString().substring(0,10);

  final _placeController = TextEditingController();

  Future<Null> _selectDate1(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2016),
      lastDate: DateTime(2100),
    );

    if(picked != null && picked != _date){
        date1 = picked.toString().substring(0,10);
        startday = date1;
        _date = picked;
    }
  }

  Future<Null> _selectDate2(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2016),
      lastDate: DateTime(2100),
    );

    if(picked != null && picked != _date){
        date2 = picked.toString().substring(0,10);
        lastday = date2;
        _date = picked;
    }
  }

  Widget _datepicker1() {
    return Row(
      children: <Widget>[
        Expanded (
          flex: 2,
          child: Column(
            children: <Widget>[
              Text(date1),
            ],
          ),
        ),
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                onPressed: (){
                  _selectDate1(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _datepicker2() {
    return Row(
      children: <Widget>[
        Expanded (
          flex: 2,
          child: Column(
            children: <Widget>[
              Text(date2),
            ],
          ),
        ),
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                onPressed: (){
                  _selectDate2(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 100, height: 30,
                    child: Center(
                      child : Text('Start Date', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                    ),
                  ),
                ),
                Expanded(
                  child : Container(
                    child: _datepicker1(),
                  ),
                ),
              ],
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 100, height: 30,
                    decoration: BoxDecoration(
                    ),
                    child: Center(
                      child : Text('Last Date', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                    ),
                  ),
                ),
                Expanded(
                    child : Container(
                      child: _datepicker2(),
                    )
                ),
              ],
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 100, height: 50,
                    decoration: BoxDecoration(
                    ),
                    child: Center( child : Text('Place', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0),),),
                  ),
                ),
                Expanded(
                  child: Container(
                    child : TextField(
                      controller: _placeController,
                      decoration: InputDecoration.collapsed(
                        fillColor: Colors.grey[50],
                        hintText: 'place',
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('ADD'),
            onPressed: () {
              if(_placeController.text != ""){
                startday = date1.substring(0,10);
                lastday = date2.substring(0,10);
                difference = int.parse(lastday.substring(8,10)) - int.parse(startday.substring(8,10));
                print(difference);

                String a = uuid.v4();
                Firestore.instance.collection('travelogue').document(a).setData({
                  'startdate': date1.substring(0,10),
                  'lastdate': date2.substring(0,10),
                  'month': date1.substring(0,7),
                  'place' : _placeController.text,
                  'uid': userID,
                  'docuID': a,
                  'day': difference,
                  'note': "",
                  'url': 'assets/default.jpg'
                });
              }
              Navigator.of(context).pop();
              _image = null;
            },
          ),
        ],
      );
    },
  );
}

class TraveloguePage extends StatefulWidget {
  @override
  createState() => new _TraveloguePageState();
}

class _TraveloguePageState extends State<TraveloguePage> {
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('travelogue').where('month', isEqualTo: selectedDate.substring(0,7)).where('uid', isEqualTo: userID).snapshots(),
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
      return a["startdate"].compareTo(b["startdate"]);
    });

    List<Card> _cards = reviews.map((product) {
      final record = Record.fromSnapshot(product);
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        semanticContainer: true,
        child : Container(
          padding: EdgeInsets.all(1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: Center(
                      child: (record.url == "assets/default.jpg")
                          ?
                      Image.asset('assets/default.jpg', height: 137, width: 400, fit: BoxFit.fitWidth)
                          :
                      Image.asset(record.url, height: 137, width: 400, fit: BoxFit.fill)
                    )
                  ),
                  ListTile(
                    title: InkWell(
                      child: Container(
                        padding: EdgeInsets.only(top: 40),
                        child : Center(
                          child: Text(record.place, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        )
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(record: record),
                          ),
                        );
                      },
                    )
                  ),
                ],
              )
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
                        _asyncInputDialog(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text("    Add a travelogue ... ", style : TextStyle(fontSize: 18, color: Colors.white)),
                        ],
                      )
                  ),
                )
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(top: 1.0),
                child: Center(
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      return GridView.count(
                        crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
                        mainAxisSpacing: 7.0,
                        padding: EdgeInsets.all(18.0),
                        childAspectRatio: 7.2 / 2.8,
                        children: _cards,
                      );
                    },
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
  final String startdate;
  final String lastdate;
  final String month;
  final String note;
  final String place;
  final String uid;
  final DocumentReference reference;
  final String docuID;
  final int day;
  final String url;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['startdate'] != null),
        assert(map['lastdate'] != null),
        assert(map['month'] != null),
      //assert(map['place'] != null),
        assert(map['uid'] != null),
        assert(map['docuID'] != null),
        assert(map['day'] != null),
        assert(map['url'] != null),
        startdate = map['startdate'],
        lastdate = map['lastdate'],
        month = map['month'],
        note = map['note'],
        place = map['place'],
        uid = map['uid'],
        docuID = map['docuID'],
        day = map['day'],
        url = map['url'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$startdate:$lastdate:$month:$note:$place:$uid:$docuID:$day:$url>";
}

class DetailPage extends StatefulWidget {
  final Record record;
  DetailPage({Key key, @required this.record}) : super(key: key);

  @override
  _DetailPageState createState() {
    return _DetailPageState();
  }
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin{
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPic(BuildContext context) async{
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Profile Picture uploaded");
    });
  }

  final _noteController = TextEditingController();

  int _page = 0;
  PageController _c;

  @override
  void initState(){
    _c =  new PageController(
      initialPage: _page,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _noteController.text = widget.record.note;
    String travelDay = (widget.record.startdate) + " ~ " + (widget.record.lastdate);
    return Scaffold(

      appBar: AppBar(
        title: Text(travelDay, style: TextStyle(color: Colors.white)),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 10),
                        width: 395,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                        ),
                        child: (_image != null)
                            ?
                        Image.file(_image, fit: BoxFit.fill)
                            :
                        (
                            (widget.record.url != "assets/default.jpg")
                                ? Image.asset(widget.record.url, fit: BoxFit.fill)
                                : Image.asset('assets/default.jpg', fit: BoxFit.fitWidth)
                        )
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.photo_camera,
                            size: 30.0,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: new PageView(
              controller: _c,
              onPageChanged: (newPage){
                setState((){
                  this._page=newPage;
                });
              },
              children: <Widget>[
                for(int i=1; i<= widget.record.day+1; i++)
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                      ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 99,
                      decoration: InputDecoration(
                        hintText: "Comment",
                      ),
                    ),
                  )
              ],
            ),
          ),
          Row(
            children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(bottom: 25.0),
                child : RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text("DELETE", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      Firestore.instance.collection('travelogue').document(widget.record.docuID).delete();
                      Navigator.of(context).pop();
                    }
                ),
               ),
            ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  padding: EdgeInsets.only(bottom: 25.0),
                  child : RaisedButton(
                      color: Theme.of(context).primaryColor,
                      child: Text("SAVE", style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        uploadPic(context);
                        if(_image == null){
                          widget.record.reference.updateData({
                            'note': _noteController.text,
                          });
                          Navigator.of(context).pop();
                          _image = null;
                        }
                        else{
                          widget.record.reference.updateData({
                            'note': _noteController.text,
                            'url': _image.path,
                          });
                          Navigator.of(context).pop();
                          _image = null;
                        }
                      }
                  ),
                ),
              )
            ],
          )
        ],
      ),

      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _page,
        onTap: (index){
          this._c.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
        },
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          for(int i=1; i<=widget.record.day+1;i++)
            new BottomNavigationBarItem(icon : Icon(Icons.directions_walk), title: new Text("Day " + i.toString(),)),
        ],
      ),

    );
  }
}