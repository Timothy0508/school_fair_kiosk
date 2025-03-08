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
    print('Order.fromJson: JSON 資料為 null!'); // 除錯訊息：JSON 資料為 null
    if (json == null) {
      throw ArgumentError.notNull('json, Order.fromJson 接收的 JSON 資料不能為 null');
    }

    List<Map<String, dynamic>> parsedProducts = [];
    if (json['products'] is List) {
      // 僅檢查 json['products'] 是否為 List
      try {
        print('Order.fromJson: 開始解析 products 列表...'); // 除錯訊息：開始解析 products 列表
        parsedProducts = (json['products'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((item) {
              if (item['product'] is Map<String, dynamic>) {
                // 僅檢查 item['product'] 是否為 Map
                print(
                    'Order.fromJson: 解析 item[\'product\']...'); // 除錯訊息：解析 item['product']
                final product =
                    Product.fromJson(item['product'] as Map<String, dynamic>);
                print(
                    'Order.fromJson: 成功解析 Product 物件: ${product.name}'); // 除錯訊息：成功解析 Product 物件
                return {
                  'product': product,
                  'quantity': item['quantity'] as int? ?? 1,
                };
              } else {
                print(
                    'Order.fromJson: item[\'product\'] 無效，返回 null'); // 除錯訊息：item['product'] 無效
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
    final order = Order(
      id: json['id'] as String? ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      products: parsedProducts,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
    print(
        'Order.fromJson: 成功建立 Order 物件，訂單編號: ${order.id}'); // 除錯訊息：成功建立 Order 物件

    return order;
  }

  // 將 Order 物件轉換為 JSON 格式的 Map (toJson 方法保持不變)
  // 將 Order 物件轉換為 JSON 格式的 Map (修正 toJson 方法)
  Map<String, dynamic> toJson() {
    print('Order.toJson: 開始序列化 Order 物件，訂單編號: $id');
    print('Order.toJson: products 列表長度: ${products.length}');
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'products': products.map((item) {
        print('Order.toJson: 序列化 item[\'product\']...');
        print(
            'Order.toJson: item[\'product\'] 型別: ${item['product'].runtimeType}');
        // 移除 item['product'].toJson() 的呼叫，直接使用 item['product']
        final productJson =
            item['product']; // 直接使用 item['product']，不再呼叫 toJson()
        print(
            'Order.toJson: 成功序列化 item[\'product\'] (直接使用): ${productJson['name']}'); // 修改除錯訊息
        return {
          'product': productJson,
          'quantity': item['quantity'],
        };
      }).toList(),
      'totalPrice': totalPrice,
    };
  }
}
