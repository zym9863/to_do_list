import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/providers/task_provider.dart';
import 'package:to_do_list/screens/task_list_screen.dart';
import 'package:to_do_list/services/notification_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根据平台初始化数据库
  if (kIsWeb) {
    // Web平台使用 sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isAndroid) {
    // Android平台使用默认的sqflite
    // 不需要特殊配置，使用默认的databaseFactory
  } else {
    // 其他平台使用 sqflite_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 初始化通知服务
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

    // 初始化 TaskProvider 并等待其完成初始化
  final taskProvider = TaskProvider();
  await taskProvider.init();
  
  runApp(MyApp(
    taskProvider: taskProvider,
  ));
}

class MyApp extends StatelessWidget {
  final TaskProvider taskProvider;

  const MyApp({
    super.key,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: taskProvider,
      child: MaterialApp(
        title: '任务清单',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF5B7AB3),      // 低饱和度科技蓝
            secondary: const Color(0xFFFF9F6B),    // 珊瑚色
            tertiary: const Color(0xFF7DC9B5),     // 薄荷色
            background: const Color(0xFFF8F9FB),   // 更柔和的背景色
            error: const Color(0xFFFF5252),
            surface: Colors.white,
            surfaceVariant: const Color(0xFFF2F4F8), // 次表面色
            shadow: const Color(0x1A000000),       // 统一阴影颜色
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50), letterSpacing: -0.5),
            displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50), letterSpacing: -0.3),
            bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF4A4A4A), height: 1.5),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF4A4A4A), height: 1.4),
            bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8F9BB3), letterSpacing: 0.2),
          ),
          cardTheme: CardTheme(
            elevation: 1,
            shadowColor: const Color(0x1A000000),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE4E9F2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE4E9F2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF5B7AB3), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 1,
              shadowColor: const Color(0x1A000000),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          dividerTheme: DividerThemeData(
            color: const Color(0xFFE4E9F2),
            thickness: 1,
            space: 1,
          ),
        ),
        home: const TaskListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
