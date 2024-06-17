import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cart_provider.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = '/payment';

  void myDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                color: Colors.yellow,
                child: const Center(
                  child: Text(
                    "결제하기",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("팝업이다."),
              const SizedBox(height: 20),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAmount = cart.totalAmount.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: 'https://aq.gy/f/z3ut0/u/$totalAmount',
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 20),
            Text(
              '총 금액: \$${totalAmount}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: () {
                myDialog(context);
              },
              icon: const Icon(Icons.bubble_chart_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
