import 'package:flutter/material.dart';
import 'package:todo_app/screens/todo_list_screen.dart';
import 'package:todo_app/services/todo_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoService(),
      child: MaterialApp(
        title: 'To-Do List',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const TodoListScreen(),
      ),
    );
  }
}
