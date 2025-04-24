import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dabba Chit-Chat"),
        actions: [
          InkWell(child:
          Icon(Icons.exit_to_app,color: Theme.of(context).colorScheme.primary,),
      onTap: (){
            FirebaseAuth.instance.signOut();
      },
          )],
      ),
      body: Center(child: Text("Logged-In"),),
    );
  }
}
