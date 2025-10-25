import 'package:hive/hive.dart';
import '../utilities/items_class.dart';
import 'package:flutter/material.dart';

class HiveHelper {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');
  late List<Task> items;
  final TextEditingController inputFieldController = TextEditingController();
  HiveHelper() {
    initializeItems();
  }

  void addTask(Task newTask) {
    inputFieldController.clear();
    _tasksBox.add(newTask);
    updateItemsList();
  }

  void initializeItems() {
    if (_tasksBox.isEmpty) {
      items = [
        Task(title: 'Take Flutter Lecture', checkedState: false),
        Task(title: 'Submit a Task on Leetcode', checkedState: true),
        Task(title: 'Submit a Task on Geeksforgeeks', checkedState: false),
      ];
      updateHiveBox();
    } else {
      updateItemsList();
    }
  }

  void updateItemsList() => items = _tasksBox.values.toList();

  Future updateItemState(int index, bool? newValue) async {
    final task = _tasksBox.getAt(index);
    task?.checkedState = newValue ?? task.checkedState;
    await task?.save();
    updateItemsList();
  }

  Future deleteItem(int index) async {
    await _tasksBox.deleteAt(index);
    updateItemsList();
  }

  void updateHiveBox() {
    for (var item in items) {
      _tasksBox.add(item);
    }
  }

  void clearInputField() => inputFieldController.clear();
  void disposeInputTextController() => inputFieldController.dispose();
  void closeHiveBox() => _tasksBox.close();
}
