import 'package:flutter/material.dart';
import 'package:flutter_token_login/user/view/login_screen.dart';

void main() {
  runApp(
    ProviderScope(
      child: _App(),
    ),
  );
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }


}
