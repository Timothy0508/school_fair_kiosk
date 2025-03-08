import 'product.dart';

class Order {
  final String id;
  final DateTime dateTime;
  final List<Product> products;
  final double totalPrice;

  Order({
    required this.id,
    required this.dateTime,
    required this.products,
    required this.totalPrice,
  });

  // 將 Order 物件轉換為 JSON 格式的 Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      // 將 products 的 JSON 轉換邏輯還原
      'products': products.map((product) => product.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }

  // 從 JSON 格式的 Map 建立 Order 物件
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      // 將 products 的 JSON 解析邏輯還原
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}
