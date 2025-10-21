import 'package:flutter/material.dart';
import 'package:todey/screens/tasks_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utilities/items_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TasksScreen());
  }
}
