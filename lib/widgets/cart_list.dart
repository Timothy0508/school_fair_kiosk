import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartList extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemoveFromCart;

  CartList({required this.cartItems, required this.onRemoveFromCart});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return ListTile(
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
