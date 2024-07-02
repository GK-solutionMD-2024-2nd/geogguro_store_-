import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../providers/cart_provider.dart';
import 'admin_screen.dart';
import 'password_screen.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

late AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();               

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';

void dbDialog(BuildContext context) {
  final cartProvid = Provider.of<CartProvider>(context, listen: false);
  var cartItemsList = cartProvid.items.values.toList();

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
                "결제를 하지 않고 '확인'버튼을 누를 시에는\n불이익이 발생할 수 있습니다.\n반드시 결제하시고 버튼을 눌러주세요.",
                style: TextStyle(
                  fontFamily: 'saum',
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              // Expanded(
              //   child: Column(
              //     MainAxisSize.max,
              //     mainAxisAlignment: MainAxisAlignment.center,
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
              //   ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _assetsAudioPlayer.open(
                        Audio("assets/audios/flutter.wav"),
                        loopMode: LoopMode.none, // 반복 없이 한 번만 재생
                        autoStart: true, // 자동 시작
                        showNotification: false, // 알림 표시 안 함
                      );
                      cartProvid.deductStockAfterPayment();
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
    final totalQuantity = cart.totalQuantity;
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
                                    '총 수량: $totalQuantity 개',
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
    ).then((_) {
      timer?.cancel();
    });
  }

  void _navigateToAdminScreen(BuildContext context) {
    Navigator.of(context).pushNamed(PasswordPage.routeName); // 관리자 페이지로 이동
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        "거꾸로 매점",
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'saum',
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _navigateToAdminScreen(context), // "거꾸로 매점" 클릭 시 관리자 페이지로 이동
                        child: Image.asset(
                          "assets/imgs/꾸로사진.png",
                          width: 100,
                          height: 60,
                        ),
                      ),
                    ],
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
                      crossAxisCount: 3, // 한 줄에 세 개의 항목
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: provider.goodsList.length,
                    itemBuilder: (ctx, index) {
                      var goodsList = provider.goodsList;
                      final product = {
                        'id': '${goodsList[index].id}',
                        'title': '${goodsList[index].title}',
                        'price': goodsList[index].price,
                        'quantity': goodsList[index].quantity,
                        'img': goodsList[index].img.path // 파일의 경로 문자열을 사용하도록 수정
                      };
                      return GridTile(
                        child: GestureDetector(
                          onTap: () {
                            var cartProvider = Provider.of<CartProvider>(context, listen: false);
                            var currentGoods = cartProvider.goodsList[index];
                            var currentCartQuantity = cartProvider.items[currentGoods.id]?.quantity ?? 0;

                            if (currentGoods.quantity > currentCartQuantity) {
                              cartProvider.addItem(
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
                                  child: Image.file(
                                    File(product['img']), // 파일 경로를 가진 img 필드를 직접 사용하도록 수정
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Flexible(
                                  child: Text(
                                    product['title'] as String,
                                    style: TextStyle(
                                      fontFamily: 'saum',
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${product['price']} 원',
                                  style: TextStyle(
                                    fontFamily: 'saum',
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '남은 수량 : ${product['quantity']} 개',
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
                                            image: FileImage(File(provider.goodsList[i].img.path)), // 파일 경로를 가진 img 필드를 직접 사용하도록 수정
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

