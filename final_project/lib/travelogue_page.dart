import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'home.dart';
import 'package:uuid/uuid.dart';

String startday = "";
String lastday = "";
int difference = 0;

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
        child: new InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(record: record),
              ),
            );
          },
          child : Container(
            padding: EdgeInsets.all(1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  leading: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top:0),
                        child : Text(record.startdate, style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)),),
                      Container(
                        padding: EdgeInsets.only(top:0),
                        child : Text("-", style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor)),),
                      Container(
                        padding: EdgeInsets.only(top:5),
                        child : Text(record.lastdate, style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)),),
                    ],
                  ),
                  title: Container(
                    padding: EdgeInsets.only(top:40),
                    child : Center(child : Text(record.place, style: TextStyle(fontSize: 40),),
                    ),
                  ),
                ),
//              ButtonTheme.bar(
//                child: ButtonBar(
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.only(top: 0),
//                      child: FlatButton(
//                        onPressed: () {
//                          Firestore.instance.collection("travelogue").document(record.docuID).delete();
//                        },
//                        child: Container(
//                            child: Text('DELETE', style: TextStyle(color: Theme.of(context).primaryColor))
//                        ),
//                      ),
//                    ),
//                    Container(
//                      padding: EdgeInsets.only(top: 0),
//                      child: FlatButton(
//                        onPressed: () {
//                          Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                              builder: (context) => DetailPage(record: record),
//                            ),
//                          );
//                        },
//                        child: Container(
//                            child: Text('MORE', style: TextStyle(color: Theme.of(context).primaryColor))
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
              ],
            ),
          ),),
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

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['startdate'] != null),
        assert(map['lastdate'] != null),
        assert(map['month'] != null),
      //assert(map['place'] != null),
        assert(map['uid'] != null),
        assert(map['docuID'] != null),
        startdate = map['startdate'],
        lastdate = map['lastdate'],
        month = map['month'],
        note = map['note'],
        place = map['place'],
        uid = map['uid'],
        docuID = map['docuID'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$startdate:$lastdate:$month:$note:$place:$uid:$docuID>";
}

class AddPage extends StatefulWidget{
  @override
  AddPageState createState() {
    return AddPageState();
  }
}

class AddPageState extends State<AddPage>{

  var uuid = Uuid();
  DateTime _date = DateTime.now();
  String date1 = DateTime.now().toString().substring(0,10);
  String date2 = DateTime.now().toString().substring(0,10);

  Future<Null> _selectDate1(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2016),
      lastDate: DateTime(2100),
    );

    if(picked != null && picked != _date){
      setState(() {
        date1 = picked.toString().substring(0,10);
        startday = date1;
        _date = picked;
      });
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
      setState(() {
        date2 = picked.toString().substring(0,10);
        lastday = date2;
        _date = picked;
      });
    }
  }

  Widget _datepicker1() {
    return Row(
      children: <Widget>[
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(date1,),
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
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(date2,),
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

  final _placeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var uuid = Uuid();

    startday = date1.substring(0,10);
    lastday = date2.substring(0,10);
    difference = int.parse(lastday.substring(8,10)) - int.parse(startday.substring(8,10));

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text("Travelogue", style: TextStyle(color: Colors.white),)
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 150,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 40.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
                  ),
                  child: Center(
                    child : Text('StartDate', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child : Container(
                  padding:EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 10.0),
                  child: _datepicker1(),),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 40.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
                  ),
                  child: Center(
                    child : Text('LastDate', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child : Container(
                    padding:EdgeInsets.fromLTRB(0.0, 40.0, 30.0, 10.0),
                    child: _datepicker2(),)
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 55.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    //border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
                  ),
                  child: Center( child : Text('Place', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0),),),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 35.0, top: 40),
                  child : TextField(
                    controller: _placeController,
                    decoration: InputDecoration.collapsed(
                      fillColor: Colors.grey[50],
                      hintText: 'place',
                      filled: true,
                    ),
                  ),),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(bottom: 50.0, top : 150,),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Next", style: TextStyle(color: Colors.white),),
              onPressed: () {
                String a = uuid.v4();
                Firestore.instance.collection('travelogue').document(a).setData({
                  'startdate': date1.substring(0,10),
                  'lastdate': date2.substring(0,10),
                  'month': date1.substring(0,7),
                  'place' : _placeController.text,
                  'uid': userID,
                  'docuID': a,
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextPage(),
                  ),
                );
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

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text(widget.record.startdate, style: TextStyle(color: Colors.white))
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              //border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
            child: TextField(
              controller: _noteTitleController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: widget.record.place,
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
                  hintText: "Comment!",
                  contentPadding: const EdgeInsets.all(20.0),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Save", style: TextStyle(color: Colors.white),),
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

class NextPage extends StatefulWidget {

  @override
  _NextPageState createState() {
    return _NextPageState();
  }
}

class _NextPageState extends State<NextPage> with SingleTickerProviderStateMixin{

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

    print(difference);

    return Scaffold(
      appBar: AppBar(

        title: Text('Travelogue', style: TextStyle(color: Colors.white),),
      ),
      body: new PageView(
        controller: _c,
        onPageChanged: (newPage){
          setState((){
            this._page=newPage;
          });
        },
        children: <Widget>[

          for(int i=1; i<= difference; i++)
            new Scaffold( body: Center(child: Text("Day " + i.toString() + " Page")),)

//            new Scaffold(
//              body: Center(child:Text("Day 1 Page")),
//            ),
//          new Scaffold(
//            body: Center(child:Text("Day 2 Page")),
//          ),

        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _page,
        onTap: (index){
          this._c.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
        },
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          //new BottomNavigationBarItem(icon: new Icon(Icons.calendar_today), title: new Text("Calendar")),
          for(int i=1; i<=difference;i++)
            new BottomNavigationBarItem(icon : Icon(Icons.directions_walk), title: new Text("Day " + i.toString(),)),


        ],
      ),
    );
  }
}