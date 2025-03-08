import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartList extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemoveFromCart;

  const CartList({super.key, required this.cartItems, required this.onRemoveFromCart});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return ListTile(
          leading: Icon(cartItem.product.category.icon), // 加入分類 Icon
          title: Text(cartItem.product.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('\$${cartItem.product.price.toStringAsFixed(2)}'),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  onRemoveFromCart(cartItem);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
