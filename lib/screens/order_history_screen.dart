import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入 intl 套件，用於日期格式化
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
    _loadOrders(); // 載入訂單歷史紀錄
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
