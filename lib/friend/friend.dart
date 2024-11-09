import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat/chat.dart';
import '../chat/eachchat.dart';
import '../theme/color.dart';
import 'friendrecommand.dart';
import 'friendsRequest.dart';
import '../chat/chat.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'friendprofile.dart';

class friendPage extends StatefulWidget {
  const friendPage({super.key});

  @override
  State<friendPage> createState() => friendPageState();
}

class friendPageState extends State<friendPage> {
  Map<String, bool> friends = {};
  List<Map<String, String>> friendsNameStatus = [];

  @override
  void initState() {
    super.initState();
    getfriendList();
  }

  getfriendList() async {
    friends = {};
    friendsNameStatus = [];
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.data() != null && doc.get('friendList') != null) {
      friends = Map<String, bool>.from(doc.get('friendList'));
    }

    for (var entry in friends.entries) {
      String key = entry.key;
      bool value = entry.value;
      if (value) {
        var friend =
            await FirebaseFirestore.instance.collection('user').doc(key).get();
        if (friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]) {
          friendsNameStatus.add({
            'name': friend.get('name'),
            'status': friend.get('status'),
            'uid': friend.get('uid'),
            'imageURL': friend.get('imageURL')
          });
        }
      }
    }
    setState(() {});
  }

  Future<String> _getOrCreateChatRoom(String friendUid) async {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot chatRooms = await FirebaseFirestore.instance
        .collection('chat')
        .where('members', arrayContains: currentUserUid)
        .get();

    for (var room in chatRooms.docs) {
      List<dynamic> members = room['members'];
      if (members.contains(friendUid)) {
        return room.id;
      }
    }

    DocumentReference newChatRoom =
        FirebaseFirestore.instance.collection('chat').doc();
    await newChatRoom.set({
      'members': [currentUserUid, friendUid],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return newChatRoom.id;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Text('내 친구', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendsRequestPage()),
                ).then((_) async {
                  await getfriendList();
                });
              },
              child: Text('친구 요청', style: TextStyle(color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecommendFriendsPage()),
                  ).then((_) async {
                    await getfriendList();
                  });
                  setState(() {});
                },
                child: Text('+ 추천 친구', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
          leading: SizedBox(),
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     height: 40,
            //     width: 350,
            //     child: TextField(
            //       decoration: InputDecoration(
            //         hintText: '친구를 검색해보세요',
            //         prefixIcon: Icon(Icons.search),
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(8.0),
            //         ),
            //         filled: true,
            //         fillColor: Colors.grey[200],
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(8.0),
                itemCount: friendsNameStatus.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap:((){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FriendProfilePage(frienduid: friendsNameStatus[index]['uid'] as String),
                        )
                      );
                    }),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                          friendsNameStatus[index]['imageURL'] as String),
                    ),
                    title: Text(friendsNameStatus[index]['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(friendsNameStatus[index]['status']!),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        String friendUid = friendsNameStatus[index]['uid']!;
                        String chatRoomId =
                            await _getOrCreateChatRoom(friendUid);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                eachChatPage(chatRoomId: chatRoomId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        elevation: 0,
                      ),
                      child: Text(
                        '1:1 채팅',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
