import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/todo_service.dart';
import '../models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Todo? _editingTodo;
  DateTime? _selectedDueDate;

  bool get _isEditing => _editingTodo != null;

  void _handleAction(TodoService todoService) {
    if (_isEditing) {
      todoService.editTodo(
        _editingTodo!.id,
        _textController.text,
        newDueDate: _selectedDueDate,
      );
    } else {
      todoService.addTodo(_textController.text, dueDate: _selectedDueDate);
    }
    _textController.clear();
    _dateController.clear();
    setState(() {
      _editingTodo = null;
      _selectedDueDate = null;
    });
  }

  void _startEditMode(Todo todo) {
    setState(() {
      _editingTodo = todo;
      _textController.text = todo.title;
      _selectedDueDate = todo.dueDate;
      if (todo.dueDate != null) {
        _dateController.text = DateFormat.yMd().add_jm().format(todo.dueDate!);
      } else {
        _dateController.clear();
      }
    });
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateController.text = DateFormat.yMd().add_jm().format(
        _selectedDueDate!,
      );
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
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: _isEditing
                        ? 'Edit To-Do Item'
                        : 'New To-Do Item',
                    suffixIcon: IconButton(
                      icon: Icon(_isEditing ? Icons.save : Icons.add),
                      onPressed: () => _handleAction(todoService),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Select Due Date and Time (Optional)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: _selectedDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                                _dateController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  readOnly: true,
                  onTap: _selectDateTime,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todoService.todos.length,
              itemBuilder: (context, index) {
                final todoItem = todoService.todos[index];
                return ListTile(
                  title: Text(todoItem.title),
                  subtitle: todoItem.dueDate != null
                      ? Text(
                          DateFormat.yMd().add_jm().format(todoItem.dueDate!),
                        )
                      : null,
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
