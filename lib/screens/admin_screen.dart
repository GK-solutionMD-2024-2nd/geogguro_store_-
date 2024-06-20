import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart'

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  TextEditingController _productTitleController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  
List<Goods> goodsList = [];


  // 상품 추가 또는 수정 함수
  void _saveProduct(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    String productTitle = _productTitleController.text;
    double productPrice = double.tryParse(_productPriceController.text) ?? 0.0;

    // Product 객체 생성 또는 업데이트 예시
    if (productId.isNotEmpty && productTitle.isNotEmpty && productPrice > 0) {
      cartProvider.addItem(productId, productTitle, productPrice.toInt());
      // 장바구니에 상품 추가 또는 업데이트
    }
  }

  // 상품 삭제 함수
  void _deleteProduct(BuildContext context, String productId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeItem(productId);
    // 장바구니에서 상품 삭제
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _productIdController,
              decoration: InputDecoration(labelText: '상품 ID'),
            ),
            TextField(
              controller: _productTitleController,
              decoration: InputDecoration(labelText: '상품 이름'),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: '상품 가격'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveProduct(context),
              child: Text('저장'),
            ),
            SizedBox(height: 20),
            Text(
              '상품 삭제',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // 상품 삭제 기능을 구현한 리스트뷰
            Consumer<CartProvider>(
              builder: (context, cartProvider, _) => ListView.builder(
                shrinkWrap: true,
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final productId = cartProvider.items.keys.toList()[index];
                  final product = cartProvider.items[productId]!;
                  return ListTile(
                    title: Text(product.title),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteProduct(context, productId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
