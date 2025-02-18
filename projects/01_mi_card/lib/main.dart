import 'package:flutter/material.dart';

void main() {
  runApp(
  MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home: Scaffold(
        backgroundColor: Colors.teal,
        body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // color: Colors.yellow[50],
                  CircleAvatar(
                    radius: 50,
                    child: ClipOval(
                      child: Image.asset(
                        'images/icebear.jpg',
                        width: 100,  // 使图片适应 `CircleAvatar`
                        height: 100,
                        fit: BoxFit.cover, // 让图片填充整个圆形区域
                      ),
                    ),
                  ),
                  Text(
                      'Ice Bear',
                      style: TextStyle(
                        fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        fontFamily:'Pacifico',
                        color: Colors.white,
                      ),
                  ),
                  Text(
                      "FLUTTER DEVELOPER",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.teal[100],
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'SourceCodePro',
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                    width: 150.0,
                    child: Divider(
                      color: Colors.teal[100],
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child:ListTile(
                          // padding:EdgeInsets.fromLTRB(10.0, 10.0,30.0,10.0),
                          leading: Icon(
                            Icons.phone,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                          title:Text(
                              "+1 123 456 7890",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        dense: true,
                      ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child:ListTile(
                      // padding:EdgeInsets.fromLTRB(10.0, 10.0,30.0,10.0),
                      leading: Icon(
                        Icons.email,
                        color: Colors.teal,
                        size: 30.0,
                      ),
                      title:Text(
                        "icebear@gmail.com",
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dense: true,
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}



