import 'package:flutter/material.dart';

import 'screens/cashier_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/report_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '校園園遊會收銀機',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.teal, brightness: Brightness.dark),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark),
      home: MainScreen(), // 使用 MainScreen 作為首頁，整合 NavigationRail
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 當前選中的導航索引

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index; // 更新選中的索引
              });
            },
            labelType: NavigationRailLabelType.all, // 顯示所有標籤
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.shopping_basket),
                selectedIcon: Icon(Icons.shopping_basket),
                label: Text('收銀機'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.history),
                label: Text('歷史紀錄'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insert_chart),
                selectedIcon: Icon(Icons.insert_chart),
                label: Text('報表'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('設定'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1), // NavigationRail 和內容區域之間的分隔線
          Expanded(
            child: _buildPageContent(_selectedIndex), // 根據選中索引建立不同的頁面內容
          ),
        ],
      ),
    );
  }

  // 根據選中索引建立不同的頁面內容
  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return CashierScreen(); // 收銀機頁面
      case 1:
        return OrderHistoryScreen(); // 訂單歷史紀錄頁面
      case 2:
        return ReportScreen(); // 資料統計報表頁面
      case 3:
        return SettingsScreen(); // 設定頁面
        break;
      default:
        return CashierScreen(); // 預設顯示收銀機頁面
    }
  }
}
