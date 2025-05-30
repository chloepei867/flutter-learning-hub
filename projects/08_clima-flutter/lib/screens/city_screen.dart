import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String cityName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/city_background.jpg'),
              fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                      onPressed: ()=>{
                        Navigator.pop(context),
                      },
                      child: Icon(
                        color: Colors.white,
                        Icons.arrow_back_ios,
                        size: 50.0,
                      )
                  ),
                ),
                //text input box
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: kTextFieldInputDecoration,
                    onChanged: (value) =>{
                      cityName = value,
                    },
                  ),
                ),
                TextButton(
                    onPressed: ()=>{
                      Navigator.pop(context, cityName),
                    },
                    child: Text(
                      'Get Weather',
                      style: kButtonTextStyle,
                    ),
                )
              ],
            ),
        ),
      ),
    );
  }
}
