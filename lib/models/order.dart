import 'product.dart';

class Order {
  final String id;
  final DateTime dateTime;
  final List<Map<String, dynamic>> products;
  final double totalPrice;

  Order({
    required this.id,
    required this.dateTime,
    required this.products,
    required this.totalPrice,
  });

  // 從 JSON 格式的 Map 建立 Order 物件
  factory Order.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw ArgumentError.notNull('json, Order.fromJson 接收的 JSON 資料不能為 null');
    }

    List<Map<String, dynamic>> parsedProducts = [];
    if (json['products'] is List) {
      // 僅檢查 json['products'] 是否為 List
      try {
        parsedProducts = (json['products'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) {
              if (item['product'] is Map<String, dynamic>) {
                // 僅檢查 item['product'] 是否為 Map
                return {
                  'product':
                      Product.fromJson(item['product'] as Map<String, dynamic>),
                  'quantity': item['quantity'] as int? ?? 1,
                };
              } else {
                return null; // 如果 item['product'] 無效，返回 null
              }
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (e) {
        print('Order.fromJson 解析 products 列表時發生錯誤: $e'); // 印出詳細錯誤訊息
        throw FormatException('Order.fromJson 解析 products 列表失敗',
            json['products']); // 拋出 FormatException
      }
    }

    if (parsedProducts.isEmpty) {
      print('Order.fromJson 解析商品列表後，商品列表為空，訂單資料可能無效'); // 印出警告訊息
      // 決定是否要拋出例外或建立部分有效的 Order 物件
      // 這裡選擇不拋出例外，建立部分有效的 Order 物件，products 為空列表
      // throw StateError('Order.fromJson 解析商品列表後，商品列表為空，訂單資料無效');
    }

    return Order(
      id: json['id'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      products: parsedProducts,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // 將 Order 物件轉換為 JSON 格式的 Map (toJson 方法保持不變)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'products': products
          .map((item) => {
                'product': item['product'].toJson(),
                'quantity': item['quantity'],
              })
          .toList(),
      'totalPrice': totalPrice,
    };
  }
}
