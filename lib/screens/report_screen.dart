import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../widgets/report_charts.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Order> _orders = [];
  double _totalSales = 0; // 總銷售額
  Map<ProductCategory, int> _categorySalesCounts = {}; // 類別銷售數量統計
  Map<ProductCategory, Map<Product, int>> _productSalesCountsByCategory =
      {}; // 分類別品項銷售數量統計

  @override
  void initState() {
    super.initState();
    _loadOrdersAndCalculateReports(); // 載入訂單並計算報表資料
  }

  // 載入訂單歷史紀錄並計算總銷售額
  _loadOrdersAndCalculateReports() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    if (ordersJson != null) {
      final List<dynamic> ordersData = jsonDecode(ordersJson);
      _orders = ordersData.map((item) => Order.fromJson(item)).toList();
      _calculateTotalSales(); // 計算總銷售額
      _calculateCategorySalesCounts(); // 計算類別銷售數量
      _calculateProductSalesCountsByCategory(); // 計算分類別品項銷售數量
    } else {
      _orders = [];
      _totalSales = 0;
      _categorySalesCounts = {};
      _productSalesCountsByCategory = {};
    }
    setState(() {});
  }

  // 計算總銷售額
  void _calculateTotalSales() {
    _totalSales = _orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  // 計算類別銷售數量
  void _calculateCategorySalesCounts() {
    Map<ProductCategory, int> categoryCounts = {};
    for (var order in _orders) {
      for (var product in order.products) {
        categoryCounts[product.category] =
            (categoryCounts[product.category] ?? 0) + 1; // 累加類別銷售數量
      }
    }
    _categorySalesCounts = categoryCounts;
  }

  // 計算分類別品項銷售數量
  void _calculateProductSalesCountsByCategory() {
    Map<ProductCategory, Map<Product, int>> productCountsByCategory = {};
    for (var order in _orders) {
      for (var product in order.products) {
        final category = product.category;
        if (!productCountsByCategory.containsKey(category)) {
          productCountsByCategory[category] = {}; // 初始化類別的品項銷售 Map
        }
        productCountsByCategory[category]![product] =
            (productCountsByCategory[category]![product] ?? 0) + 1; // 累加品項銷售數量
      }
    }
    _productSalesCountsByCategory = productCountsByCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('資料統計報表')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // 使用 SingleChildScrollView 讓報表內容可滾動
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
                        style:
                            TextStyle(fontSize: 36, color: Colors.green[700])),
                  ),
                ),
              ),
              SizedBox(height: 30),

              Text('各類別銷售統計',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)), // 類別銷售統計標題
              SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CategorySalesBarChart(
                      categorySalesData: _categorySalesCounts), // 顯示類別銷售長條圖
                ),
              ),
              SizedBox(height: 30),

              Text('各品項銷售統計 (分類別)',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)), // 品項銷售統計標題
              SizedBox(height: 10),
              ..._buildProductSalesCharts(), // 顯示分類別品項銷售長條圖
              SizedBox(height: 30),

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
      ),
    );
  }

  List<Widget> _buildProductSalesCharts() {
    List<Widget> charts = [];
    ProductCategory.values.forEach((category) {
      // 依序建立每個類別的品項銷售圖表
      if (_productSalesCountsByCategory.containsKey(category)) {
        // 檢查是否有該類別的銷售數據
        charts.add(
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProductSalesBarChart(
                  category: category,
                  productSalesData:
                      _productSalesCountsByCategory[category]!), // 顯示品項銷售長條圖
            ),
          ),
        );
      }
    });
    return charts;
  }
}
