import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class CategorySalesBarChart extends StatelessWidget {
  final Map<ProductCategory, int> categorySalesData; // 類別銷售數據

  const CategorySalesBarChart({super.key, required this.categorySalesData});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // 使用 AspectRatio 控制圖表比例
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxSales() + 2, // 設定 Y 軸最大值，略高於最高銷售量
          barTouchData: BarTouchData(
            enabled: false, // 禁用互動效果
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  // 底部 X 軸標籤
                  final category = ProductCategory.values[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(category.label,
                        style: TextStyle(fontSize: 12)), // 顯示類別名稱
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2, // Y 軸間隔
              ),
            ),
            topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)), // 隱藏頂部 X 軸標籤
            rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false)), // 隱藏右側 Y 軸標籤
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2, // 水平網格線間隔
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!, // 網格線顏色
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false), // 隱藏邊框
          barGroups: _generateBarGroups(), // 產生 BarChartGroupData 列表
        ),
      ),
    );
  }

  // 取得最大銷售量，用於設定 Y 軸最大值
  double _getMaxSales() {
    double maxSales = 0;
    for (var sales in categorySalesData.values) {
      if (sales > maxSales) {
        maxSales = sales.toDouble();
      }
    }
    return maxSales;
  }

  // 產生 BarChartGroupData 列表
  List<BarChartGroupData> _generateBarGroups() {
    List<BarChartGroupData> barGroups = [];
    categorySalesData.entries
        .toList()
        .sort((a, b) => a.key.index.compareTo(b.key.index)); // 依類別順序排序

    categorySalesData.forEach((category, sales) {
      barGroups.add(
        BarChartGroupData(
          x: category.index, // X 軸座標為類別的 index
          barRods: [
            BarChartRodData(
              toY: sales.toDouble(), // Y 軸高度為銷售量
              width: 22, // 長條寬度
            ),
          ],
        ),
      );
    });
    return barGroups;
  }
}

class ProductSalesBarChart extends StatelessWidget {
  final ProductCategory category;
  // 修改 productSalesData 的 Key 型別為 String (商品 ID)
  final Map<String, int> productSalesData;
  final List<Product> products; // 接收商品列表

  const ProductSalesBarChart(
      {super.key,
      required this.category,
      required this.productSalesData,
      required this.products}); // 修改建構子參數

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text('${category.label} - 品項銷售統計',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300),
          child: AspectRatio(
            aspectRatio: 2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxSales() + 2,
                barTouchData: BarTouchData(
                  enabled: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final style = TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        Widget textWidget;
                        // 檢查 _products 列表是否為空，避免空列表時 firstWhere 錯誤
                        if (products.isEmpty) {
                          textWidget = const Text('N/A'); // 空列表時顯示 "N/A"
                        } else {
                          switch (value.toInt()) {
                            case 0:
                              textWidget = Text(
                                products
                                    .firstWhere(
                                        (product) =>
                                            product.category ==
                                            ProductCategory.drink,
                                        orElse: () => Product(
                                            // 使用 orElse 提供預設 Product
                                            id: 'default_drink',
                                            name: 'N/A', // 找不到時顯示 "N/A"
                                            price: 0,
                                            category: ProductCategory.drink))
                                    .name,
                                style: style,
                              );
                              break;
                            case 1:
                              textWidget = Text(
                                products
                                    .firstWhere(
                                        (product) =>
                                            product.category ==
                                            ProductCategory.food,
                                        orElse: () => Product(
                                            // 使用 orElse 提供預設 Product
                                            id: 'default_food',
                                            name: 'N/A', // 找不到時顯示 "N/A"
                                            price: 0,
                                            category: ProductCategory.food))
                                    .name,
                                style: style,
                              );
                              break;
                            case 2:
                              textWidget = Text(
                                products
                                    .firstWhere(
                                        (product) =>
                                            product.category ==
                                            ProductCategory.ice,
                                        orElse: () => Product(
                                            // 使用 orElse 提供預設 Product
                                            id: 'default_ice',
                                            name: 'N/A', // 找不到時顯示 "N/A"
                                            price: 0,
                                            category: ProductCategory.ice))
                                    .name,
                                style: style,
                              );
                              break;
                            default:
                              textWidget = const Text('');
                              break;
                          }
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 10,
                          child: textWidget,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),
        )
      ],
    );
  }

  double _getMaxSales() {
    double maxSales = 0;
    for (var sales in productSalesData.values) {
      if (sales > maxSales) {
        maxSales = sales.toDouble();
      }
    }
    return maxSales;
  }

  // 產生 BarChartGroupData 列表 (修改 Key 的型別為 String)
  List<BarChartGroupData> _generateBarGroups() {
    List<BarChartGroupData> barGroups = [];
    productSalesData.entries.toList().sort((a, b) {
      // 根據商品名稱排序 (需要從 products 列表中找到 Product 物件)
      final productA = products.firstWhere((p) => p.id == a.key);
      final productB = products.firstWhere((p) => p.id == b.key);
      return productA.name.compareTo(productB.name);
    });

    productSalesData.forEach((productId, sales) {
      // 修改迴圈變數名稱為 productId
      // 取得品項在 products 列表中的索引 (不再使用索引作為 X 軸座標)
      // final productIndex = productSalesData.keys.toList().indexOf(productId);
      //  X 軸座標改用 index，確保類別內的品項順序一致
      final productIndex = barGroups.length; // 使用 barGroups 的長度作為 index，依序遞增
      barGroups.add(
        BarChartGroupData(
          x: productIndex, // X 軸座標為當前長條的 index (從 0 開始)
          barRods: [
            BarChartRodData(
              toY: sales.toDouble(),
              width: 16,
            ),
          ],
        ),
      );
    });
    return barGroups;
  }
}
