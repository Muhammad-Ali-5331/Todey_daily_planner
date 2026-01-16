import 'package:flutter/material.dart';
import '../utilities/items_class.dart';
import '../utilities/task_colors.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;
  final bool isNewTask;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onSave,
    this.isNewTask = false,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController notesController;
  late DateTime? selectedDate;
  late int selectedColor;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    notesController = TextEditingController(text: widget.task.notes);
    selectedDate = widget.task.dueDate;
    selectedColor = widget.task.colorValue;
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(selectedColor)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (titleController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Title cannot be empty';
      });
      return;
    }

    final updatedTask = Task(
      title: titleController.text.trim(),
      checkedState: widget.task.checkedState,
      notes: notesController.text.trim(),
      dueDate: selectedDate,
      colorValue: selectedColor,
      createdAt: widget.task.createdAt,
    );

    widget.onSave(updatedTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(selectedColor),
        title: Text(widget.isNewTask ? 'New Task' : 'Edit Task'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveTask)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Task Title',
                      border: InputBorder.none,
                      errorText: errorMessage,
                    ),
                    maxLength: 50,
                    onChanged: (value) {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        widget.task.checkedState
                            ? 'Completed'
                            : 'Not Completed',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Color(selectedColor),
                    ),
                    title: Text('Due Date'),
                    subtitle: Text(
                      selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                          : 'No date set',
                    ),
                    trailing: selectedDate != null
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                              });
                            },
                          )
                        : null,
                    onTap: () => _selectDate(context),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.palette, color: Color(selectedColor)),
                    title: Text('Color'),
                    subtitle: Text(TaskColors.getColorName(selectedColor)),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(selectedColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: () {
                      _showColorPicker();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: notesController,
                maxLines: null,
                minLines: 8,
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Color'),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: TaskColors.palette.length,
            itemBuilder: (context, index) {
              final color = TaskColors.palette[index];
              final isSelected = color.value == selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color.value;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
