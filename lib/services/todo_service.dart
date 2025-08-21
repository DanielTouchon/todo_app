import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/todo.dart';

const String _baseUrl = 'http://10.0.2.2:8000';

class TodoService with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoService() {
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _todos = data
          .map(
            (json) => Todo(
              id: json['id'],
              title: json['title'],
              dueDate: json['due_date'] != null
                  ? DateTime.parse(json['due_date'])
                  : null,
            ),
          )
          .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> addTodo(String title, {DateTime? dueDate}) async {
    if (title.isNotEmpty) {
      final response = await http.post(
        Uri.parse('$_baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'due_date': dueDate?.toIso8601String(),
        }),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> newTodoData = jsonDecode(response.body);
        _todos.add(
          Todo(
            id: newTodoData['id'],
            title: newTodoData['title'],
            dueDate: newTodoData['due_date'] != null
                ? DateTime.parse(newTodoData['due_date'])
                : null,
          ),
        );
        notifyListeners();
      } else {
        throw Exception('Failed to add todo');
      }
    }
  }

  Future<void> editTodo(
    String id,
    String newTitle, {
    DateTime? newDueDate,
  }) async {
    if (newTitle.isNotEmpty) {
      final response = await http.put(
        Uri.parse('$_baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': newTitle,
          'due_date': newDueDate?.toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        final index = _todos.indexWhere((todo) => todo.id == id);
        if (index != -1) {
          _todos[index].title = newTitle;
          _todos[index].dueDate = newDueDate;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to edit todo');
      }
    }
  }

  Future<void> removeTodo(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));
    if (response.statusCode == 204) {
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete todo');
    }
  }
}
