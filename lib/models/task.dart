import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String description;
  DateTime? dueDate;
  bool isCompleted;
  String category;
  bool hasReminder;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.category = '默认',
    this.hasReminder = false,
  }) : id = id ?? const Uuid().v4();

  // 从Map创建Task对象（用于从数据库加载）
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      hasReminder: map['hasReminder'] == 1,
    );
  }

  // 将Task对象转换为Map（用于保存到数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'hasReminder': hasReminder ? 1 : 0,
    };
  }

  // 创建Task的副本
  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    String? category,
    bool? hasReminder,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }
}