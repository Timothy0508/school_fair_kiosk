import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;
  final Function(Product) onEditProduct; // 編輯商品回呼
  final Function(Product) onDeleteProduct; // 刪除商品回呼

  ProductList({
    required this.products,
    required this.onAddToCart,
    required this.onEditProduct,
    required this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          title: Text(product.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}'),
              IconButton(
                icon: Icon(Icons.edit), // 編輯按鈕
                onPressed: () {
                  onEditProduct(product); // 呼叫編輯商品回呼
                },
              ),
              IconButton(
                icon:
                    Icon(Icons.delete_forever, color: Colors.redAccent), // 刪除按鈕
                onPressed: () {
                  onDeleteProduct(product); // 呼叫刪除商品回呼
                },
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: () {
                  onAddToCart(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
