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
