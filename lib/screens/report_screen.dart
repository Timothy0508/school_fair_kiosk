import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../widgets/report_charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Order> _orders = [];
  double _totalSales = 0; // 總銷售額
  Map<ProductCategory, int> _categorySalesCounts = {};

  // 修改品項銷售統計 Map 的 Key 為 String (商品 ID)
  Map<ProductCategory, Map<String, int>> _productSalesCountsByCategory = {};
  List<Product> _products = []; // 新增商品列表

  @override
  void initState() {
    super.initState();
    _loadDataForReports(); // 修改載入資料函數名稱
  }

  // 載入訂單歷史紀錄並計算總銷售額
  // 修改載入資料函數，同時載入訂單和商品列表
  _loadDataForReports() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    final productsJson = prefs.getString('products'); // 載入商品列表

    if (ordersJson != null) {
      final List<dynamic> ordersData = jsonDecode(ordersJson);
      _orders = ordersData.map((item) => Order.fromJson(item)).toList();
      _calculateTotalSales();
      _calculateCategorySalesCounts();
      _calculateProductSalesCountsByCategory();
    } else {
      _orders = [];
      _totalSales = 0;
      _categorySalesCounts = {};
      _productSalesCountsByCategory = {};
    }

    if (productsJson != null) {
      // 載入商品列表
      final List<dynamic> productsData = jsonDecode(productsJson);
      _products = productsData.map((item) => Product.fromJson(item)).toList();
    } else {
      _products = [];
    }
    setState(() {});
  }

  // 計算總銷售額
  void _calculateTotalSales() {
    _totalSales = _orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  // 計算類別銷售數量 (修改商品物件取得方式)
  void _calculateCategorySalesCounts() {
    Map<ProductCategory, int> categoryCounts = {};
    for (var order in _orders) {
      for (var item in order.products) {
        // 迭代 Map 列表
        final product = item['product'] as Product; // 從 Map 中取出 Product 物件
        categoryCounts[product.category] =
            (categoryCounts[product.category] ?? 0) + 1;
      }
    }
    _categorySalesCounts = categoryCounts;
  }

  // 計算分類別品項銷售數量 (修改商品物件取得方式)
  void _calculateProductSalesCountsByCategory() {
    Map<ProductCategory, Map<String, int>> productCountsByCategory = {};
    for (var order in _orders) {
      for (var item in order.products) {
        // 迭代 Map 列表
        final product = item['product'] as Product; // 從 Map 中取出 Product 物件
        final category = product.category;
        final productId = product.id;
        if (!productCountsByCategory.containsKey(category)) {
          productCountsByCategory[category] = {};
        }
        productCountsByCategory[category]![productId] =
            (productCountsByCategory[category]![productId] ?? 0) + 1;
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
                  // 使用 ConstrainedBox 包裹 CategorySalesBarChart，限制最大高度
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxHeight: 200), // 設定最大高度為 200 (可依需求調整)
                    child: CategorySalesBarChart(
                        categorySalesData: _categorySalesCounts),
                  ),
                ),
              ),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
