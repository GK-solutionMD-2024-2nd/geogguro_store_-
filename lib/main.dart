import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/payment_screen.dart';
import 'providers/cart_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: '거꾸로 매점',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PaymentScreen(),
      ),
    );
  }
}
