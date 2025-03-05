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
      'dateTime': dateTime.toIso8601String(), // 將 DateTime 轉換為 ISO 8601 字串
      'products': products
          .map((product) => product.toJson())
          .toList(), // 將商品列表轉換為 JSON 列表
      'totalPrice': totalPrice,
    };
  }

  // 從 JSON 格式的 Map 建立 Order 物件
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']), // 將 ISO 8601 字串轉換為 DateTime
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(), // 將 JSON 列表轉換為商品列表
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}
