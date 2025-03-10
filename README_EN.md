# To-Do List Application

A comprehensive Flutter to-do list management application that supports multiple platforms.

## Key Features

- Task Management
  - Create, edit, and delete tasks
  - Set task title, description, and due date
  - Mark task completion status
  - Task category management
  - Task search functionality

- Reminder Notifications
  - Support for task reminders
  - Automatic notifications 1 hour before task due
  - Local notifications support for Android and iOS platforms

- Data Persistence
  - Local storage using SQLite database
  - Web platform data storage support

## Technical Features

- State management using Provider
- Data persistence with SQLite
- Web platform SQLite storage support
- Integration of Flutter Local Notifications
- UUID generation for unique identifiers
- Date formatting and localization support

## Supported Platforms

- Android
- iOS
- Web
- Windows
- Linux
- macOS

## Getting Started

1. Ensure Flutter SDK is installed and development environment is configured

2. Clone the project and install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Dependencies

- provider: ^6.1.1 - State management
- sqflite: ^2.3.2 - SQLite database
- sqflite_common_ffi_web: ^0.4.2 - Web platform SQLite support
- flutter_local_notifications: ^16.3.2 - Local notifications
- intl: ^0.19.0 - Date formatting
- uuid: ^4.3.3 - Unique ID generation
- path_provider: ^2.1.2 - File path management
- shared_preferences: ^2.2.2 - Simple data storage