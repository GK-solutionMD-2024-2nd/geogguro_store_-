import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for TextInputFormatter
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart'; // CartProvider를 import합니다.
import 'password_screen.dart';
import 'payment_screen.dart';

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  TextEditingController _productTitleController = TextEditingController();
  TextEditingController _productImageUrlController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productQuantityController = TextEditingController();

  // 상품 추가 또는 수정 함수
  void _saveProduct(BuildContext context, String id) {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    String productTitle = _productTitleController.text;
    String productImageUrl = _productImageUrlController.text; // Get the image URL
    int productPrice = int.tryParse(_productPriceController.text) ?? 0;
    int productQuantity = int.tryParse(_productQuantityController.text) ?? 0;

    if (productTitle.isNotEmpty && productImageUrl.isNotEmpty && productPrice > 0 && productQuantity > 0) {
      Goods newGoods = Goods(
        id: id,
        title: productTitle,
        img: productImageUrl, // Use the image URL
        price: productPrice,
        quantity: productQuantity,
      );

      goodsProvider.addGoods(newGoods);
    }
  }

  // 상품 삭제 함수
  void _deleteProduct(BuildContext context, String productId) {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false); // CartProvider를 사용합니다.
    goodsProvider.removeGoods(productId);
  }

  // 상품 수정 다이얼로그
  void _editProductDialog(BuildContext context, Goods goods) {
    _productTitleController.text = goods.title;
    _productPriceController.text = goods.price.toString();
    _productQuantityController.text = goods.quantity.toString();
    _productImageUrlController.text = goods.img;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('상품 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productTitleController,
              decoration: InputDecoration(labelText: '상품 이름'),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: '상품 가격'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productQuantityController,
              decoration: InputDecoration(labelText: '상품 수량'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productImageUrlController,
              decoration: InputDecoration(labelText: '이미지 URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveProduct(context, goods.id);
              Navigator.of(context).pop();
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, PaymentScreen.routeName); // '/password'로 이동
            },
          ),            
          Text(
              '상품 추가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _productTitleController,
              decoration: InputDecoration(labelText: '상품 이름'),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: '상품 가격'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productQuantityController,
              decoration: InputDecoration(labelText: '상품 수량'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productImageUrlController,
              decoration: InputDecoration(labelText: '이미지 URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String newId = DateTime.now().toString(); // 임시 ID
                _saveProduct(context, newId);
                _productTitleController.clear();
                _productPriceController.clear();
                _productQuantityController.clear();
                _productImageUrlController.clear();
                
              },
              child: Text('추가'),
            ),
            SizedBox(height: 20),
            Text(
              '상품 리스트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, goodsProvider, _) => ListView.builder(
                  itemCount: goodsProvider.goodsList.length, // goodsProvider에서 goodsList를 사용합니다.
                  itemBuilder: (context, index) {
                    final goods = goodsProvider.goodsList[index];
                    return ListTile(
                      title: Text(goods.title),
                      subtitle: Text('${goods.price} 원 / ${goods.quantity} 개'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProduct(context, goods.id),
                      ),
                      onTap: () => _editProductDialog(context, goods),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
