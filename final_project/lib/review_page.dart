import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget _buildstar(int num){
  return Container(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(num, (index){
        return IconTheme(
          data: IconThemeData(
            color: Colors.yellow,
            size: 30,
          ),
          child: Icon(Icons.star),
        );
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

        return _buildListCard(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildListCard(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<DocumentSnapshot> reviews = snapshot;

    List<Card> _cards = reviews.map((product) {
      final record = Record.fromSnapshot(product);
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.blueAccent, width: 2),
                    )
                ),
                child: Text(
                  record.date,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight
                      .bold),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: FittedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 3),
                              Text(
                                record.title,
                                style: TextStyle(fontSize: 11),
                              ),
                              SizedBox(height: 3),
                              Text(
                                record.author,
                                style: TextStyle(fontSize: 11),
                              ),
                              SizedBox(height: 3),
                              _buildstar(record.star),
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
                                  alignment: Alignment.topRight,
                                  child: Text('more',
                                    style: TextStyle(fontSize: 14, color: Colors.blue),
                                    textAlign: TextAlign.right,),
                                ),
                              )
                            ],
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Center(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return GridView.count(
                      crossAxisCount: orientation == Orientation.portrait ? 1 : 1,
                      padding: EdgeInsets.all(16.0),
                      childAspectRatio: 8.0 / 2.5,
                      children: _cards,
                    );
                  },
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget> [
                Center(
                  child: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPage(page: _page),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Note'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Date', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'title',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Title', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'title',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Author', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'author',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Rating', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _starController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'rating',
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: TextField(
                controller: _noteController,
                maxLines: 99,
                decoration: InputDecoration(
                  hintText: "Comment!",
                  border: OutlineInputBorder(),
                ),
              ),
            ),),
          RaisedButton(
            child: Text("Save"),
            onPressed: () {
              widget.record.reference.updateData({
                'date': _dateController.text,
                'title': _titleController.text,
                'author': _authorController.text,
                'star': int.parse(_starController.text),
                'note': _noteController.text,
                'uid': "",
              });
              _dateController.clear();
              _titleController.clear();
              _authorController.clear();
              _starController.clear();
              _noteController.clear();
              Navigator.of(context).pop();
            },
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Note'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Date', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'date',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Title', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'title',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Author', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'author',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text('Rating', textAlign: TextAlign.center,),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _starController,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'rating',
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: TextField(
                controller: _noteController,
                maxLines: 99,
                decoration: InputDecoration(
                  hintText: "Comment!",
                  border: OutlineInputBorder(),
                ),
              ),
            ),),
          RaisedButton(
            child: Text("Save"),
            onPressed: () {
              Firestore.instance.collection(collection).add({
                'date': _dateController.text,
                'title': _titleController.text,
                'author': _authorController.text,
                'star': int.parse(_starController.text),
                'note': _noteController.text,
                'uid': ""
              });
              _dateController.clear();
              _titleController.clear();
              _authorController.clear();
              _starController.clear();
              _noteController.clear();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}