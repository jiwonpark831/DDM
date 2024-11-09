import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../theme/color.dart';

class eachChatPage extends StatefulWidget {
  final String chatRoomId;

  eachChatPage({required this.chatRoomId});

  @override
  _eachChatPageState createState() => _eachChatPageState();
}

class _eachChatPageState extends State<eachChatPage> {
  final String userUid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? otherUserData;

  @override
  void initState() {
    super.initState();
    _fetchOtherUserData();
  }

  Future<void> _fetchOtherUserData() async {
    final chatDoc = await FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatRoomId)
        .get();
    final members = List<String>.from(chatDoc['members']);
    final otherUserId = members.firstWhere((id) => id != userUid);

    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(otherUserId)
        .get();
    setState(() {
      otherUserData = userDoc.data();
    });
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: otherUserData == null
            ? Text("Loading...")
            : Row(
                children: [
                  CircleAvatar(
                    backgroundImage: otherUserData!['imageURL'] != null
                        ? NetworkImage(otherUserData!['imageURL'])
                        : AssetImage('assets/placeholder.png') as ImageProvider,
                  ),
                  SizedBox(width: 15),
                  Text(otherUserData!['name'] ?? "Unknown"),
                ],
              ),
      ),
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
              createdAt: doc['timestamp'] != null
                  ? (doc['timestamp'] as Timestamp)
                      .toDate()
                      .millisecondsSinceEpoch
                  : DateTime.now().millisecondsSinceEpoch,
              id: doc.id,
              text: doc['text'],
            );
          }).toList();

          return Chat(
            messages: messages,
            onSendPressed: (partialText) async {
              await _sendMessage(partialText.text);
            },
            user: types.User(id: userUid),
            theme: DefaultChatTheme(
              primaryColor: AppColor.primary,
              secondaryColor: AppColor.secondary,
              inputTextColor: Colors.black,
              inputTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              inputContainerDecoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(20),
                // border: Border.all(
                //   color: Colors.grey.shade300,
                //   width: 1.0,
                // ),
              ),
            ),
          );
        },
      ),
    );
  }
}
