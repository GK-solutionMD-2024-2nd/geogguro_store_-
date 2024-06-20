import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../providers/cart_provider.dart';
import 'login_screen.dart'; // 필요하면 import 추가

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';

  Future<bool> checkPaymentStatus(String accountId, String amount) async {
    final url = Uri.parse('https://api.yourservice.com/check_payment');
    final response = await http.post(
      url,
      body: json.encode({
        'account_id': accountId,
        'amount': amount,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['payment_success'];
    } else {
      throw Exception('Failed to load payment status');
    }
  }

  void myDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount.toStringAsFixed(0);
    final totalQuantity = cart.totalQuantity;
    int remainingTime = 120;
    Timer? timer;
    QRViewController? qrController;
    bool paymentSuccess = false;

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

                // 주기적으로 결제 상태 확인
                if (remainingTime % 5 == 0) { // 5초마다 확인
                  bool status = await checkPaymentStatus('7777029976146', totalAmount);
                  setState(() {
                    paymentSuccess = status;
                  });
                  if (paymentSuccess) {
                    timer.cancel();
                    // 결제 성공 메시지 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("결제 성공"),
                        content: Text("결제가 성공적으로 완료되었습니다."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // 다이얼로그 닫기
                            },
                            child: Text("확인"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              });
            }

            void onQRViewCreated(QRViewController controller) {
              qrController = controller;
              controller.scannedDataStream.listen((scanData) {
                // QR 코드가 스캔되었음을 확인할 수 있는 부분
                print("QR 코드가 스캔되었습니다: ${scanData.code}");
                timer?.cancel();
                Navigator.of(context).pop();
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
      qrController?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAmount = cart.totalAmount.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Color.fromRGBO(27, 70, 180, 1.0),
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
                IconButton(
                  icon: Icon(Icons.login),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminLoginPage()),
                    );
                  },
                ),
                const Text(
                  "거꾸로 매점",
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'saum',
                    color: Colors.white,
                  ),
                ),
                Image.asset(
                  "assets/imgs/꾸로사진.png",
                  width: 100,
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 20,
            right: 20,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6, // 상품 수에 맞게 설정
                itemBuilder: (ctx, index) {
                  // 임시 상품 데이터를 사용
                  final product = {
                    'id': 'p$index',
                    'title': '상품 $index',
                    'price': 1000 + index * 100
                  };
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        // 상품을 장바구니에 추가
                        Provider.of<CartProvider>(context, listen: false).addItem(
                          product['id'] as String,
                          product['title'] as String,
                          product['price'] as int, // int 타입으로 변경
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 12),
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
                            Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: Text(
                                  '이미지',
                                  style: TextStyle(
                                    fontFamily: 'saum',
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              product['title'] as String,
                              style: TextStyle(
                                fontFamily: 'saum',
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${product['price']} 원',
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
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Text(
                                        '이미지',
                                        style: TextStyle(
                                          fontFamily: 'saum',
                                          fontSize: 18,
                                        ),
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
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "총액 : ${totalAmount}",
                          style: TextStyle(
                            fontFamily: 'saum',
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(width: 10),
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
      ),
    );
  }
}

