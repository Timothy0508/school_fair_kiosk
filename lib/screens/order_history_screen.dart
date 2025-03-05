import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // 載入訂單歷史紀錄
  _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    if (ordersJson != null) {
      final List<dynamic> ordersData = jsonDecode(ordersJson);
      setState(() {
        _orders = ordersData.map((item) => Order.fromJson(item)).toList();
      });
    }
  }

  // 儲存訂單歷史紀錄
  _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson =
        jsonEncode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString('orders', ordersJson);
  }

  // 刪除訂單
  void _deleteOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('確認刪除訂單？'),
          content: Text('您確定要刪除訂單編號 ${order.id} 的歷史紀錄嗎？\n此操作無法復原。'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('刪除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _orders.remove(order);
                  _saveOrders();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('訂單編號 ${order.id} 歷史紀錄已刪除')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('訂單歷史紀錄')),
      body: _orders.isEmpty
          ? Center(
              child: Text('尚無訂單紀錄',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  // 直接返回 Card，移除 Dismissible
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('訂單編號: ${order.id}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                                '時間: ${DateFormat('yyyy-MM-dd HH:mm').format(order.dateTime)}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            Align(
                              // 加入 Align 组件，將刪除按鈕靠右對齊
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                // 加入刪除按鈕
                                icon: Icon(Icons.delete_forever,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  _deleteOrder(order); // 呼叫刪除訂單函數
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('商品:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.products
                              .map((product) => Text('- ${product.name} x 1'))
                              .toList(),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                              '總金額: \$${order.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
