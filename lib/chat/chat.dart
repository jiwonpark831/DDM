import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'eachchat.dart';

class chatPage extends StatefulWidget {
  const chatPage({super.key});

  @override
  State<chatPage> createState() => _chatPageState();
}

class _chatPageState extends State<chatPage> {
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> _getOtherUserData(List<dynamic> members) async {
    final otherUserId = members.firstWhere((id) => id != userUid);
    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(otherUserId)
        .get();
    return userDoc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 30),
              child: Text("채팅"),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
        centerTitle: false,
      ),
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
                  : null;

              return FutureBuilder(
                future: _getOtherUserData(chatRoom['members']),
                builder: (context,
                    AsyncSnapshot<Map<String, dynamic>> userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Please wait'),
                    );
                  }

                  final otherUserData = userSnapshot.data!;
                  final otherUserName = otherUserData['name'] ?? 'Unknown';
                  final otherUserImageURL = otherUserData['imageURL'] ?? '';

                  final timeAgoText = timestamp != null
                      ? timeago.format(timestamp)
                      : 'No timestamp';

                  return ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                        backgroundImage: otherUserImageURL.isNotEmpty
                            ? NetworkImage(otherUserImageURL)
                            : AssetImage('assets/placeholder.png')
                                as ImageProvider,
                      ),
                    ),
                    title: Text(otherUserName),
                    subtitle: Text(lastMessage),
                    trailing: Text(timeAgoText),
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
          );
        },
      ),
    );
  }
}
