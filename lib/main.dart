import 'package:delivery_app/common/component/custom_text_form_field.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CustomTextFormField(
              hintText: '이메일을 입력하세요.',
              onChanged: (String value) {},
            ),
          ),
        ));
  }
}
