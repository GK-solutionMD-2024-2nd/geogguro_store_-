import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 임포트

import '../providers/cart_provider.dart';
import 'payment_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

FirebaseFirestore _firestore = FirebaseFirestore.instance;
firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        home: AdminScreen(),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';

  @override
  AdminScreenState createState() => AdminScreenState();
}

// Suggests 클래스 최상위 수준에 정의
class Suggests {
  String suggest;
  String timestamp;

  Suggests({
    required this.suggest,
    required this.timestamp,
  });
}

class AdminScreenState extends State<AdminScreen> {
  TextEditingController _productTitleController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productQuantityController = TextEditingController();
  File? _userImage;

  @override
  void initState() {
    super.initState();
    loadProductsFromFirestore();
  }

  void loadProductsFromFirestore() async {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    final snapshot = await _firestore.collection('Goods').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      Goods goods = Goods(
        id: doc.id,
        title: data['title'],
        img: data['img'],
        price: data['price'],
        quantity: data['quantity'],
      );
      goodsProvider.addGoods(goods);
    }
  }

  Future<String> uploadImage(File imageFile) async {
    final now = DateTime.now();
    var ref = _storage.ref().child('Images/$now.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  void _suggestedDialog(BuildContext context) async {
    final snapshot = await _firestore.collection('suggest').get();

    List<Suggests> suggestsList = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp timestamp = data['timestamp'];
      return Suggests(
        suggest: data['suggest'],
        timestamp: formatTimestampToDateString(timestamp),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '제안된 상품 리스트',
          style: TextStyle(
            fontFamily: 'saum',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: suggestsList.map((suggest) {
              return ListTile(
                title: Text(suggest.timestamp),
                subtitle: Text(suggest.suggest),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontFamily: 'saum',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct(BuildContext context, String id) async {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    String productTitle = _productTitleController.text;
    int productPrice = int.tryParse(_productPriceController.text) ?? 0;
    int productQuantity = int.tryParse(_productQuantityController.text) ?? 0;

    if (productTitle.isNotEmpty &&
        _userImage != null &&
        productPrice > 0 &&
        productQuantity > 0) {
      String imageUrl = await uploadImage(_userImage!);

      Goods newGoods = Goods(
        id: id,
        title: productTitle,
        img: imageUrl,
        price: productPrice,
        quantity: productQuantity,
      );

      await _firestore.collection('Goods').doc(id).set({
        'id': id,
        'title': newGoods.title,
        'img': newGoods.img,
        'price': newGoods.price,
        'quantity': newGoods.quantity,
      });

      goodsProvider.addGoods(newGoods);
    }
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    goodsProvider.removeGoods(productId);
    await _firestore.collection('Goods').doc(productId).delete();
  }

  Future<void> _editProduct(BuildContext context, Goods goods) async {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    String productTitle = _productTitleController.text;
    int productPrice = int.tryParse(_productPriceController.text) ?? 0;
    int productQuantity = int.tryParse(_productQuantityController.text) ?? 0;

    if (productTitle.isNotEmpty && productPrice > 0 && productQuantity > 0) {
      String imageUrl = goods.img;
      if (_userImage != null) {
        imageUrl = await uploadImage(_userImage!);
      }

      Goods newGoods = Goods(
        id: goods.id,
        title: productTitle,
        img: imageUrl,
        price: productPrice,
        quantity: productQuantity,
      );

      DocumentReference docRef = _firestore.collection('Goods').doc(goods.id);
      await docRef.update({
        'id': newGoods.id,
        'title': newGoods.title,
        'img': newGoods.img,
        'price': newGoods.price,
        'quantity': newGoods.quantity,
      });

      goodsProvider.addGoods(newGoods);
    }
  }

  void _editProductDialog(BuildContext context, Goods goods) {
    _productTitleController.text = goods.title;
    _productPriceController.text = goods.price.toString();
    _productQuantityController.text = goods.quantity.toString();
    _userImage = null;

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
                    _userImage = File(image.path);
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
              _editProduct(context, goods);
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

  void _addProductDialog(BuildContext context) {
    _productTitleController.clear();
    _productPriceController.clear();
    _productQuantityController.clear();
    _userImage = null;

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
                    _userImage = File(image.path);
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
              _saveProduct(context, DateTime.now().toString());
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

  @override
  Widget build(BuildContext context) {
    final goodsProvider = Provider.of<CartProvider>(context);

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
            GestureDetector(
              onTap: () {
                _suggestedDialog(context);
              },
              child: const Text(
                '제안된 상품 리스트',
                style: TextStyle(
                  fontFamily: 'saum',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
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
                                  child: Image.network(goods.img),
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

String formatTimestampToDateString(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate(); // Timestamp를 DateTime으로 변환

  // 년도, 월, 일 추출
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;

  // 년도, 월, 일을 문자열로 변환하여 반환
  return '$year년 $month월 $day일';
}
