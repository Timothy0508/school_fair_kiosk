import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/action_buttons.dart';
import '../widgets/cart_list.dart';
import '../widgets/customer_number_dialog.dart';
import '../widgets/notification_helper.dart';
import '../widgets/notification_type.dart';
import '../widgets/product_list.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  _CashierScreenState createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  List<Product> _products = [];
  final List<CartItem> _cartItems = [];

  double get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.product.price);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  //for debug
  _clearSharedPreferenced() async {
    final perfs = await SharedPreferences.getInstance();
    await perfs.clear();
  }

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

  void _clearCart({bool showNotification = true}) {
    setState(() {
      _cartItems.clear();
    });
    if (showNotification) {
      showPopupNotification(
        context,
        '購物車已清空',
        type: NotificationType.warning,
      );
    }
  }

  void _confirmOrder(int? customerNumber) async {
    if (_cartItems.isEmpty) {
      showPopupNotification(context, '購物車內沒有商品，無法確認訂單。',
          type: NotificationType.warning); // 使用 showPopupNotification 顯示提示訊息
      return;
    }

    // 建立合併品項後的商品列表
    List<Map<String, dynamic>> consolidatedProducts = [];
    Map<String, int> productCounts = {}; // 使用 Map 記錄品項 ID 和數量

    for (var cartItem in _cartItems) {
      final productId = cartItem.product.id;
      productCounts[productId] = (productCounts[productId] ?? 0) + 1; // 累加品項數量
    }

    productCounts.forEach((productId, quantity) {
      final product =
          _products.firstWhere((p) => p.id == productId); // 根據 ID 找到 Product 物件

      // *** 強制轉換 Product 物件為 JSON 格式 ***
      final productJson = product.toJson();

      consolidatedProducts.add({
        'product': productJson, // 儲存 Product 物件的 JSON 格式 (確認是 JSON!)
        'quantity': quantity, // 儲存品項數量
      });
    });

    // 建立訂單物件，使用合併後的商品列表 consolidatedProducts
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      products: consolidatedProducts, // 使用合併後的商品列表
      totalPrice: _totalPrice,
      customerNumber: customerNumber ?? 0,
    );

    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    List<dynamic> ordersData = [];
    if (ordersJson != null) {
      ordersData = jsonDecode(ordersJson);
    }
    ordersData.add(order.toJson());
    await prefs.setString('orders', jsonEncode(ordersData));

    print('已確認訂單，總金額：\$${_totalPrice.toStringAsFixed(2)}，訂單編號: ${order.id}');
    _clearCart(showNotification: false);
    showPopupNotification(context, '訂單已確認！',
        type: NotificationType.success); // 使用 showPopupNotification 顯示提示訊息
  }

  // 新增商品對話框
  _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    ProductCategory selectedCategory = ProductCategory.drink; // 預設選取飲品分類

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增商品'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '商品名稱'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: '商品價格'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                // 分類下拉選單
                value: selectedCategory,
                decoration: InputDecoration(labelText: '商品分類'),
                items: ProductCategory.values.map((ProductCategory category) {
                  return DropdownMenuItem<ProductCategory>(
                    value: category,
                    child: Text(category.label), // 顯示類別名稱
                  );
                }).toList(),
                onChanged: (ProductCategory? newValue) {
                  setState(() {
                    selectedCategory = newValue!; // 更新選取的分類
                  });
                },
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
                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0;
                if (name.isNotEmpty && price > 0) {
                  setState(() {
                    _products.add(Product(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        price: selectedCategory == ProductCategory.coupon
                            ? -price
                            : price,
                        category: selectedCategory // 傳遞選取的分類
                        ));
                    _saveProducts();
                  });
                  Navigator.of(context).pop();
                } else {
                  showPopupNotification(context, '商品名稱或價格無效，請重新輸入。',
                      type: NotificationType.warning);
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
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    ProductCategory selectedCategory = product.category; // 預設選取為商品目前的分類

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('編輯商品'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: '商品名稱'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: '商品價格'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                // 分類下拉選單
                value: selectedCategory,
                decoration: InputDecoration(labelText: '商品分類'),
                items: ProductCategory.values.map((ProductCategory category) {
                  return DropdownMenuItem<ProductCategory>(
                    value: category,
                    child: Text(category.label), // 顯示類別名稱
                  );
                }).toList(),
                onChanged: (ProductCategory? newValue) {
                  setState(() {
                    selectedCategory = newValue!; // 更新選取的分類
                  });
                },
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
                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0;
                if (name.isNotEmpty && price > 0) {
                  setState(() {
                    final index = _products.indexOf(product);
                    if (index != -1) {
                      _products[index] = Product(
                          id: product.id,
                          name: name,
                          price: price,
                          category: selectedCategory // 傳遞選取的分類
                          );
                      _saveProducts();
                    }
                  });
                  Navigator.of(context).pop();
                } else {
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

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('確認刪除商品？'),
          content: Text('您確定要刪除 ${product.name} 嗎？\n此操作無法復原。'),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('刪除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _products.remove(product);
                  _saveProducts();
                });
                Navigator.of(context).pop();
                showPopupNotification(
                  context,
                  '${product.name} 已刪除',
                  type: NotificationType.warning, // 設定為 warning 類型，使用橘色主題
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('收銀機')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      _products.isEmpty
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
                              products: _products,
                              onAddToCart: _addToCart,
                              onEditProduct: (product) =>
                                  _showEditProductDialog(context, product),
                              onDeleteProduct: _deleteProduct,
                            ),
                      Positioned(
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
            ),
            SizedBox(width: 8),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('已選商品',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
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
                        onConfirmOrder: () async {
                          int customerNumber =
                              await showCustomerNumberDialog(context);
                          debugPrint(customerNumber.toString());
                          _confirmOrder(customerNumber);
                        },
                        //TODO: Add dialog to add customer's number.
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
