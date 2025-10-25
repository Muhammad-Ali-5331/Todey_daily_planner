import 'package:flutter/material.dart';
import '../utilities/items_class.dart';
import '../utilities/HiveHelperClass.dart';

const clr = Colors.blueAccent;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? errorMessage;
  String newTaskTitle = '';
  late final hiveHelper = HiveHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    hiveHelper.disposeInputTextController();
    hiveHelper.updateHiveBox();
    hiveHelper.closeHiveBox();
    super.dispose();
  }

  void updateCurrentState() => setState(() {});

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
                  '${hiveHelper.items.length} Tasks',
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
                      itemCount: hiveHelper.items.length,
                      itemBuilder: (build, index) {
                        return CheckboxListTile(
                          secondary: TextButton(
                            onPressed: () async {
                              await hiveHelper.deleteItem(index);
                              updateCurrentState();
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                          title: Text(
                            hiveHelper.items[index].title,
                            style: TextStyle(
                              color: Colors.black,
                              decoration: hiveHelper.items[index].checkedState
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          value: hiveHelper.items[index].checkedState,
                          onChanged: (newValue) async {
                            await hiveHelper.updateItemState(index, newValue);
                            updateCurrentState();
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
          hiveHelper.clearInputField();
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
                  controller: hiveHelper.inputFieldController,
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
                    if (newTaskTitle.trim() == '') {
                      setModalState(() {
                        errorMessage = 'Title of Task cannot be empty';
                      });
                    } else {
                      if ((hiveHelper.items.any(
                        (task) =>
                            task.title.toLowerCase().trim() ==
                            newTaskTitle.toLowerCase().trim(),
                      ))) {
                        setModalState(() {
                          errorMessage = 'Same Task cannot be added Again';
                        });
                      } else {
                        hiveHelper.addTask(
                          Task(title: newTaskTitle, checkedState: false),
                        );
                        hiveHelper.clearInputField();
                        updateCurrentState();
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
