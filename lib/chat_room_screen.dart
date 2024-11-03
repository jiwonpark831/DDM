import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;

  ChatRoomScreen({required this.chatRoomId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage(String text) {
    final timestamp = FieldValue.serverTimestamp();

    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'senderId': userUid,
      'text': text,
      'timestamp': timestamp,
    });

    FirebaseFirestore.instance.collection('chat').doc(widget.chatRoomId).update({
      'lastMessage': text,
      'timestamp': timestamp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Room")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(widget.chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs.map((doc) {
            return types.TextMessage(
              author: types.User(id: doc['senderId']),
              createdAt: (doc['timestamp'] as Timestamp).toDate().millisecondsSinceEpoch,
              id: doc.id,
              text: doc['text'],
            );
          }).toList();

          return Chat(
            messages: messages,
            onSendPressed: (partialText) {
              _sendMessage(partialText.text);
            },
            user: types.User(id: userUid),
          );
        },
      ),
    );
  }
}
