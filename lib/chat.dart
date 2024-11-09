import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

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
              primaryColor: Color(0xff64DCAC),
              secondaryColor: Color(0xffEEEEEE),
              inputTextColor: Colors.black,
              inputTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              inputContainerDecoration: BoxDecoration(
                color: Color(0xffEEEEEE),
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
