import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const kButtonTextStyle = TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'SpartanMB',
  color: Colors.white,
);

const kTempTextStyle = TextStyle(
  fontFamily: 'SpartanMB',
  fontSize: 100.0,
);

const kConditionTextStyle = TextStyle(
  fontSize: 100.0,
);

const kMessageTextStyle = TextStyle(
  fontFamily: 'SpartanMB',
  fontSize: 60.0,
);

const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
  ),
  hintText: "Enter City Name",
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);