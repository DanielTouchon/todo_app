import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import 'package:uuid/uuid.dart';

class TodoService with ChangeNotifier {
  final List<Todo> _todos = [];
  final Uuid _uuid = const Uuid();

  List<Todo> get todos => _todos;

  void addTodo(String title) {
    if (title.isNotEmpty) {
      _todos.add(Todo(id: _uuid.v4(), title: title));
      notifyListeners();
    }
  }

  void editTodo(String id, String newTitle) {
    if (newTitle.isNotEmpty) {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].title = newTitle;
        notifyListeners();
      }
    }
  }

  void removeTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }
}
