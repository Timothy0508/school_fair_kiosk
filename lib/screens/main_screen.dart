import 'package:flutter/material.dart';

import 'cashier_screen.dart';
import 'order_history_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

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
