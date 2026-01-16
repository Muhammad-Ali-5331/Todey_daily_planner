import 'package:flutter/material.dart';
import '../utilities/items_class.dart';
import '../utilities/HiveHelperClass.dart';
import '../utilities/task_detail_screen.dart';
import '../utilities/calendar_view_screen.dart';
import 'package:intl/intl.dart';

const clr = Colors.blueAccent;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final hiveHelper = HiveHelper();
  String _filterType = 'all'; // all, active, completed

  @override
  void dispose() {
    hiveHelper.disposeInputTextController();
    hiveHelper.updateHiveBox();
    hiveHelper.closeHiveBox();
    super.dispose();
  }

  void updateCurrentState() => setState(() {});

  List<Task> get filteredTasks {
    switch (_filterType) {
      case 'active':
        return hiveHelper.items.where((task) => !task.checkedState).toList();
      case 'completed':
        return hiveHelper.items.where((task) => task.checkedState).toList();
      default:
        return hiveHelper.items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = filteredTasks;
    final completedCount = hiveHelper.items.where((t) => t.checkedState).length;

    return Scaffold(
      backgroundColor: clr,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 30.0,
              top: 60.0,
              bottom: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30.0,
                      child: Icon(Icons.list, size: 30.0, color: clr),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CalendarViewScreen(hiveHelper: hiveHelper),
                          ),
                        ).then((_) => updateCurrentState());
                      },
                    ),
                  ],
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
                  '${hiveHelper.items.length} Tasks, $completedCount Completed',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 16),
                _buildFilterChips(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            _filterType == 'all'
                                ? 'No tasks yet!'
                                : _filterType == 'active'
                                ? 'No active tasks'
                                : 'No completed tasks',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 8),
                      itemCount: tasks.length,
                      itemBuilder: (build, index) {
                        final task = tasks[index];
                        return _buildTaskCard(task, index);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newTask = Task(title: '', checkedState: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: newTask,
                isNewTask: true,
                onSave: (task) {
                  hiveHelper.addTask(task);
                  updateCurrentState();
                },
              ),
            ),
          );
        },
        backgroundColor: clr,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _buildChip('All', 'all'),
        SizedBox(width: 8),
        _buildChip('Active', 'active'),
        SizedBox(width: 8),
        _buildChip('Done', 'completed'),
      ],
    );
  }

  Widget _buildChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: Colors.white,
      backgroundColor: Colors.white24,
      labelStyle: TextStyle(
        color: isSelected ? clr : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index) {
    final actualIndex = hiveHelper.items.indexOf(task);

    return Dismissible(
      key: Key(task.createdAt.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await hiveHelper.deleteItem(actualIndex);
        updateCurrentState();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                hiveHelper.addTask(task);
                updateCurrentState();
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(
                  task: task,
                  onSave: (updatedTask) async {
                    await hiveHelper.updateTask(actualIndex, updatedTask);
                    updateCurrentState();
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(task.colorValue),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.checkedState
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.checkedState
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      if (task.notes.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          task.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (task.dueDate != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: _getDateColor(task.dueDate!),
                            ),
                            SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDateColor(task.dueDate!),
                                fontWeight: _isOverdue(task.dueDate!)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Checkbox(
                  value: task.checkedState,
                  onChanged: (value) async {
                    await hiveHelper.updateItemState(actualIndex, value);
                    updateCurrentState();
                  },
                  activeColor: Color(task.colorValue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  Color _getDateColor(DateTime dueDate) {
    if (_isOverdue(dueDate)) return Colors.red;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day) {
      return Colors.orange;
    }

    if (dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day) {
      return Colors.blue;
    }

    return Colors.grey;
  }
}
