import 'package:dabba_chat/Screen/chat_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screen/auth.dart';
import 'Screen/splash_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      // options:  FirebaseOptions(
        // apiKey: "YOUR_API_KEY", // Replace with your actual values
        // appId: "YOUR_APP_ID",
        // messagingSenderId: "YOUR_SENDER_ID",
        // projectId: "YOUR_PROJECT_ID",
        // // Add other required options for your platforms
      // ),
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: // In your main app widget (where you have StreamBuilder)
      StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            if (!user.emailVerified) {
              // Force logout if email isn't verified
              FirebaseAuth.instance.signOut();
              return const AuthScreen();
            }
            return const ChatScreen();
          }

          return const AuthScreen();
        },
      )
    );
  }
}