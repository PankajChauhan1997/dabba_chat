import 'package:dabba_chat/Screen/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'chat_Message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setPushNotification() async {
    ///you could send this token(via HTTP or firestore SDK)to backend
    ///you can send a message to a single device and whole channel through messaging
    try {
      // Get the FCM token (no permission needed on Android by default)
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print("FCM Token: $token");
        // Send this token to your backend for push notifications
        // Example: await saveTokenToServer(token);
      } else {
        print("Failed to get FCM token: Token is null");
      }

      // Optional: Listen for token refresh (important for long-lived sessions)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("Refreshed FCM Token: $newToken");
        // Update the new token in your backend
        // Example: await updateTokenInServer(newToken);
      });

    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

@override
void initState() {
    super.initState();
    setPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dabba Chit-Chat"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(child:
            Icon(Icons.exit_to_app,color: Theme.of(context).colorScheme.primary,),
                  onTap: (){
              FirebaseAuth.instance.signOut();
                  },
            ),
          )],
      ),
      body: Column(
        children: [
          Expanded(
              child: ChatMessage()
          ),
          NewMessage(),
        ],
      )
    );
  }
}
