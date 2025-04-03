import 'package:flutter/material.dart';
import 'package:flash_card/constants.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({required this.bgColor, required this.onPressed, required this.text});
  final Color bgColor;
  final Function() onPressed;
  final String text;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        // color: Color(0xff64B5F6),
        color: bgColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,

          minWidth: 200.0,
          height: 42.0,
          child: Text(
            // 'Log In',
            text,
            style: kLoginSignupButtonTextStyle,
          ),
        ),
      ),
    );
  }
}