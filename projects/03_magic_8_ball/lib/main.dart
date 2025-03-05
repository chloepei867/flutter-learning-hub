import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text(
              "Ask Me Anything",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
             ImagePage()
          ],
        ),
      ),
    ),
  );
}

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  int index = 1;
  void _switchImage() {
    Random random = Random();
    setState(() {
      index = random.nextInt(5) + 1;
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _switchImage,
      child: Image
          .asset(
        'images/ball$index.png',
        fit: BoxFit.cover,
      ),
    );
  }
}


