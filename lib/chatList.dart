import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
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
                      builder: (context) => ChatRoomScreen(chatRoomId: chatRoom.id),
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
