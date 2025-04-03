import 'package:flutter/material.dart';
import 'package:flash_card/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const id = "chat_screen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  // late User loggedInUser;
  late String email;
  late String password;
  String messageText = "";
  final Stream<QuerySnapshot> _messagesStream = _db.collection('messages').snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCurrentUser();

  }

  // Future<void> getCurrentUser() async {
  //   final user = _auth.currentUser;
  //   try {
  //     if (user != null) {
  //        setState(() {
  //          loggedInUser = user;
  //        });
  //       print(loggedInUser.email);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    // print(_messagesStream);
    return Scaffold(
      appBar: AppBar(
        title: Text("⚡️Chat"),
        actions: [
          IconButton(
              icon: Icon(Icons.close),
              onPressed: (){
                //TODO: implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              },
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
        leading: null,
        
      ),
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: MessagesStream(),
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value){
                          //TODO: handle user's input
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        messageTextController.clear();
                        //TODO: implement send functionality
                        _db
                            .collection('messages')
                            .add({
                          'text': messageText,
                          'sender': _auth.currentUser!.email,
                          'timestamp': Timestamp.now(),
                        }).then((_) {
                          print("Message successfully sent!");
                        }).catchError((error) {
                          print("Failed to send message: $error");
                        });
                      },
                      child: Text(
                        "Send",
                        style: kSendButtonTextStyle,
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('messages').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        if (snapshot.hasData) {

          final messages = snapshot.data!.docs;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            Map<String, dynamic>? data = message.data() as Map<String, dynamic>?;
            if (message.data() == null) return SizedBox();
            final messageBubble = MessageBubble(
                text: data?['text'],
                sender: data?['sender'],
                timestamp: data?['timestamp'],
                isMe: _auth.currentUser?.email == data?['sender'],
            );
            messageWidgets.add(messageBubble);
          }
          // messageWidgets.toList();
          // messageWidgets.sort((a,b) => b.timestamp.compareTo(a.timestamp));
          return ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          );
        }
        return Text("hhhh");
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({required this.text, required this.sender, required this.isMe, required this.timestamp});
  final String text;
  final String sender;
  final Timestamp timestamp;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
              sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe ? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0))
            :  BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            color: isMe? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                  text,
                style: TextStyle(
                  color: isMe? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
