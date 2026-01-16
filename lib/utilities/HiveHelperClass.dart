import 'package:hive/hive.dart';
import '../utilities/items_class.dart';
import 'package:flutter/material.dart';

class HiveHelper {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');
  late List<Task> items;
  final TextEditingController inputFieldController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  HiveHelper() {
    initializeItems();
  }

  void addTask(Task newTask) {
    inputFieldController.clear();
    notesController.clear();
    _tasksBox.add(newTask);
    updateItemsList();
  }

  void initializeItems() {
    if (_tasksBox.isEmpty) {
      items = [
        Task(
          title: 'Take Flutter Lecture',
          checkedState: false,
          notes: 'Learn about state management and widgets',
          dueDate: DateTime.now().add(Duration(days: 1)),
          colorValue: 0xFF2196F3,
        ),
        Task(
          title: 'Submit a Task on Leetcode',
          checkedState: true,
          notes: 'Complete daily challenge',
          dueDate: DateTime.now(),
          colorValue: 0xFF4CAF50,
        ),
        Task(
          title: 'Submit a Task on Geeksforgeeks',
          checkedState: false,
          notes: 'Practice DSA problems',
          colorValue: 0xFFE91E63,
        ),
      ];
      updateHiveBox();
    } else {
      updateItemsList();
    }
  }

  void updateItemsList() {
    items = _tasksBox.values.toList();
    // Sort by date (tasks with dates first, then by creation date)
    items.sort((a, b) {
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future updateTask(int index, Task updatedTask) async {
    await _tasksBox.putAt(index, updatedTask);
    updateItemsList();
  }

  Future updateItemState(int index, bool? newValue) async {
    final task = _tasksBox.getAt(index);
    task?.checkedState = newValue ?? task.checkedState;
    await task?.save();
    updateItemsList();
  }

  Future deleteItem(int index) async {
    // Find actual index in box
    final task = items[index];
    final boxIndex = _tasksBox.values.toList().indexOf(task);
    if (boxIndex != -1) {
      await _tasksBox.deleteAt(boxIndex);
    }
    updateItemsList();
  }

  void updateHiveBox() {
    for (var item in items) {
      _tasksBox.add(item);
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return items.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  List<Task> getTasksByColor(int colorValue) {
    return items.where((task) => task.colorValue == colorValue).toList();
  }

  void clearInputField() {
    inputFieldController.clear();
    notesController.clear();
  }

  void disposeInputTextController() {
    inputFieldController.dispose();
    notesController.dispose();
  }

  void closeHiveBox() => _tasksBox.close();
}
