import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/payment_screen.dart';
import 'providers/cart_provider.dart';
import 'screens/admin_screen.dart';
import 'screens/password_screen.dart';

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
        initialRoute: '/', // 초기 라우트 설정
        routes: {
          '/': (ctx) => PaymentScreen(), // '/' 라우트 설정 (예시로 PaymentScreen을 초기 화면으로 설정)
          '/admin': (ctx) => AdminScreen(), 
          '/password': (ctx) => PasswordPage(),// '/admin' 라우트 설정
          '/payment' : (ctx) => PaymentScreen(),
        },
      ),
    );
  }
}
