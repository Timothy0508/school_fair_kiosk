import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Order> _orders = [];
  double _totalSales = 0; // 總銷售額

  @override
  void initState() {
    super.initState();
    _loadOrdersAndCalculateTotalSales(); // 載入訂單歷史紀錄並計算總銷售額
  }

  // 載入訂單歷史紀錄並計算總銷售額
  _loadOrdersAndCalculateTotalSales() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    if (ordersJson != null) {
      final List<dynamic> ordersData = jsonDecode(ordersJson);
      _orders = ordersData.map((item) => Order.fromJson(item)).toList();
      _calculateTotalSales(); // 計算總銷售額
    } else {
      _orders = []; // 如果沒有訂單紀錄，則清空訂單列表
      _totalSales = 0; // 總銷售額歸零
    }
    setState(() {}); // 更新畫面
  }

  // 計算總銷售額
  void _calculateTotalSales() {
    _totalSales = _orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('資料統計報表')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('總銷售額',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text('\$${_totalSales.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 36, color: Colors.green[700])),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 未來可以加入更多統計圖表或報表
            Text('** 其他統計報表功能 (未來擴充) **',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('- 熱銷商品排行榜',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text('- 每日/每周/每月銷售額統計',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            // ...
          ],
        ),
      ),
    );
  }
}
