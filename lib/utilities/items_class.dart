import 'package:hive/hive.dart';

part 'items_class.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool checkedState;

  @HiveField(2)
  String notes;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  int colorValue;

  @HiveField(5)
  DateTime createdAt;

  Task({
    required this.title,
    required this.checkedState,
    this.notes = '',
    this.dueDate,
    this.colorValue = 0xFF2196F3, // Default blue
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
