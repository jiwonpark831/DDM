import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class chatPage extends StatefulWidget {
  const chatPage({super.key});

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Rooms")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .where('members', arrayContains: userUid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return ListTile(
                title: Text(chatRoom['lastMessage']),
                subtitle: Text(chatRoom['timestamp'].toDate().toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          eachChatPage(chatRoomId: chatRoom.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class eachChatPage extends StatefulWidget {
  final String chatRoomId;

  eachChatPage({required this.chatRoomId});

  @override
  _eachChatPageState createState() => _eachChatPageState();
}

class _eachChatPageState extends State<eachChatPage> {
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

    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomId)
        .update({
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
              createdAt: (doc['timestamp'] as Timestamp)
                  .toDate()
                  .millisecondsSinceEpoch,
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
