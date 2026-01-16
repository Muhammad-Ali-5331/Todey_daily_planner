import 'package:flutter/material.dart';
import '../utilities/items_class.dart';
import '../utilities/HiveHelperClass.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'task_detail_screen.dart';

class CalendarViewScreen extends StatefulWidget {
  final HiveHelper hiveHelper;

  const CalendarViewScreen({super.key, required this.hiveHelper});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day) {
    return widget.hiveHelper.getTasksForDate(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Calendar View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
          ),
          SizedBox(height: 8),
          Expanded(child: _buildTasksList()),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    if (_selectedDay == null) {
      return Center(child: Text('Select a date'));
    }

    final tasks = _getTasksForDay(_selectedDay!);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 4,
              height: double.infinity,
              color: Color(task.colorValue),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.checkedState
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: task.notes.isNotEmpty
                ? Text(task.notes, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: Checkbox(
              value: task.checkedState,
              onChanged: (value) {
                setState(() {
                  task.checkedState = value ?? false;
                  task.save();
                });
              },
              activeColor: Color(task.colorValue),
            ),
            onTap: () {
              final taskIndex = widget.hiveHelper.items.indexOf(task);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    task: task,
                    onSave: (updatedTask) async {
                      await widget.hiveHelper.updateTask(
                        taskIndex,
                        updatedTask,
                      );
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
