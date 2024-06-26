import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'payment_screen.dart';


class AdminLoginPage extends StatefulWidget {
    static const String routeName = '/admin';
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final String _correctPassword = "0523";
  String _enteredPassword = "";
  String _errorMessage = "";

  void _buttonPressed(String value) {
    setState(() {
      if (value == "지우기") {
        if (_enteredPassword.isNotEmpty) {
          _enteredPassword = _enteredPassword.substring(0, _enteredPassword.length - 1);
        }
      } else if (value == "확인") {
        if (_enteredPassword == _correctPassword) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          _errorMessage = "비밀번호가 맞지 않습니다";
        }
      } else {
        if (_enteredPassword.length < 4) {
          _enteredPassword += value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B46B4),
      appBar: AppBar(
        title: Text('관리자 로그인'),
        backgroundColor: Color(0xFF1B46B4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '관리자로 로그인',
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              '비밀번호 입력: $_enteredPassword',
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButtonRow(["1", "2", "3"]),
                  buildButtonRow(["4", "5", "6"]),
                  buildButtonRow(["7", "8", "9"]),
                  buildButtonRow(["지우기", "0", "확인"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: values.map((value) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 배경색 설정
              foregroundColor: Color(0xFF1B46B4), // 텍스트 색상 설정
              minimumSize: Size(80, 80), // 버튼 크기 설정
            ),
            onPressed: () => _buttonPressed(value),
            child: Text(
              value,
              style: TextStyle(fontSize: 20),
            ),
          ),
        );
      }).toList(),
    );
  }
}