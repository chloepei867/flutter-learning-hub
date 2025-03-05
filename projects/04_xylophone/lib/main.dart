import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {runApp(XylophoneApp());}

class XylophoneApp extends StatelessWidget {
  // const XylophoneApp({super.key});
  void playSound(int soundNumber) async {
    final player = AudioPlayer();
    await player.play(AssetSource('note$soundNumber.wav'));
  }

  Widget buildKey(int soundNumber, Color color) {
    return Expanded(
      child: GestureDetector(
          onTap: () async {
            playSound(soundNumber);
          },
          child: Container(
            color: color,
          )
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){
    return MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(

              children: [
                buildKey(1, Colors.red),
                buildKey(2, Colors.orange),
                buildKey(3, Colors.yellow),
                buildKey(4, Colors.green),
                buildKey(5, Colors.blue),
                buildKey(6, Colors.green[900]!),
                buildKey(7, Colors.purple),
            ],
            ),
          ),
        ),
      );
  }
}

