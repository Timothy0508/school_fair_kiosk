import 'product.dart';

class Order {
  final String id;
  final DateTime dateTime;
  final List<Map<String, dynamic>> products;
  final double totalPrice;
  final int customerNumber;

  Order({
    required this.id,
    required this.dateTime,
    required this.products,
    required this.totalPrice,
    this.customerNumber = 0,
  });

  // 從 JSON 格式的 Map 建立 Order 物件
  factory Order.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedProducts = [];
    if (json['products'] is List) {
      // 僅檢查 json['products'] 是否為 List
      try {
        parsedProducts = (json['products'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) {
              if (item['product'] is Map<String, dynamic>) {
                // 僅檢查 item['product'] 是否為 Map
                final product =
                    Product.fromJson(item['product'] as Map<String, dynamic>);
                return {
                  'product': product,
                  'quantity': item['quantity'] as int? ?? 1,
                };
              } else {
                return null; // 如果 item['product'] 無效，返回 null
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (e) {
        throw FormatException('Order.fromJson 解析 products 列表失敗',
            json['products']); // 拋出 FormatException
      }
    }

    if (parsedProducts.isEmpty) {}
    final order = Order(
      id: json['id'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      products: parsedProducts,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      customerNumber: json['customerNumber'] ?? 0,
    );

    return order;
  }

  // 將 Order 物件轉換為 JSON 格式的 Map (toJson 方法保持不變)
  // 將 Order 物件轉換為 JSON 格式的 Map (修正 toJson 方法)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'products': products.map((item) {
        // 移除 item['product'].toJson() 的呼叫，直接使用 item['product']
        final productJson =
            item['product']; // 直接使用 item['product']，不再呼叫 toJson()
        return {
          'product': productJson,
          'quantity': item['quantity'],
        };
      }).toList(),
      'totalPrice': totalPrice,
      'customerNumber': customerNumber,
    };
  }
}
