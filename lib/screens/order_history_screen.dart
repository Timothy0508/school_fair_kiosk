import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import '../models/product.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _loadProducts();
  }

  _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products');
    if (productsJson != null) {
      final List<dynamic> productsData = jsonDecode(productsJson);
      setState(() {
        _products = productsData.map((item) => Product.fromJson(item)).toList();
      });
    }
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
          content: Text('您確定要刪除訂單編號 ${order.id} 的歷史紀錄嗎？\n此操作無法復原。'), // 加入警告訊息
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
            ),
            TextButton(
              child: Text('刪除', style: TextStyle(color: Colors.red)),
              // 強調刪除按鈕
              onPressed: () {
                setState(() {
                  _orders.remove(order);
                  _saveOrders(); // 儲存訂單歷史紀錄
                });
                Navigator.of(context).pop(); // 關閉對話框
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('訂單編號 ${order.id} 歷史紀錄已刪除')), // 顯示刪除成功訊息
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 合併訂單中的同品項商品並計數
  List<Map<String, dynamic>> _consolidateOrderProducts(List<Product> products) {
    List<Map<String, dynamic>> consolidatedProducts = [];
    Map<String, int> productCounts = {};

    for (var product in products) {
      final productId = product.id;
      productCounts[productId] = (productCounts[productId] ?? 0) + 1;
    }

    productCounts.forEach((productId, quantity) {
      final product = _products
          .firstWhere((p) => p.id == productId); // 從 _products 列表中找到 Product 物件
      consolidatedProducts.add({
        'product': product,
        'quantity': quantity,
      });
    });
    return consolidatedProducts;
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
                return Dismissible(
                  // 使用 Dismissible 實現側滑刪除 (可選，如果不需要側滑刪除，可以移除 Dismissible)
                  key: UniqueKey(),
                  // 使用 UniqueKey 確保 Dismissible 的唯一性
                  direction: DismissDirection.endToStart,
                  // 設定側滑方向為從右到左
                  background: Container(
                    // 設定側滑時顯示的背景
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    // 設定側滑刪除的確認
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("確認刪除訂單？"),
                          content: const Text("您確定要刪除此筆訂單歷史紀錄嗎？\n此操作無法復原。"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(false), // 按取消返回 false
                              child: const Text("取消"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true), // 按確認返回 true
                              child: const Text("刪除",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    // 側滑刪除後的操作
                    _deleteOrder(order); // 呼叫刪除訂單函數
                  },
                  child: Card(
                    // 直接返回 Card，移除 Dismissible
                    elevation: 2,
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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
                            // 修改商品列表顯示邏輯，加入顯示時合併計數
                            children: _consolidateOrderProducts(order.products)
                                .map((item) {
                              final product =
                                  item['product'] as Product; // 取得 Product 物件
                              final quantity = item['quantity'] as int; // 取得數量
                              return Text(
                                  '- ${product.name} x $quantity'); // 顯示 品項名稱 x 數量
                            }).toList(),
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
                  ),
                );
              },
            ),
    );
  }
}
