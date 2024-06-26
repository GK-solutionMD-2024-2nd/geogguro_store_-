import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:assets_audio_player/assets_audio_player.dart'; // Import assets_audio_player
import '../providers/cart_provider.dart';
import 'admin_screen.dart';
import 'password_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

late AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

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
                  int parsedAmount = int.parse(totalAmount); // 또는 int.parse를 사용할 수도 있습니다.
                  bool status = await checkPaymentStatus('7777029976146', parsedAmount.toString());
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

            _assetsAudioPlayer.open(
              Audio("assets/audios/flutter.wav"),
              loopMode: LoopMode.none, // 반복 없이 한 번만 재생
              autoStart: true, // 자동 시작
              showNotification: false, // 알림 표시 안 함
            );

            void _navigateToAdminScreen(BuildContext context) {
              Navigator.of(context).pushNamed(AdminScreen.routeName); // 관리자 페이지로 이동
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

  void _navigateToAdminScreen(BuildContext context) {
    Navigator.of(context).pushNamed(AdminLoginPage.routeName); // 관리자 페이지로 이동
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
                      GestureDetector(
                        onTap: () => _navigateToAdminScreen(context), // "거꾸로 매점" 클릭 시 관리자 페이지로 이동
                        child: Text(
                          "거꾸로 매점",
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'saum',
                            color: Colors.white,
                          ),
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
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 20,
                right: 20,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 줄에 세 개의 항목
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: provider.goodsList.length,
                    itemBuilder: (ctx, index) {
                      var goodsList = provider.goodsList;
                      final product = {
                        'id': '${goodsList[index].id}',
                        'title': '${goodsList[index].title}',
                        'price': goodsList[index].price,
                        'quantity': goodsList[index].quantity,
                        'img': goodsList[index].img
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
                                  height: 165,
                                  width: double.infinity,
                                  // child: Image.network(
                                  //   product['img'] as String,
                                  //   fit: BoxFit.contain, // 이미지가 컨테이너 내에서 비율을 유지하며 맞춰짐
                                  //   loadingBuilder: (context, child, loadingProgress) {
                                  //     if (loadingProgress == null) {
                                  //       return child;
                                  //     }
                                  //     return Center(
                                  //       child: CircularProgressIndicator(
                                  //         value: loadingProgress.expectedTotalBytes != null
                                  //             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  //             : null,
                                  //       ),
                                  //     );
                                  //   },
                                  //   errorBuilder: (context, error, stackTrace) {
                                  //     return Center(
                                  //       child: Text(
                                  //         '이미지 로드 실패',
                                  //         style: TextStyle(color: Colors.red),
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                  child: CachedNetworkImage(
                                    imageUrl: product['img'] as String,
                                    fit: BoxFit.cover,
                                    width: 300,
                                    errorWidget: (context, url, error) => Text("error!")
                                    
                                  )
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
                                            image: NetworkImage(provider.goodsList[i].img),
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
                              onPressed: () async {
                                _assetsAudioPlayer.play(); //재생
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
