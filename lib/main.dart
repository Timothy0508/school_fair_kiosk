import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 確保 Flutter Binding 初始化
  await ThemeManager().loadThemeMode(); // 在 runApp 之前載入主題模式
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      // 使用 ValueListenableBuilder 監聽主題變化
      valueListenable: ThemeManager().themeModeNotifier,
      builder: (_, currentThemeMode, __) {
        return MaterialApp(
          title: '校園市集收銀機',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // 亮色主題
          darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.teal, brightness: Brightness.dark),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness: Brightness.dark),
          // 暗色主題
          themeMode: currentThemeMode,
          // 動態設定主題模式，根據 ValueNotifier 的值
          home: MainScreen(), // 使用 MainScreen
        );
      },
    );
  }
}
