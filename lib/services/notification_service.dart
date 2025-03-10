import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:to_do_list/models/task.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // 单例模式 - 使用懒加载方式
  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  // 初始化通知服务
  Future<void> init() async {
    // 初始化时区数据
    tz_data.initializeTimeZones();
    
    // 初始化Android设置
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // 初始化iOS设置
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // 初始化通知插件
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 处理通知点击事件
      },
    );
  }

  // 请求通知权限
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // 为任务设置提醒
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null || !task.hasReminder) return;
    
    // 设置提醒时间（在截止日期前1小时）
    final scheduledDate = tz.TZDateTime.from(
      task.dueDate!.subtract(const Duration(hours: 1)),
      tz.local,
    );
    
    // 如果提醒时间已经过去，则不设置提醒
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;
    
    // 通知详情
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'todo_reminder',
      '任务提醒',
      channelDescription: '任务截止日期提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // 安排通知
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      '任务提醒',
      '${task.title} 将在1小时后到期',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 取消任务提醒
  Future<void> cancelTaskReminder(Task task) async {
    await _flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }

  // 取消所有提醒
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}