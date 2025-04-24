import 'package:dabba_chat/Screen/chat_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'Screen/auth.dart';
import 'Screen/splash_Screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // demoProjectId:"dabbashop-5eddb"
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177)),

    ),home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges() ,
        builder: (ctx,snapShot){
      if(snapShot.connectionState==ConnectionState.waiting){
        return SplashScreen();
      }
if(snapShot.hasData){
  return ChatScreen();
}
return Auth();
    })
    );
  }
}


