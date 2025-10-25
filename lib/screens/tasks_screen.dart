import 'package:flutter/material.dart';
import '../utilities/items_class.dart';
import 'package:hive/hive.dart';

const clr = Colors.blueAccent;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? errorMessage; // null if no error, string if there is an error
  String newTaskTitle = '';
  late List<Task> items;
  TextEditingController textEditingController = TextEditingController();
  late Box<Task> tasksBox;

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box<Task>('tasksBox');
    if (tasksBox.isEmpty) {
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

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    updateHiveBox();
    tasksBox.close();
    super.dispose();
  }

  Future closeKeyboard() async {
    FocusScope.of(context).unfocus(); // closes keyboard
    await Future.delayed(Duration(milliseconds: 500));
  }

  void updateHiveBox() {
    for (var item in items) {
      tasksBox.add(item);
    }
  }

  void updateItemsList() {
    if (mounted) {
      setState(() {
        items = tasksBox.values.toList();
      });
    }
  }

  void addItem(Task newTask) async {
    textEditingController.clear();
    tasksBox.add(newTask);
    updateItemsList();
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
                            onPressed: () async {
                              await tasksBox.deleteAt(index);
                              updateItemsList();
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                          title: Text(
                            items[index].title,
                            style: TextStyle(
                              color: Colors.black,
                              decoration: items[index].checkedState
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          value: items[index].checkedState,
                          onChanged: (newValue) async {
                            final task = tasksBox.getAt(index);
                            task?.checkedState = newValue ?? task.checkedState;
                            await task?.save();
                            updateItemsList();
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
          textEditingController.clear();
          showModalBottomSheet(context: context, builder: buildAddTaskTopUp);
        },
        backgroundColor: clr,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildAddTaskTopUp(BuildContext context) {
    return StatefulBuilder(
      //StatefulBuilder to update bottom sheet independently
      builder: (context, setModalState) {
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
                      errorMessage = null;
                    });
                  },
                  maxLength: 50,
                  decoration: InputDecoration(
                    errorText: errorMessage,
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
                    await closeKeyboard();
                    if (newTaskTitle.trim() == '') {
                      setModalState(() {
                        errorMessage = 'Title of Task cannot be empty';
                      });
                    } else {
                      if ((items.any(
                        (task) =>
                            task.title.toLowerCase().trim() ==
                            newTaskTitle.toLowerCase().trim(),
                      ))) {
                        setModalState(() {
                          errorMessage = 'Same Task cannot be added Again';
                        });
                      } else {
                        addItem(Task(title: newTaskTitle, checkedState: false));
                        textEditingController.clear();
                        setModalState(() {
                          errorMessage = null;
                          newTaskTitle = '';
                        });
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: clr),
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
      },
    );
  }
}
