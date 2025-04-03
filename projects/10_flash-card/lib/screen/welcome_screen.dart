import 'package:flash_card/constants.dart';
import 'package:flash_card/screen/login_screen.dart';
import 'package:flash_card/screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_card/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static const id = "welcome_screen";

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
    );
    _animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(_controller);
    _controller.forward();
    _controller.addListener(() {
      setState(() {});
      }
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 60.0,
                    child: Image.asset("images/logo.png"),
                  ),
                ),
                AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                            'Flash Card',
                          textStyle: TextStyle(
                            fontSize: 35.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                  ),
                SizedBox(
                  height: 48.0,
                ),
              ],
            ),
            RoundedButton(
              bgColor: Color(0xff64B5F6),
              text: "Log In",
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen()),
                );
              },
            ),
            RoundedButton(
                bgColor: Colors.blueAccent,
                onPressed: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignupScreen()),
                  );
                },
                text: 'Sign Up',
            )
          ],
        ),
      ),
    );
  }
}


