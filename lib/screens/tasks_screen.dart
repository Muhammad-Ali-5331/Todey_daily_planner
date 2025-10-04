import 'package:flutter/material.dart';
import '../utilities/items_class.dart';

const clr = Colors.blueAccent;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String newTaskTitle = '';
  List<Task> items = [
    Task(title: 'Take Flutter Lecture', checkedState: false),
    Task(title: 'Submit a Task on Leetcode', checkedState: true),
    Task(title: 'Submit a Task on Geeksforgeeks', checkedState: false),
  ];
  TextEditingController textEditingController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  Future closeKeyboard() async {
    FocusScope.of(context).unfocus(); // closes keyboard
    // wait a short delay (200–300 ms is usually enough for keyboard closing)
    await Future.delayed(Duration(milliseconds: 300));
  }

  void addItem(Task newTask) async {
    items.add(newTask);
    textEditingController.clear();
    await closeKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 30.0, top: 60.0, bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30.0,
                  child: Icon(Icons.list, size: 30.0, color: clr),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Todey',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 50.0,
                  ),
                ),
                Text(
                  '${items.length} Tasks',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (build, index) {
                        return CheckboxListTile(
                          secondary: TextButton(
                            onPressed: () {
                              setState(() {
                                items.removeAt(index);
                              });
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                          title: Text(
                            items[index].title,
                            style: TextStyle(color: Colors.black),
                          ),
                          value: items[index].checkedState,
                          onChanged: (newValue) {
                            setState(() {
                              items[index].checkedState =
                                  newValue ?? items[index].checkedState;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: buildAddTaskTopUp);
        },
        backgroundColor: clr,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildAddTaskTopUp(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Add Task',
              style: TextStyle(
                color: clr,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: textEditingController,
              onChanged: (val) {
                setState(() {
                  newTaskTitle = val;
                });
              },
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Enter title of task',
                icon: Icon(Icons.calendar_month),
                enabledBorder: UnderlineInputBorder(
                  // default border (not focused)
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  // border when focused
                  borderSide: BorderSide(color: clr, width: 2.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newTaskTitle == '') {
                  await closeKeyboard();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('[!] Title of task cannot be empty.'),
                    ),
                  );
                } else {
                  Task newTask = Task(title: newTaskTitle, checkedState: false);
                  if (items.contains(newTask)) {
                    await closeKeyboard();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('[!] Title of task cannot be empty.'),
                      ),
                    );
                  } else {
                    addItem(newTask);
                  }
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: clr,
                  borderRadius: BorderRadius.horizontal(),
                ),
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
