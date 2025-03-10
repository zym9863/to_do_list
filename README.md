[English](README_EN.md) | 简体中文

# 待办事项应用

一个功能完整的Flutter待办事项管理应用，支持多平台运行。

## 主要功能

- 任务管理
  - 创建、编辑和删除任务
  - 设置任务标题、描述和截止日期
  - 标记任务完成状态
  - 任务分类管理
  - 任务搜索功能

- 提醒通知
  - 支持为任务设置提醒
  - 在任务截止前1小时自动发送通知
  - 支持Android和iOS平台的本地通知

- 数据持久化
  - 使用SQLite数据库本地存储
  - 支持Web平台的数据存储

## 技术特性

- 使用Provider进行状态管理
- 采用SQLite进行数据持久化存储
- 支持Web平台的SQLite存储
- 集成Flutter Local Notifications实现本地通知
- 使用UUID生成唯一标识符
- 支持日期格式化和本地化

## 支持平台

- Android
- iOS
- Web
- Windows
- Linux
- macOS

## 开始使用

1. 确保已安装Flutter SDK并配置好开发环境

2. 克隆项目并安装依赖：
   ```bash
   flutter pub get
   ```

3. 运行应用：
   ```bash
   flutter run
   ```

## 依赖说明

- provider: ^6.1.1 - 状态管理
- sqflite: ^2.3.2 - SQLite数据库
- sqflite_common_ffi_web: ^0.4.2 - Web平台SQLite支持
- flutter_local_notifications: ^16.3.2 - 本地通知
- intl: ^0.19.0 - 日期格式化
- uuid: ^4.3.3 - 生成唯一ID
- path_provider: ^2.1.2 - 文件路径管理
- shared_preferences: ^2.2.2 - 简单数据存储
