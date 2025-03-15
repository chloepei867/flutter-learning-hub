import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants.dart';



class IconContent extends StatelessWidget {
  const IconContent({required this.icon, required this.iconText});
  final IconData icon;
  final String iconText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          color: Colors.white,
          size: 70.0,
        ),
        SizedBox(height: 15.0,),
        Text(iconText,
          style: kIconTextStyle),
      ],
    );
  }
}