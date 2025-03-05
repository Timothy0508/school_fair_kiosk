import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_list.dart';
import '../widgets/cart_list.dart';
import '../widgets/action_buttons.dart';

class CashierScreen extends StatefulWidget {
  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  // 預設商品列表
  List<Product> _products = [
    Product(id: '1', name: '可口可樂', price: 20),
    Product(id: '2', name: '雪碧', price: 20),
    Product(id: '3', name: '礦泉水', price: 15),
    Product(id: '4', name: '蘋果汁', price: 25),
    Product(id: '5', name: '柳橙汁', price: 25),
    Product(id: '6', name: '熱狗', price: 35),
    Product(id: '7', name: '三明治', price: 40),
    Product(id: '8', name: '薯條', price: 30),
  ];

  List<CartItem> _cartItems = [];

  double get _totalPrice => _cartItems.fold(0, (sum, item) => sum + item.product.price);

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(CartItem(product: product));
    });
  }

  void _removeFromCart(CartItem cartItem) {
    setState(() {
      _cartItems.remove(cartItem);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  void _confirmOrder() {
    // 在這裡處理確認訂單的邏輯，例如儲存訂單資料
    // 這裡僅簡單示範印出訊息並清空購物車
    print('已確認訂單，總金額：\$${_totalPrice.toStringAsFixed(2)}');
    _clearCart();
    // 可以加入提示訊息告知使用者訂單已確認
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('訂單已確認！')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('收銀機')),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProductList(
                products: _products,
                onAddToCart: _addToCart,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已選商品', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: CartList(
                      cartItems: _cartItems,
                      onRemoveFromCart: _removeFromCart,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('總金額: \$${_totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ActionButtons(
                    onClearCart: _clearCart,
                    onConfirmOrder: _confirmOrder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
