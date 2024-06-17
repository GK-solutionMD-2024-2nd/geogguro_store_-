import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    return _items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(String id, String title, double price) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: id,
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';

  void myDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalAmount.toStringAsFixed(2);
    final totalQuantity = cart.totalQuantity;
    int remainingTime = 60;
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
              timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

            void onQRViewCreated(QRViewController controller) {
              controller.scannedDataStream.listen((scanData) {
                timer?.cancel();
                Navigator.of(context).pop();
              });
            }

            if (remainingTime == 60) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAmount = cart.totalAmount.toStringAsFixed(2);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              '총 금액: \$${totalAmount}',
              style: const TextStyle(fontSize: 20, fontFamily: 'saum'),
            ),
            const SizedBox(height: 20),
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
              child: const Text(
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
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color.fromRGBO(27, 70, 180, 1.0),
        ),
        home: PaymentScreen(),
        routes: {
          PaymentScreen.routeName: (context) => PaymentScreen(),
        },
      ),
    ),
  );
}
