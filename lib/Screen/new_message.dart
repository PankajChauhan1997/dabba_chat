import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget{
  NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }

}
class _NewMessageState extends State<NewMessage>{
  final _messageController=TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit()async{
final enteredMessage=_messageController.text;
if(enteredMessage.trim().isEmpty){
  return;
}

_messageController.clear();
FocusScope.of(context).unfocus();

final user=FirebaseAuth.instance.currentUser!;
final userData=await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
 FirebaseFirestore.instance.collection('chat').add({
  'text':enteredMessage,
  'createdAt':Timestamp.now(),
  'userId':user.uid,
  'username':userData.data()!['username']??"Pankaj",
  'userImage':userData.data()!['imageBase64'],
});

  }
  @override
  Widget build(BuildContext context) {
   return Padding(padding: EdgeInsets.only(
       left: 15,right: 1,bottom: 5),
     child: Row(children: [
       Expanded(child: TextField(
         controller: _messageController,
         textCapitalization: TextCapitalization.sentences,
         autocorrect: true,
         enableSuggestions: true,
         decoration: InputDecoration(labelText: "Send a message"),
       )),
         IconButton(onPressed: _submit, icon: Icon(Icons.send),
           color: Theme.of(context).colorScheme.primary,
       )
     ],),
   );
  }

}