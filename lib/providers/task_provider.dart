import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/database_service.dart';
import 'package:to_do_list/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  List<Task> _tasks = [];
  List<String> _categories = ['默认', '工作', '学习', '生活'];
  bool _isLoading = false;

  TaskProvider() {
    // 移除自动初始化
  }

  // 初始化提供者
  Future<void> init() async {
    await _notificationService.init();
    await _notificationService.requestPermissions();
    await _initProvider();
  }

  // 初始化提供者
  Future<void> _initProvider() async {
    await _loadCategories();
    await loadTasks();
  }

  // 加载任务
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _databaseService.getTasks();
    } catch (e) {
      debugPrint('加载任务失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载分类
  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList('categories');
      if (savedCategories != null && savedCategories.isNotEmpty) {
        _categories = savedCategories;
      }
    } catch (e) {
      debugPrint('加载分类失败: $e');
    }
  }

  // 保存分类
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
    } catch (e) {
      debugPrint('保存分类失败: $e');
    }
  }

  // 添加任务
  Future<void> addTask(Task task) async {
    try {
      await _databaseService.insertTask(task);
      _tasks.add(task);
      notifyListeners();

      // 如果任务有提醒，设置通知
      if (task.hasReminder && task.dueDate != null) {
        await _notificationService.scheduleTaskReminder(task);
      }
    } catch (e) {
      debugPrint('添加任务失败: $e');
    }
  }

  // 更新任务
  Future<void> updateTask(Task updatedTask) async {
    try {
      await _databaseService.updateTask(updatedTask);
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();

        // 取消旧的提醒
        await _notificationService.cancelTaskReminder(updatedTask);
        
        // 如果任务有提醒，设置新的通知
        if (updatedTask.hasReminder && updatedTask.dueDate != null) {
          await _notificationService.scheduleTaskReminder(updatedTask);
        }
      }
    } catch (e) {
      debugPrint('更新任务失败: $e');
    }
  }

  // 删除任务
  Future<void> deleteTask(String id) async {
    try {
      await _databaseService.deleteTask(id);
      final task = _tasks.firstWhere((task) => task.id == id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();

      // 取消任务提醒
      await _notificationService.cancelTaskReminder(task);
    } catch (e) {
      debugPrint('删除任务失败: $e');
    }
  }

  // 切换任务完成状态
  Future<void> toggleTaskCompletion(String id) async {
    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final task = _tasks[index];
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        await _databaseService.updateTask(updatedTask);
        _tasks[index] = updatedTask;
        notifyListeners();

        // 如果任务已完成，取消提醒
        if (updatedTask.isCompleted) {
          await _notificationService.cancelTaskReminder(updatedTask);
        } else if (updatedTask.hasReminder && updatedTask.dueDate != null) {
          // 如果任务未完成且有提醒，重新设置提醒
          await _notificationService.scheduleTaskReminder(updatedTask);
        }
      }
    } catch (e) {
      debugPrint('切换任务状态失败: $e');
    }
  }

  // 添加分类
  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      await _saveCategories();
      notifyListeners();
    }
  }

  // 删除分类
  Future<void> deleteCategory(String category) async {
    if (category != '默认') {
      _categories.remove(category);
      await _saveCategories();
      
      // 将该分类下的任务移到默认分类
      for (final task in _tasks.where((task) => task.category == category)) {
        final updatedTask = task.copyWith(category: '默认');
        await _databaseService.updateTask(updatedTask);
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      }
      
      notifyListeners();
    }
  }

  // 搜索任务
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // 获取特定分类的任务
  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  // Getters
  List<Task> get tasks => _tasks;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
}