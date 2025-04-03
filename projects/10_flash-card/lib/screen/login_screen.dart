import 'package:flash_card/constants.dart';
import 'package:flash_card/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_card/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const id = "login_screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible (
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset("images/logo.png"),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
              onChanged: (value){
                //TODO: handle user's input
                email = value;
              },
              decoration:kTextFieldDecoration.copyWith(
                hintText: "Enter your email",
              )
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value){
                //TODO: handle user's input
                  password = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your password',
              )
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
                bgColor: Colors.lightBlueAccent,
                onPressed: () async {
                //TODO: implement login functionality
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password
                    );
                    if (user != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      )
                      );
                    }
                    setState(() {
                      showSpinner = true;
                    });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      print('No user found for that email.');
                    } else if (e.code == 'wrong-password') {
                      print('Wrong password provided for that user.');
                    }
                  }
                },
                text: 'Log In',
            ),
          ],
        ),
      ),
    );
  }
}
