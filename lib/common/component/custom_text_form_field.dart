import 'package:delivery_app/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool isObscure;
  final bool isAutofocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.errorText,
    this.isObscure = false,
    this.isAutofocus = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const baseBorder = OutlineInputBorder(
        borderSide: BorderSide(
      color: INPUT_BORDER_COLOR,
      width: 1.0,
    ));

    return TextFormField(
      cursorColor: PRIMARY_COLOR,
      onChanged: onChanged,
      obscureText: isObscure,
      //비밀번호 입력할때 사용
      autofocus: isAutofocus,
      //화면 나오면 바로 오토포커스를 줄것인지 여부
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        errorText: errorText,
        hintStyle: const TextStyle(
          color: BODY_TEXT_COLOR,
          fontSize: 14.0,
        ),
        fillColor: INPUT_BG_COLOR,
        filled: true,
        //배경색을 넣을것인지 여부
        //모든 Input 상태의 기본 스타일링값
        border: baseBorder,
        focusedBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
          color: PRIMARY_COLOR,
        )),
      ),
    );
  }
}
