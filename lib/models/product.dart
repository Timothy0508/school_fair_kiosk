import 'package:flutter/material.dart';

enum ProductCategory {
  drink, // 飲品
  food, // 熟食
  ice, // 冰品
}

extension ProductCategoryExtension on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.drink:
        return '飲品';
      case ProductCategory.food:
        return '熟食';
      case ProductCategory.ice:
        return '冰品';
      default:
        return '未分類';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.drink:
        return Icons.local_drink; // 飲品 Icon
      case ProductCategory.food:
        return Icons.fastfood; // 熟食 Icon
      case ProductCategory.ice:
        return Icons.icecream; // 冰品 Icon
      default:
        return Icons.category;
    }
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final ProductCategory category; // 新增商品分類屬性

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.category = ProductCategory.drink, // 預設分類為飲品
  });

  // 將 Product 物件轉換為 JSON 格式的 Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category.name, // 儲存分類名稱 (enum 的 name 屬性)
    };
  }

  // 從 JSON 格式的 Map 建立 Product 物件
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: ProductCategory.values
          .byName(json['category'] ?? 'drink'), // 載入分類，預設為飲品
    );
  }
}
