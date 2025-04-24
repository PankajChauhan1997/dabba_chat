import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dabba Chit-Chat"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(child:
            Icon(Icons.logout),
              onTap: (){
                FirebaseAuth.instance.signOut();
              },
            ),
          )],
      ),
      body: Center(child: Text("Loading...."),),
    );
  }
}
