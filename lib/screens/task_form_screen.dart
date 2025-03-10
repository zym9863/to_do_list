import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _hasReminder = false;
  String _selectedCategory = '默认';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // 编辑模式：填充现有任务数据
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _hasReminder = widget.task!.hasReminder;
      _selectedCategory = widget.task!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? '添加任务' : '编辑任务'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '任务标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入任务标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '任务描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('设置提醒'),
                subtitle: const Text('在截止日期前提醒'),
                value: _hasReminder,
                onChanged: _dueDate == null
                    ? null
                    : (value) {
                        setState(() {
                          _hasReminder = value;
                        });
                      },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('保存任务'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return ListTile(
      title: const Text('截止日期'),
      subtitle: Text(
        _dueDate == null ? '未设置' : dateFormat.format(_dueDate!),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      _dueDate ?? DateTime.now()),
                );
                if (time != null) {
                  setState(() {
                    _dueDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              }
            },
          ),
          if (_dueDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _dueDate = null;
                  _hasReminder = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final categories = taskProvider.categories;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('分类'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ...categories.map((category) => ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    )),
                ActionChip(
                  label: const Text('添加分类'),
                  avatar: const Icon(Icons.add),
                  onPressed: () {
                    _showAddCategoryDialog(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '分类名称',
            hintText: '输入新分类名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newCategory = controller.text.trim();
              if (newCategory.isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false)
                    .addCategory(newCategory);
                setState(() {
                  _selectedCategory = newCategory;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final title = _titleController.text;
      final description = _descriptionController.text;

      if (widget.task == null) {
        // 创建新任务
        final newTask = Task(
          title: title,
          description: description,
          dueDate: _dueDate,
          hasReminder: _hasReminder && _dueDate != null,
          category: _selectedCategory,
        );
        taskProvider.addTask(newTask);
      } else {
        // 更新现有任务
        final updatedTask = widget.task!.copyWith(
          title: title,
          description: description,
          dueDate: _dueDate,
          hasReminder: _hasReminder && _dueDate != null,
          category: _selectedCategory,
        );
        taskProvider.updateTask(updatedTask);
      }

      Navigator.pop(context);
    }
  }
}