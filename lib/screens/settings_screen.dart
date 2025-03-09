import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_manager.dart';
import '../widgets/notification_helper.dart';
import '../widgets/notification_type.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showClearDataConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('確認清除資料？'),
          content: Text('您確定要清除所有應用程式資料嗎？此操作不可逆！'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 關閉對話框
              },
            ),
            ElevatedButton(
              child: Text('確認清除'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // 先關閉對話框
                await _clearSharedPreferencesData(); // 再清除資料
                showPopupNotification(context, 'Shared Preferences 資料已清除',
                    type: NotificationType.success); // 顯示成功提示
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有 Shared Preferences 資料
    // 清除資料後，可以考慮重新載入商品資料，或進行其他必要的重置操作
    // 例如：
    // widget.on продуктыChanged([]); // 如果 MainScreen 有提供更新商品列表的回調函數
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('應用程式主題設定',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            //  Segmented Button 將在此處加入
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeManager().themeModeNotifier,
              builder: (context, currentMode, _) {
                return SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('亮色'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('隨系統'),
                      icon: Icon(Icons.computer),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('暗色'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {currentMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ThemeManager().setThemeMode(newSelection.first);
                  },
                );
              },
            ),

            SizedBox(height: 32),
            Text('開發者區域',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            //  清除 Shared Preferences 按鈕將在此處加入
            Text(
              '**警告：** 此操作將會清除所有應用程式資料，包含商品、訂單歷史紀錄、報表資料等，此操作不可逆，請謹慎使用。',
              style: TextStyle(
                  color: Colors.orange[700], fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showClearDataConfirmationDialog(context);
              },
              child: Text('清除 Shared Preferences 資料'),
            ),
          ],
        ),
      ),
    );
  }
}
