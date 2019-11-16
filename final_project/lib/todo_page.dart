import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color(0xFF91B3E7),
        title: new Text('Todo List')
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Add task',
        child: new Icon(Icons.add)
      ),
    );
  }

  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if(index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  void _addTodoItem(String task) {
    if(task.length > 0) {
      setState(() => _todoItems.add(task));
    }
  }

  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
        title: new Text(todoText),
        onTap: () => _promptRemoveTodoItem(index)
    );
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
              appBar: new AppBar(
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

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
  }

  void _promptRemoveTodoItem(int index) {
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
                  _removeTodoItem(index);
                  Navigator.of(context).pop();
                }
              )
            ]
          );
        }
    );
  }
}