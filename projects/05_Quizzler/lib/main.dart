import 'package:flutter/material.dart';
import 'question.dart';
import 'quiz_brain.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

QuizBrain quizBrain = QuizBrain();
void main() {
  runApp(Quizzler());
}

class Quizzler extends StatelessWidget {
  const Quizzler({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: QuizPage(),
            ),
        ),
      ),
    );
  }

  _onBasicAlertPressed(context) {
    Alert(
      context: context,
      title: "RFLUTTER ALERT",
      desc: "Flutter is more awesome with RFlutter Alert.",
    ).show();
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Widget> scoreKeeper = [
  ];
  Question curQuestion = quizBrain.nextQuestion();

  void reSet() {
    quizBrain.reSet();
    scoreKeeper.clear();
  }

  void checkAnswers(bool response) {
    if (curQuestion.getQuestionAnswer() == response) {
      scoreKeeper.add(Icon(Icons.check, color: Colors.green));
    } else {
      scoreKeeper.add(Icon(Icons.close, color: Colors.red));
    }
    setState(() {
      if (quizBrain.isEnd()) {
        Alert(context: context, title: "Finished!", desc: "You've reached the end of the quiz.").show();
        reSet();
      }
      curQuestion = quizBrain.nextQuestion();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center (
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,// Centering the text for better UI
        children: [
          Expanded (
            flex: 10,
            child: Center (
              child: Text(
                curQuestion.getQuestionText(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Expanded (
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: ()=>{
                  checkAnswers(true),
                },
                child: Container (
                  decoration: BoxDecoration(
                    color: Colors.green, // 背景颜色
                    borderRadius: BorderRadius.circular(6), // 圆角半径
                  ),
                  // color: Colors.red,
                  child: Center (
                    child: Text(
                      'True',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded (
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: ()=>{
                  checkAnswers(false),
                },
                child: Container (
                  decoration: BoxDecoration(
                    color: Colors.red, // 背景颜色
                    borderRadius: BorderRadius.circular(6), // 圆角半径
                  ),
                  // color: Colors.red,
                  child: Center (
                      child: Text(
                          'False',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: scoreKeeper,
          ),
        ]
      ),
    );
  }
}


