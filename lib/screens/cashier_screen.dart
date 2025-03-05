import 'dart:convert'; // 引入 jsonEncode 和 jsonDecode

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../widgets/action_buttons.dart';
import '../widgets/cart_list.dart';
import '../widgets/product_list.dart';

class CashierScreen extends StatefulWidget {
  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Product> _products = []; // 商品列表，一開始為空
  List<CartItem> _cartItems = [];

  double get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.product.price);

  @override
  void initState() {
    super.initState();
    _loadProducts(); // 載入商品資料
  }

  // 載入商品資料
  _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products');
    if (productsJson != null) {
      final List<dynamic> productsData = jsonDecode(productsJson);
      setState(() {
        _products = productsData.map((item) => Product.fromJson(item)).toList();
      });
    }
  }

  // 儲存商品資料
  _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson =
        jsonEncode(_products.map((product) => product.toJson()).toList());
    await prefs.setString('products', productsJson);
  }

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
    print('已確認訂單，總金額：\$${_totalPrice.toStringAsFixed(2)}');
    _clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('訂單已確認！')),
    );
  }

  // 新增商品對話框
  _showAddProductDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增商品'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '商品名稱'),
              ),
              TextField(
                controller: _priceController,
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true), // 允許小數
                decoration: InputDecoration(labelText: '商品價格'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('確認'),
              onPressed: () {
                final name = _nameController.text;
                final price = double.tryParse(_priceController.text) ??
                    0; // 價格轉換，無效輸入則為 0
                if (name.isNotEmpty && price > 0) {
                  setState(() {
                    _products.add(Product(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        price: price)); // 使用時間戳記作為 ID
                    _saveProducts(); // 儲存商品列表
                  });
                  Navigator.of(context).pop();
                } else {
                  // 可以加入錯誤提示訊息，例如使用 SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('商品名稱或價格無效，請重新輸入。')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 編輯商品對話框
  _showEditProductDialog(BuildContext context, Product product) {
    final _nameController = TextEditingController(text: product.name);
    final _priceController =
        TextEditingController(text: product.price.toString());
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('編輯商品'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '商品名稱'),
              ),
              TextField(
                controller: _priceController,
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true), // 允許小數
                decoration: InputDecoration(labelText: '商品價格'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('確認'),
              onPressed: () {
                final name = _nameController.text;
                final price = double.tryParse(_priceController.text) ??
                    0; // 價格轉換，無效輸入則為 0
                if (name.isNotEmpty && price > 0) {
                  setState(() {
                    final index = _products.indexOf(product);
                    if (index != -1) {
                      _products[index] = Product(
                          id: product.id, name: name, price: price); // 更新商品資訊
                      _saveProducts(); // 儲存商品列表
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  // 可以加入錯誤提示訊息，例如使用 SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('商品名稱或價格無效，請重新輸入。')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 刪除商品
  void _deleteProduct(Product product) {
    setState(() {
      _products.remove(product);
      _saveProducts(); // 儲存商品列表
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} 已刪除')),
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
              child: Stack(
                // 使用 Stack 來疊加 FloatingActionButton
                children: [
                  _products.isEmpty // 判斷商品列表是否為空
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart,
                                  size: 100, color: Colors.grey),
                              Text('沒有品項',
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ProductList(
                          // 如果有商品，顯示商品列表
                          products: _products,
                          onAddToCart: _addToCart,
                          onEditProduct: (product) => _showEditProductDialog(
                              context, product), // 編輯商品回呼
                          onDeleteProduct: _deleteProduct, // 刪除商品回呼
                        ),
                  Positioned(
                    // 將 FloatingActionButton 定位在列表底部中央
                    bottom: 16.0,
                    left: 0.0,
                    right: 0.0,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _showAddProductDialog(context);
                        },
                        icon: Icon(Icons.add),
                        label: Text('新增商品'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已選商品',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: CartList(
                      cartItems: _cartItems,
                      onRemoveFromCart: _removeFromCart,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('總金額: \$${_totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18)),
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
