import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../providers/cart_provider.dart';
import 'admin_screen.dart';
import 'password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 임포트

FirebaseFirestore _firestore = FirebaseFirestore.instance;
firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;
late AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

AdminScreenState popo = new AdminScreenState();

double _position = 0;
double _velocity = 10; // 속도 조정
Timer? _timer;


class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  void dbDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    var cartItemsList = cartProvider.items.values.toList();

    showDialog(
      context: context,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isTablet = mediaQuery.size.width > 600;
        final dialogWidth = isTablet ? 600.0 : mediaQuery.size.width * 0.8;
        final dialogHeight = isTablet ? 400.0 : mediaQuery.size.height * 0.5;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "결제를 하지 않고 '확인' 버튼을 누를 시에는\n불이익이 발생할 수 있습니다.\n반드시 결제하시고 버튼을 눌러주세요.",
                  style: TextStyle(
                    fontFamily: 'saum',
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: cartItemsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var cartItem = cartItemsList[index];
                        return Text(
                          "${cartItem.title} : ${cartItem.quantity}개 : ${cartItem.price * cartItem.quantity}원",
                          style: TextStyle(
                            fontFamily: 'saum',
                            fontSize: 20,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [ㄹ
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _assetsAudioPlayer.open(
                          Audio("assets/audios/flutter.wav"),
                          loopMode: LoopMode.none,
                          autoStart: true,
                          showNotification: false,
                        );
                        cartProvider.deductStockAfterPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: 'saum',
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'saum',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void myDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount.toStringAsFixed(0);
    int remainingTime = 120;
    Timer? timer;

    showDialog(
      context: context,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isTablet = mediaQuery.size.width > 600;
        final dialogWidth = isTablet ? 600.0 : mediaQuery.size.width * 0.8;

        return StatefulBuilder(
          builder: (context, setState) {
            void startTimer() {
              timer = Timer.periodic(Duration(seconds: 1), (timer) async {
                setState(() {
                  if (remainingTime > 0) {
                    remainingTime--;
                  } else {
                    timer.cancel();
                    Navigator.of(context).pop();
                  }
                });
              });
            }

            if (remainingTime == 120) {
              startTimer();
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 217, 1, 1.0),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "결제하기",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'saum',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 150,
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "제한 시간: $remainingTime 초",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'saum',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '총 수량: ${cart.totalQuantity} 개',
                                    style: const TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '결제금액: $totalAmount 원',
                                    style: const TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              QrImageView(
                                data: 'https://aq.gy/f/z3ut0/u/$totalAmount',
                                version: QrVersions.auto,
                                size: 150,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '결제를 완료하면\n냉장고가 열립니다',
                                    style: TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '잠시만 기다려주세요!',
                                    style: TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  timer?.cancel();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'saum',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  timer?.cancel();
                                  Navigator.of(context).pop();
                                  dbDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '결제 확인',
                                  style: TextStyle(
                                    fontFamily: 'saum',
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

Future<void> _suggestProduct(BuildContext context) async {
  String productSuggest = _productSuggestController.text;
  String id = DateTime.now().millisecondsSinceEpoch.toString(); // 현재 시각을 이용한 ID 생성

  if (productSuggest.isNotEmpty) {
    await _firestore.collection('suggest').doc(id).set({
      'suggest': productSuggest,
      'timestamp': DateTime.now(), // 현재 시각 저장 (옵션)
    });
  }
}


TextEditingController _productSuggestController = TextEditingController();

void _suggestDialog(BuildContext context) {
  _productSuggestController.clear();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        '상품 제안',
        style: TextStyle(
          fontFamily: 'saum',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _productSuggestController,
            decoration: InputDecoration(
              labelText: '제안할 상품을 적어주세요!',
              labelStyle: TextStyle(
                fontFamily: 'saum',
              ),
            ),
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _suggestProduct(context); // _suggestProduct에 context 전달
          },
          child: Text(
            '제안하기',
            style: TextStyle(
              fontFamily: 'saum',
            ),
          ),
        ),
      ],
    ),
  );
}

  void _navigateToAdminScreen(BuildContext context) {
    Navigator.of(context).pushNamed(PasswordPage.routeName);
  }

  Future<void> loadProductsFromFirestore() async {
    final goodsProvider = Provider.of<CartProvider>(context, listen: false);
    final snapshot = await _firestore.collection('goods').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      Goods goods = Goods(
        id: doc.id,
        title: data['title'],
        price: data['price'],
        quantity: data['quantity'],
        img: data['img'], // assuming 'img' is the field for image path
      );
      goodsProvider.addGoods(goods);
    }
  }

  @override
  void initState() {
    loadProductsFromFirestore();
    super.initState();
    _startMoving();
  }
  

  void _startMoving() {
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      setState(() {
        _position += _velocity;
        double screenWidth = MediaQuery.of(context).size.width;
        double barWidth = screenWidth - 80;
        if (_position > barWidth - 50 || _position < 0) {
          _velocity = -_velocity;
        }
      });
    });
  }

  void _increaseSpeed() {
    setState(() {
      if (_velocity > 0 && _velocity < 50) {
        _velocity += 3;
      } else if (_velocity < 0 && _velocity > -50) {
        _velocity -= 3;
      }
    });
  }

  void _decreaseSpeed() {
    setState(() {
      if (_velocity > 5) {
        _velocity -= 3;
      } else if (_velocity < -5) {
        _velocity += 3;
      }
    });
  }

  double _calculateProgress() {
    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = screenWidth - 80;
    return (_position / (barWidth - 50)) * 100;
  }

  final String kakaoTalkBotUrl = 'https://open.kakao.com/o/gfVrazAg'; // 여기에 실제 카카오톡 봇 URL을 입력하세요

  // 카카오톡 봇 링크를 여는 함수
  void _launchKakaoTalkBot() async {
    if (await canLaunch(kakaoTalkBotUrl)) {
      await launch(kakaoTalkBotUrl);
    } else {
      throw 'Could not launch $kakaoTalkBotUrl';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();
    final cart = Provider.of<CartProvider>(context);
    final totalAmount = cart.totalAmount.toStringAsFixed(0);

    return Scaffold(
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Color.fromRGBO(27, 70, 180, 1.0),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 35),
                      GestureDetector(
                        onTap: () {
                          _launchKakaoTalkBot();
                        },
                        child: const Text(
                          '문의하기',
                          style: TextStyle(
                            fontFamily: 'saum',
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      const Text(
                        "거꾸로 매점",
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'saum',
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToAdminScreen(context),
                        child: Image.asset(
                          "assets/imgs/꾸로사진.png",
                          width: 100,
                          height: 60,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          _suggestDialog(context);
                        },
                        child: const Text(
                          '제안하기',
                          style: TextStyle(
                            fontFamily: 'saum',
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 150),
                  width: MediaQuery.of(context).size.width - 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: _position + 40,
                child: Image.asset(
                  'assets/imgs/꾸로사진.png',
                  width: 50,
                ),
              ),
              Positioned(
                bottom: 1125, // Adjusted to position the button just below the bar
                left: 40,  // Positioned at the start of the bar
                child: ElevatedButton(
                  onPressed: _decreaseSpeed,
                  child: Text('-'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 255, 255, 255)), // 버튼 배경색
                    foregroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 0, 0, 0)), // 버튼 텍스트 색
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 버튼 크기 조정
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                        fontSize: 20, // 버튼 텍스트 크기
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글기
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 1125, // Adjusted to position the button just below the bar
                right: 40, // Positioned at the end of the bar
                child: ElevatedButton(
                  onPressed: _increaseSpeed,
                  child: Text('+'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)), // 버튼 배경색
                    foregroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 0, 0, 0)), // 버튼 텍스트 색
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 버튼 크기 조정
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(
                        fontSize: 20, // 버튼 텍스트 크기
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글기
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 20,
                right: 20,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.goodsList.length,
                    itemBuilder: (ctx, index) {
                      var goodsList = provider.goodsList;
                      final product = goodsList[index];

                      return GridTile(
                        child: GestureDetector(
                          onTap: () {
                            var currentGoods = goodsList[index];
                            var currentCartQuantity = cart.items[currentGoods.id]?.quantity ?? 0;

                            if (currentGoods.quantity > currentCartQuantity) {
                              cart.addItem(
                                currentGoods.id,
                                currentGoods.title,
                                currentGoods.price,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('상품이 더 이상 선택할 수 없습니다.'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 12),
                            height: 200,
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
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Image.network(product.img), // Load image from network
                                ),
                                SizedBox(height: 8),
                                Flexible(
                                  child: Text(
                                    product.title,
                                    style: TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${product.price} 원',
                                  style: TextStyle(
                                    fontFamily: 'saum',
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '남은 수량 : ${product.quantity} 개',
                                  style: TextStyle(
                                    fontFamily: 'saum',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: -12,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '장바구니',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'saum',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cart.items.length,
                          itemBuilder: (ctx, i) {
                            final item = cart.items.values.toList()[i];
                            return Container(
                              width: 90,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(provider.goodsList[i].img), // Load image from network
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${item.title}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'saum',
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '${item.quantity} 개',
                                            style: TextStyle(
                                              fontFamily: 'saum',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: -7,
                                    right: 5,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      iconSize: 20,
                                      onPressed: () {
                                        Provider.of<CartProvider>(context, listen: false).removeItem(item.id);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '총액 : $totalAmount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'saum',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                myDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(255, 217, 1, 1.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: Size(150, 50),
                              ),
                              child: Text(
                                '결제하기',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'saum',
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
