import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        appBar: AppBar(
          elevation: 6.0,
          backgroundColor: Colors.red,
          title: Text(
              'Dicee',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ),
        body: DicePage(),
      ),
    ),
  );
}

class DicePage extends StatelessWidget {
  const DicePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: ImageSwitcherScreen(),
          ),
          Expanded(
            child: ImageSwitcherScreen(),
          ),
        ],
      ),
    );
  }
}

class ImageSwitcherScreen extends StatefulWidget {
  const ImageSwitcherScreen({super.key});

  @override
  State<ImageSwitcherScreen> createState() => _ImageSwitcherScreenState();
}

class _ImageSwitcherScreenState extends State<ImageSwitcherScreen> {
  //the index of current image
  int _currentIndex = 0;
  final List<String> _imagePaths = [
    'images/dice1.png', // 本地图片
    'images/dice2.png',
    'images/dice3.png',
    'images/dice4.png',
    'images/dice5.png',
    'images/dice6.png',
  ];

  void _switchImage() {
    Random random = Random();
    setState(() {
      _currentIndex = random.nextInt(_imagePaths.length);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: _switchImage,
        child: Image
            .asset(
          _imagePaths[_currentIndex],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}









