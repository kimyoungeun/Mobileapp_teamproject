import 'package:flutter/material.dart';
import 'todo_check_page.dart';

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
            child: Text("날짜", style: TextStyle(color: Color(0xFF91B3E7), fontSize: 40, fontWeight: FontWeight.bold)),
          ),
          _buildTodoList(),
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

  Widget _buildTodoList() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 30, bottom: 30, left: 30, right: 30), //for text
        margin: EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20), //for border
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: Color(0xFF91B3E7)),
          borderRadius: const BorderRadius.all(const Radius.circular(8)),
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            if(index < _todoItems.length) {
              return _buildTodoItem(_todoItems[index], index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTodoItem(String todoText, int index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: ListTile(
              title: new Text(todoText),
              //onTap: () => _promptRemoveTodoItem(index)
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () {
            setState(() {
              if(_doneItems.contains(todoText) == false){
                setState(() => _doneItems.add(todoText));
                setState(() => _notdoneItems.remove(todoText));
              }
              else if(_doneItems.contains(todoText) == true){
                setState(() => _notdoneItems.add(todoText));
                setState(() => _doneItems.remove(todoText));
              }
            });
            //_removeTodoItem(index);
          }
        ),
      ],
    );
  }

  /*void _promptRemoveTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Mark "${_todoItems[index]}" as done?'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop()
            ),
            new FlatButton(
              child: new Text('MARK AS DONE'),
              onPressed: () {
                setState(() => _doneItems.add("${_todoItems[index]}"));
                //_removeTodoItem(index);
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }*/

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

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
  }
}