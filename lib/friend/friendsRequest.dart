import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class FriendsRequestPage extends StatefulWidget {
  const FriendsRequestPage({super.key});

  @override
  State<FriendsRequestPage> createState() => FriendsRequestPageState();
}

class FriendsRequestPageState extends State<FriendsRequestPage> {
  final List<Map<String, String>> FriendsRequestList = [];
  Map<String, bool> friends = {};
  List<Map<String, String>> friendsNameStatus = [];

  @override
  void initState() {
    super.initState();
    getfriendList();
  }

  getfriendList() async {
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
      if (!value) {
        var friend =
            await FirebaseFirestore.instance.collection('user').doc(key).get();
        if (friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid])
          friendsNameStatus.add({
            'name': friend.get('name'),
            'status': friend.get('status'),
            'uid': friend.get('uid')
          });
      }
    }

    setState(() {});

    // List<Future<void>> friendFetchFutures = friends.map((element) async {
    //   print(element['uid']);
    //   print(element['accept']);
    //   if(!element['accept']){
    //     var friend = await FirebaseFirestore.instance.collection('user').doc(element['uid']).get();
    //     friendsNameStatus.add({'name':friend.get('name'), 'status':friend.get('status'), 'uid':friend.get('uid')});
    //   }
    // }).toList();

    // await Future.wait(friendFetchFutures);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: Text(' 친구 요청 ', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back, color: Colors.grey),
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // ),
        ),
        body: ListView.separated(
          padding: EdgeInsets.all(8.0),
          itemCount: friendsNameStatus.length,
          itemBuilder: (context, index) {
            return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.black),
                ),
                title: Text(friendsNameStatus[index]['name']!,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(friendsNameStatus[index]['status']!),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  ElevatedButton(
                    onPressed: () async {
                      DocumentSnapshot doc = await FirebaseFirestore.instance
                          .collection('user')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      var myFriends =
                          Map<String, bool>.from(doc.get('friendList'));
                      myFriends[friendsNameStatus[index]['uid'] as String] =
                          true;
                      DocumentSnapshot friendDoc = await FirebaseFirestore
                          .instance
                          .collection('user')
                          .doc(friendsNameStatus[index]['uid'])
                          .get();
                      var friendsFriends =
                          Map<String, bool>.from(friendDoc.get('friendList'));
                      appState.requestFriend(
                          appState.currentuser.uid,
                          friendsNameStatus[index]['uid'] as String,
                          myFriends,
                          friendsFriends);
                      print('수락');
                      setState(() {
                        friendsNameStatus.removeAt(index);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff6AEFC0),
                      elevation: 0,
                    ),
                    child: Text(
                      '수락',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DocumentSnapshot doc = await FirebaseFirestore.instance
                          .collection('user')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();
                      var myFriends =
                          Map<String, bool>.from(doc.get('friendList'));
                      myFriends
                          .remove(friendsNameStatus[index]['uid'] as String);
                      DocumentSnapshot friendDoc = await FirebaseFirestore
                          .instance
                          .collection('user')
                          .doc(friendsNameStatus[index]['uid'])
                          .get();
                      var friendsFriends =
                          Map<String, bool>.from(friendDoc.get('friendList'));
                      friendsFriends.remove(appState.currentuser.uid);
                      appState.requestFriend(
                          appState.currentuser.uid,
                          friendsNameStatus[index]['uid'] as String,
                          myFriends,
                          friendsFriends);
                      print('거절');
                      setState(() {
                        friendsNameStatus.removeAt(index);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffEEEEEE),
                      elevation: 0,
                    ),
                    child: Text(
                      '거절',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ]));
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      );
    });
  }
}
