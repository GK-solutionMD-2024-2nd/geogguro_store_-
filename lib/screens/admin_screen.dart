import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'password_screen.dart';
import 'payment_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

var userImage;

class _AdminScreenState extends State<AdminScreen> {
  TextEditingController _productTitleController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productQuantityController = TextEditingController();

  // 상품 추가 또는 수정 함수
  void _saveProduct(BuildContext context, String id) {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    String productTitle = _productTitleController.text;
    int productPrice = int.tryParse(_productPriceController.text) ?? 0;
    int productQuantity = int.tryParse(_productQuantityController.text) ?? 0;

    if (productTitle.isNotEmpty &&
        userImage != null &&
        productPrice > 0 &&
        productQuantity > 0) {
      Goods newGoods = Goods(
        id: id,
        title: productTitle,
        img: userImage,
        price: productPrice,
        quantity: productQuantity,
      );

      goodsProvider.addGoods(newGoods);
    }
  }

  // 상품 삭제 함수
  void _deleteProduct(BuildContext context, String productId) {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    goodsProvider.removeGoods(productId);
  }

  // 상품 수정 다이얼로그
  void _editProductDialog(BuildContext context, Goods goods) {
    _productTitleController.text = goods.title;
    _productPriceController.text = goods.price.toString();
    _productQuantityController.text = goods.quantity.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('상품 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productTitleController,
              decoration: InputDecoration(
                labelText: '상품 이름',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(
                labelText: '상품 가격',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productQuantityController,
              decoration: InputDecoration(
                labelText: '상품 수량',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    userImage = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'saum',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _saveProduct(context, goods.id);
              Navigator.of(context).pop();
            },
            child: Text(
              '저장',
              style: TextStyle(
                fontFamily: 'saum',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상품 추가 다이얼로그
  void _addProductDialog(BuildContext context) {
    _productTitleController.clear();
    _productPriceController.clear();
    _productQuantityController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '상품 추가',
          style: TextStyle(
            fontFamily: 'saum',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productTitleController,
              decoration: InputDecoration(
                labelText: '상품 이름',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(
                labelText: '상품 가격',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            TextField(
              controller: _productQuantityController,
              decoration: InputDecoration(
                labelText: '상품 수량',
                labelStyle: TextStyle(
                  fontFamily: 'saum',
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    userImage = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'saum',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String newId = DateTime.now().toString(); // 임시 ID
              _saveProduct(context, newId);
              Navigator.of(context).pop();
            },
            child: Text(
              '추가',
              style: TextStyle(
                fontFamily: 'saum',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상품 관리",
            style: TextStyle(
              fontFamily: "saum",
              color: Colors.white,
              fontSize: 35,
            )),
        leadingWidth: 165,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, PaymentScreen.routeName);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
            ),
            child: Text(
              '메인 페이지로',
              style: TextStyle(
                fontFamily: 'saum',
                fontSize: 18,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _addProductDialog(context),
              style: ElevatedButton.styleFrom(
                elevation: 0,
              ),
              child: Text(
                '상품 추가',
                style: TextStyle(
                  fontFamily: 'saum',
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Color.fromRGBO(27, 70, 180, 1.0),
      ),
      backgroundColor: Color.fromRGBO(27, 70, 180, 1.0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              '상품 리스트',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: "saum",
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, goodsProvider, _) => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: goodsProvider.goodsList.length,
                  itemBuilder: (context, index) {
                    final goods = goodsProvider.goodsList[index];
                    return GestureDetector(
                      onTap: () => _editProductDialog(context, goods),
                      child: Container(
                        height: 200,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Image.file(goods.img), // Corrected image display
                                ),
                                Positioned(
                                  top: -4,
                                  right: -2,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    iconSize: 20,
                                    onPressed: () => _deleteProduct(context, goods.id),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              goods.title,
                              style: TextStyle(
                                fontFamily: 'saum',
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${goods.price} 원',
                              style: TextStyle(
                                fontFamily: 'saum',
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '남은 수량 : ${goods.quantity} 개',
                              style: TextStyle(
                                fontFamily: 'saum',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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
