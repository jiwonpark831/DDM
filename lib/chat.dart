import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

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
      appBar: AppBar(title: Text("내 채팅방")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .where('members', arrayContains: userUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chat rooms found."));
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];

              final lastMessage =
                  chatRoom.get('lastMessage') ?? 'No messages yet';
              final timestamp = chatRoom.get('timestamp') != null
                  ? (chatRoom.get('timestamp') as Timestamp).toDate()
                  : DateTime.now();

              return ListTile(
                title: Text(lastMessage),
                subtitle: Text('${timestamp.toString()}'),
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

  Future<void> _sendMessage(String text) async {
    final timestamp = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'senderId': userUid,
      'text': text,
      'timestamp': timestamp,
    });

    await FirebaseFirestore.instance
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
      appBar: AppBar(title: Text("여기 친구 uid 넣을 예정")),
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

          final messages = snapshot.data!.docs.map((doc){
            if(doc['senderId']!=null && doc['timestamp']!=null && doc['text'] !=null){
              return types.TextMessage(
                author: types.User(id: doc['senderId']),
                createdAt: (doc['timestamp'] as Timestamp)
                    .toDate()
                    .millisecondsSinceEpoch,
                id: doc.id,
                text: doc['text'],
              );
            }
            else {
              return types.TextMessage(
                author: types.User(id: ''),
                createdAt: 0,
                id: '',
                text: '',
              );
            }
          }).toList();

          return Chat(
            messages: messages,
            onSendPressed: (partialText) async {
              await _sendMessage(partialText.text);
            },
            user: types.User(id: userUid),
          );
        },
      ),
    );
  }
}
