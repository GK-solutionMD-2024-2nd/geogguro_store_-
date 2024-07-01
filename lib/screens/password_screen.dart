import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'payment_screen.dart';

class PasswordPage extends StatefulWidget {
  static const String routeName = '/password';

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
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
          Navigator.pushReplacement(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 15),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 26,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, PaymentScreen.routeName);
                  },
                ),
                SizedBox(width: 20),
                Text(
                  '로그인 페이지',
                  style: TextStyle(fontSize: 24.0, color: Colors.white, fontFamily: "saum"),
                ),
              ],
            ),
            SizedBox(height: 60),
            Text(
              '비밀번호 입력: $_enteredPassword',
              style: TextStyle(fontSize: 24.0, color: Colors.white, fontFamily: "saum"),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontFamily: 'saum'),
              ),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButtonRow(["1", "2", "3"]),
                  SizedBox(height: 10), // 버튼 간 간격 추가
                  buildButtonRow(["4", "5", "6"]),
                  SizedBox(height: 10), // 버튼 간 간격 추가
                  buildButtonRow(["7", "8", "9"]),
                  SizedBox(height: 10), // 버튼 간 간격 추가
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
          padding: const EdgeInsets.all(15), // 여백 추가
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // 배경색 설정
              foregroundColor: Color(0xFF1B46B4), // 텍스트 색상 설정
              minimumSize: Size(80, 80), // 버튼 크기 설정
              shape: CircleBorder(), // 원형 버튼
            ),
            onPressed: () => _buttonPressed(value),
            child: Text(
              value,
              style: TextStyle(
                fontSize: value == "지우기" || value == "확인" ? 16 : 20,
                fontFamily: 'saum',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
