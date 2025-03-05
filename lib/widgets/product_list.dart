import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  ProductList({required this.products, required this.onAddToCart});

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
