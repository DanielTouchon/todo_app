import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/todo_service.dart';
import '../models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _textController = TextEditingController();
  Todo? _editingTodo;

  bool get _isEditing => _editingTodo != null;

  void _handleAction(TodoService todoService) {
    if (_isEditing) {
      todoService.editTodo(_editingTodo!.id, _textController.text);
    } else {
      todoService.addTodo(_textController.text);
    }
    _textController.clear();
    setState(() {
      _editingTodo = null;
    });
  }

  void _startEditMode(Todo todo) {
    setState(() {
      _editingTodo = todo;
      _textController.text = todo.title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoService = Provider.of<TodoService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Edit To-Do Item' : 'New To-Do Item',
                suffixIcon: IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  onPressed: () => _handleAction(todoService),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todoService.todos.length,
              itemBuilder: (context, index) {
                final todoItem = todoService.todos[index];
                return ListTile(
                  title: Text(todoItem.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _startEditMode(todoItem),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => todoService.removeTodo(todoItem.id),
                      ),
                    ],
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
