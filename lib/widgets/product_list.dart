import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;
  final Function(Product) onEditProduct;
  final Function(Product) onDeleteProduct;

  const ProductList({super.key, 
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
          leading: Icon(product.category.icon), // 顯示分類 Icon
          title: Text(product.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}'),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  onEditProduct(product);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () {
                  onDeleteProduct(product);
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
