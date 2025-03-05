import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onClearCart;
  final VoidCallback onConfirmOrder;

  ActionButtons({required this.onClearCart, required this.onConfirmOrder});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
          onPressed: onClearCart,
          icon: Icon(Icons.delete),
          label: Text('清空'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        ElevatedButton.icon(
          onPressed: onConfirmOrder,
          icon: Icon(Icons.check),
          label: Text('確認'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
