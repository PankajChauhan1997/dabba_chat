import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widget/message_bubble.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser=FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatSnapshot.hasError) {
          return const Center(child: Text("Something went wrong..."));
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No message found!!!"));
        }

        final loadedMessage = chatSnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(left:13.0,right:13 ,bottom: 40),
          itemCount: loadedMessage.length,
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessage[index].data() as Map<String, dynamic>;
            final nextchatMessage = index+1<loadedMessage.length
                ?loadedMessage[index+1].data() as Map<String, dynamic>
                :null;
            final currentMessageUserId=chatMessage['userId'];
            final NextMessageUserId=nextchatMessage!=null?nextchatMessage['userId']:null;
            final nexrUserIsSame=currentMessageUserId==NextMessageUserId;
            if(nexrUserIsSame){
              return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid==currentMessageUserId);
            }else{
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid==currentMessageUserId
              );
            }
          },
        );
      },
    );
  }
}