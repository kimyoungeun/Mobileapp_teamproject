import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

String person = "Director :    ";
String collection;
int _page = 0;
String addText;

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

class _ReviewPageState extends State<ReviewPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    super.initState();
  }

  Widget _buildBody(BuildContext context, int page) {
    String collection;
    if(page == 0) collection = "movie_review";
    if(page == 1) collection = "book_review";
    if(page == 2) collection = "exhibition_review";
    if(page == 3) collection = "concert_review";
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(collection).where('uid', isEqualTo: userID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if(page == 0){
          person = "Director :   ";
          addText = "    Add a movie review ... ";
          _page = 0;
        }
        else if(page == 1){
          person = "Author :   ";
          addText = "    Add a book review ... ";
          _page = 1;
        }
        if(page == 2){
          person = "Author :   ";
          addText = "    Add a exhibition review ... ";
          _page = 2;
        }
        else if(page == 3){
          person = "Artist :   ";
          addText = "    Add a concert review ... ";
          _page = 3;
        }

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
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: Text(record.date, style: TextStyle(fontSize: 15)),
                title: InkWell(
                  child: Container(
                      padding: EdgeInsets.only(bottom: 10, top: 10),
                      child: Text(record.title, style: Theme.of(context).textTheme.title)
                  ),
                ),
                subtitle: Text(record.author, style: Theme.of(context).textTheme.subtitle),

              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Firestore.instance.collection(collection).document().delete();
                      },
                      child: Container(
                          child: Text('DELETE', style: TextStyle(color: Theme.of(context).primaryColor))
                      ),
                    ),
                    FlatButton(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
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
                            builder: (context) => AddPage(page: _page),
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text(addText, style : TextStyle(fontSize: 18, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Colors.amber,
            tabs: [
              new Tab(icon: new Icon(Icons.movie, color: Colors.grey[700])),
              new Tab(icon: new Icon(Icons.book, color: Colors.grey[700])),
              new Tab(icon: new Icon(Icons.wallpaper, color: Colors.grey[700])),
              new Tab(icon: new Icon(Icons.audiotrack, color: Colors.grey[700]))
            ],
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab
        ),
        bottomOpacity: 1,
      ),
      body: TabBarView(
        children: [
          new Center(
            child: _buildBody(context, 0),
          ),
          new Center(
            child: _buildBody(context, 1),
          ),
          new Center(
            child: _buildBody(context, 2),
          ),
          new Center(
            child: _buildBody(context, 3),
          ),
        ],
        controller: _tabController,
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
              Text(date),
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

    String detailTitle;
    if(_page == 0){
      detailTitle = "Movie Review";
      _page = 0;
    }
    else if(_page == 1){
      detailTitle = "Book Review";
      _page = 1;
    }
    if(_page == 2){
      detailTitle = "Exhibition Review";
      _page = 2;
    }
    else if(_page == 3){
      detailTitle = "Concert Review";
      _page = 3;
    }

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text(detailTitle)
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                  child: Center(
                    child : Text('Title', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                  ),
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                  fillColor: Theme.of(context).primaryColor,
                  borderColor: Theme.of(context).primaryColor,
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
            ),),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
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
                icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
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
    String detailTitle;
    if(_page == 0){
      detailTitle = "Movie Review";
      _page = 0;
    }
    else if(_page == 1){
      detailTitle = "Book Review";
      _page = 1;
    }
    if(_page == 2){
      detailTitle = "Exhibition Review";
      _page = 2;
    }
    else if(_page == 3){
      detailTitle = "Concert Review";
      _page = 3;
    }

    if(widget.page == 0) collection = "movie_review";
    if(widget.page == 1) collection = "book_review";
    if(widget.page == 2) collection = "exhibition_review";
    if(widget.page == 3) collection = "concert_review";
    double rate2;

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text(detailTitle)
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
                  ),
                  child: Center(
                    child : Text('Date', textAlign: TextAlign.center , style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.0)),
                  ),
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2.5),
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
                  fillColor: Theme.of(context).primaryColor,
                  borderColor: Theme.of(context).primaryColor,
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
            ),),
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Save", style: TextStyle(color: Colors.white),),
              onPressed: () {
                Firestore.instance.collection(collection).document().setData({
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
            ),
          ),
        ],
      ),
    );
  }
}