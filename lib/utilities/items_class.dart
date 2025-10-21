import 'package:hive/hive.dart';

part 'items_class.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool checkedState;
  Task({required this.title, required this.checkedState});
}
