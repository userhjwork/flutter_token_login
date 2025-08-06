// import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_token_login/common/component/custom_text_form_field.dart';
import 'package:flutter_token_login/common/const/color.dart';
import 'package:flutter_token_login/common/const/data.dart';
import 'package:flutter_token_login/common/layout/default_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter_token_login/common/secure_storage/secure_storage.dart';
import 'package:flutter_token_login/common/view/root_tab.dart';



class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {

    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(height: 16.0,),
                _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',

                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hintText: '이메일을 입력하세요',
                  // errorText: '올바른 이메일주소를 입력해주세요',
                  onChanged: (String value) {
                    username = value;
                  },
                ),
                const SizedBox(height: 16.0,),
                CustomTextFormField(
                  hintText: '비밀번호를 입력하세요',
                  obscureText: true,
                  autofocus: true,
                  onChanged: (String value) {
                    password = value;
                  },
                  // errorText: '올바른 이메일주소를 입력해주세요',
                ),
                const SizedBox(height: 16.0,),
                ElevatedButton(
                  onPressed: () async {
                    // id:pw
                    final rawString = '$username:$password';

                    Codec<String, String> stringToBase64 = utf8.fuse(base64);

                    String token = stringToBase64.encode(rawString);


                    final resp = await dio.post(
                      'http://$ip/auth/login',
                      options: Options(
                          headers: {
                            'authorization': 'Basic $token',
                          }
                      ),
                    );

                    final refreshToken = resp.data['refreshToken'];
                    final accessToken = resp.data['accessToken'];

                    final storage = ref.read(secureStorageProvider);

                    await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);


                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RootTab(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: PRIMARY_COLOR,
                  ),
                  child: Text(
                    '로그인',
                  ),
                ),
                TextButton(
                  onPressed: () async {

                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: Text(
                    '회원가입',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인해주세요!\N오늘도 성공적인 주문이 되길 :>',
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
