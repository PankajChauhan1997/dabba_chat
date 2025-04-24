import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widget/user_image.dart';

final firebaseAuth=FirebaseAuth.instance;
class Auth extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _AuthState();
  }
  
}
class _AuthState extends State<Auth>{
  final _form=GlobalKey<FormState>();
var email=TextEditingController();
var pass=TextEditingController();
var isLogin=false;
File ?selectedImage;

  void _submit() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid||selectedImage==null||!isLogin) {
      return;
    }

    _form.currentState!.save();

    try {
      UserCredential userCred;

      if (isLogin) {
        print("Attempting login...");

        userCred = await firebaseAuth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );

        final user = userCred.user;

        if (user != null) {
          if (user.emailVerified) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Login successful!",
                style: TextStyle(color: Colors.white),
              ),
            ));
          } else {
            await user.sendEmailVerification();
            await firebaseAuth.signOut(); // Sign out if not verified

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orange,
              content: Text(
                "Email not verified. A verification email has been sent. Please verify to continue.",
                style: TextStyle(color: Colors.white),
              ),
            ));
          }
        } else {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'User not found.');
        }
      } else {
        print("Attempting signup...");

        userCred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );
        ///Store in firebase storage and download it...start
// final storageRef=FirebaseStorage.instance.ref().child('User_Images').child('${userCred.user!.uid}.jpg');
// await storageRef.putFile(selectedImage!);
//         final getImage=await storageRef.getDownloadURL();
//         print("getImage...${getImage}");
        ///Store in firebase storage and download it...end
        final user = userCred.user;

        if (user != null) {
          await user.sendEmailVerification();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registration successful! A verification email has been sent.",
              style: TextStyle(color: Colors.white),
            ),
          ));
        } else {
          throw FirebaseAuthException(
              code: 'registration-failed', message: 'User registration failed.');
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: $e");
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          e.message ?? "Authentication failed",
          style: TextStyle(color: Colors.white),
        ),
      ));
    } catch (e) {
      print("General Exception: $e");
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "An unexpected error occurred. Please try again.",
          style: TextStyle(color: Colors.white),
        ),
      ));
    }

    email.clear();
    pass.clear();
  }

  @override
  Widget build(BuildContext context) {

   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.primary,
     body: Center(child: SingleChildScrollView(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
         Container(
           margin: EdgeInsets.only(
             top:30 ,
             bottom:20 ,
             left:20 ,
             right: 20
         ),width: 200,child: Image.asset('asset/images/chat.png'),),
           Card(margin: EdgeInsets.all(20),
             child: SingleChildScrollView(
               padding: EdgeInsets.all(16),
             child: Form(
key: _form,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   if(!isLogin)UserImage(onpickedImage:(pickedImage){
                     selectedImage=pickedImage;
                   } ,),
                 TextFormField(
                   validator:(value){
                     if(value==null||value.isEmpty||!value.contains("@")){
                       return "Please enter an valid email address!!";
                     }
                     return null;

                   },
                   controller:email ,
                   decoration: InputDecoration(
                     labelText: 'Enter email address'
                   ),
                   keyboardType: TextInputType.emailAddress,
                   autocorrect: false,
                   textCapitalization: TextCapitalization.none,
                   onSaved: (value){
                     email.text=value!;
                   },
                 ),
                   TextFormField(
                     validator:(value){
                       if(value==null||value.isEmpty||value.trim().length<6){
                         return "Password must be atleast 6 character long!!";
                       }
                       return null;
                     },
                     controller:pass ,
                   decoration: InputDecoration(
                     labelText: 'Enter password'
                   ),
                   obscureText: true,
                     onSaved: (value){
                       pass.text=value!;

                     },
                 ),
                   SizedBox(height: 12,),

                   ElevatedButton(
                     onPressed: _submit,
                   child: Text(isLogin?"LogIn":"SignUp"),
                   style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                   ),

                   TextButton(onPressed: (){
                setState(() {
                  isLogin=!isLogin;
                });
                   }, child: Text(isLogin?"Create an account":"Already have an account")),
               ],),
             ),
             ),)
       ],),
     ),),
   );
  }
  
}