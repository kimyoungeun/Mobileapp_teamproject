import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

String person = "Director :    ";

Widget _buildstar(int num){
  return Container(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index){
        return (index < num ? IconTheme(
          data: IconThemeData(
            color: Colors.yellow,
            size: 20,
          ),
          child: Icon(Icons.star),
        ) : IconTheme(
          data: IconThemeData(
            color: Colors.grey[350],
            size: 20,
          ),
          child: Icon(Icons.star),
        ));
      }),
    ),
  );
}



class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() {
    return _ReviewPageState();
  }
}

class _ReviewPageState extends State<ReviewPage> {
  int _page = 0;
  PageController _c;

  @override
  void initState() {
    _c = new PageController(
      initialPage: _page,
    );
  }

  Widget _buildBody(BuildContext context, int page) {
    String collection;
    if(page == 0) collection = "movie_review";
    if(page == 1) collection = "book_review";
    if(page == 2) collection = "exhibition_review";
    if(page == 3) collection = "concert_review";
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return
          _buildListCard(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildListCard(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<DocumentSnapshot> reviews = snapshot;

    List<Card> _cards = reviews.map((product) {
      final record = Record.fromSnapshot(product);
      return
        Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF91B3E7), width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width:90,
                  padding: EdgeInsets.only(left : 4.0),
                  child: Center(
                    child: Text(
                      record.date,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight
                          .bold, color: Colors.grey[800],),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 4.0),
                    height: 100, child: VerticalDivider(color: Colors.blueAccent)),
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(6.0, 0.0, 16.0, 8.0),
                              child: FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 3),
                                    Row(
                                      children : <Widget> [
                                        Container(
                                          padding : EdgeInsets.only(left: 3.0),
                                          child : Text(
                                            "Title :    ",
                                            style: TextStyle(fontSize: 11, color: Colors.grey[800], fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                          ),),
                                        Text(
                                          record.title,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],),
                                    SizedBox(height: 3),
                                    Row(
                                      children : <Widget> [
                                        Container(
                                          padding : EdgeInsets.only(left: 3.0),
                                          child : Text(
                                            person,
                                            style: TextStyle(fontSize: 11, color: Colors.grey[800], fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                          ),),
                                        Text(
                                          record.author,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],),
                                    SizedBox(height: 5),
                                    _buildstar(record.star),


                                  ],
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(record: record),
                          ),
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.only(left: 40.0),
                          alignment: Alignment.bottomLeft,
                          child:
//                      Text('more',
//                        style: TextStyle(fontSize: 14, color: Colors.blue),
//                        textAlign: TextAlign.right,),
                          Icon(Icons.arrow_forward,)
                      ),
                    )],),
              ],
            ),
          ),
        );
    }).toList();

    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return GridView.count(
                      crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
                      mainAxisSpacing: 24.0,
                      padding: EdgeInsets.all(16.0),
                      childAspectRatio: 8.0 / 2.5,
                      children:
                      _cards,
                    );
                  },
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget> [
                Container(
                  margin: EdgeInsets.only(left: 180, bottom: 50),
                  child: FittedBox(
                    child: Center(
                      child : FloatingActionButton(
                        backgroundColor: Color(0xFF91B3E7),
                        child: new Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPage(page: _page),
                            ),
                          );
                        },
                      ),),
                  ),
                ),
              ],
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xFF91B3E7),
          title: new Text('Review Note')
      ),
      bottomNavigationBar: new BottomNavigationBar(
        currentIndex: _page,
        onTap: (index){
          this._c.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
        },
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: Icon(Icons.movie), title: new Text("Movie")),
          new BottomNavigationBarItem(icon: Icon(Icons.book),title: new Text("Book")),
          new BottomNavigationBarItem(icon: Icon(Icons.wallpaper),title: new Text("Exhibition")),
          new BottomNavigationBarItem(icon: Icon(Icons.audiotrack),title: new Text("Concert")),
        ],
      ),
      body: new PageView(
        controller: _c,
        onPageChanged: (newPage){
          setState((){
            this._page=newPage;
            if(newPage == 0){
              person = "Director :   ";
            }
            else if(newPage == 1){
              person = "Author :   ";
            }
          });
        },
        children: <Widget>[
          new Center(
            child: _buildBody(context, _page),
          ),
          new Center(
            child: _buildBody(context, _page),
          ),
          new Center(
            child: _buildBody(context, _page),
          ),
          new Center(
            child: _buildBody(context, _page),
          ),
        ],
      ),
    );
  }
}

class Record {
  final String date;
  final String title;
  final String author;
  final int star;
  final String note;
  final String uid;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['date'] != null),
        assert(map['title'] != null),
        assert(map['author'] != null),
        assert(map['star'] != null),
        assert(map['note'] != null),
        assert(map['uid'] != null),
        date = map['date'],
        title = map['title'],
        author = map['author'],
        note = map['note'],
        uid = map['uid'],
        star = map['star'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$title:0>";
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
  DateTime _date = DateTime.now();
  String date = DateTime.now().toString().substring(0,10);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2016),
      lastDate: DateTime(2100),
    );

    if(picked != null && picked != _date){
      setState(() {
        date = picked.toString().substring(0,10);
        _date = picked;
      });
    }
  }

  Widget _datepicker() {
    return Row(
      children: <Widget>[
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(date,),
            ],
          ),
        ),
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.calendar_today, color: Color(0xFF91B3E7),),
                onPressed: (){
                  _selectDate(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  final _dateController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _starController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _dateController.text = widget.record.date;
    _titleController.text = widget.record.title;
    _authorController.text = widget.record.author;
    _starController.text = widget.record.star.toString();
    _noteController.text = widget.record.note;
    double rate = widget.record.star.toDouble();

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xFF91B3E7),
          title: new Text('Review Note')
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Date', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child: _datepicker(),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Title', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0),),),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 35.0),
                  child : TextField(
                    controller: _titleController,
                    decoration: InputDecoration.collapsed(
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                  ),),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center(child : Text('Director', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 35.0),
                  child : TextField(
                    controller: _authorController,
                    decoration: InputDecoration.collapsed(
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                  ),),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Rating', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child:
//                TextField(
//                  controller: _starController,
//                  decoration: InputDecoration(
//                    filled: true,
//                  ),
//                ),
                FlutterRatingBar(
                  initialRating: rate,
                  itemSize: 30.0,
                  fillColor: Color(0xFF91B3E7),
                  borderColor: Color(0xFF91B3E7),
                  allowHalfRating: false,
                  onRatingUpdate: (rating) {
                    rate = rating;
                    print(rating);
                  },
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF91B3E7), width: 1.5),
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
            ),),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Color(0xFF91B3E7),
              child: Text("Save", style: TextStyle(color: Colors.white),),
              onPressed: () {
                widget.record.reference.updateData({
                  'date': date,
                  'title': _titleController.text,
                  'author': _authorController.text,
                  'star': rate.toInt(),
                  'note': _noteController.text,
                  'uid': userID,
                });
                _dateController.clear();
                _titleController.clear();
                _authorController.clear();
                _starController.clear();
                _noteController.clear();
                Navigator.of(context).pop();
              },
            ),),
        ],
      ),
    );
  }
}

class AddPage extends StatefulWidget{
  final int page;

  AddPage({Key key, @required this.page}) : super(key: key);


  @override
  AddPageState createState() {
    return AddPageState();
  }
}

class AddPageState extends State<AddPage>{

  DateTime _date = DateTime.now();
  String date = DateTime.now().toString().substring(0,10);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2016),
      lastDate: DateTime(2100),
    );

    if(picked != null && picked != _date){
      setState(() {
        date = picked.toString().substring(0,10);
        _date = picked;
      });
    }
  }

  Widget _datepicker() {
    return Row(
      children: <Widget>[
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              Text(date,),
            ],
          ),
        ),
        Expanded (
          flex: 1,
          child: Column(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.calendar_today, color: Color(0xFF91B3E7),),
                onPressed: (){
                  _selectDate(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  final _dateController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _starController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String collection;
    if(widget.page == 0) collection = "movie_review";
    if(widget.page == 1) collection = "book_review";
    if(widget.page == 2) collection = "exhibition_review";
    if(widget.page == 3) collection = "concert_review";
    double rate2;
    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Color(0xFF91B3E7),
          title: new Text('Review Note')
      ),
      body:

      Column(
        children: <Widget>[
          SizedBox(height: 20.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Date', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child: _datepicker(),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Title', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0),),),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 35.0),
                  child : TextField(
                    controller: _titleController,
                    decoration: InputDecoration.collapsed(
                      fillColor: Colors.grey[50],
                      hintText: 'title',
                      filled: true,
                    ),
                  ),),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center(child : Text('Director', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 35.0),
                  child : TextField(
                    controller: _authorController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'director',
                      fillColor: Colors.grey[50],
                      filled: true,
                    ),
                  ),),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.fromLTRB(24.0, 10.0, 30.0, 10.0),
                  width: 80, height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF91B3E7), width: 2.5),
                  ),
                  child: Center( child : Text('Rating', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),),
                ),
              ),
              Expanded(
                flex: 2,
                child:
//                TextField(
//                  controller: _starController,
//                  decoration: InputDecoration(
//                    filled: true,
//                  ),
//                ),
                FlutterRatingBar(
                  initialRating: 0,
                  itemSize: 30.0,
                  fillColor: Color(0xFF91B3E7),
                  borderColor: Color(0xFF91B3E7),
                  allowHalfRating: false,
                  onRatingUpdate: (rating) {
                    rate2 = rating;
                    print(rating);
                  },
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF91B3E7), width: 1.5),
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
            ),),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Color(0xFF91B3E7),
              child: Text("Save", style: TextStyle(color: Colors.white),),
              onPressed: () {
                Firestore.instance.collection(collection).add({
                  'date': date,
                  'title': _titleController.text,
                  'author': _authorController.text,
                  'star': rate2.toInt(),
                  'note': _noteController.text,
                  'uid': userID,
                });
                _dateController.clear();
                _titleController.clear();
                _authorController.clear();
                _starController.clear();
                _noteController.clear();
                Navigator.of(context).pop();
              },
            ),),
        ],
      ),
    );
  }
}