import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme/color.dart';

class RecommendFriendsPage extends StatefulWidget {
  const RecommendFriendsPage({super.key});

  @override
  State<RecommendFriendsPage> createState() => RecommendFriendsPageState();
}

class RecommendFriendsPageState extends State<RecommendFriendsPage> {
  // final List<Map<String, String>> recommendedFriends = [
  //   {'name': '추천 1', 'status': '친구 구해요'},
  //   {'name': '추천 2', 'status': '공강메이트 구함 !!'},
  //   {'name': '친구 3', 'status': '친구 추가 ?'},
  //   {'name': '친구 4', 'status': '공강 많다 ~'},
  //   {'name': '친구 5', 'status': '공강때 만날 사람~'},
  //   {'name': '친구 6', 'status': '우리 앱 이름 뭐하지'},
  //   {'name': '친구 7', 'status': '학회실 소라 3층'},
  //   {'name': '친구 8', 'status': '글로컬 경축'},
  // ];
  Map<String, bool> friends = {};
  List<Map<String, String>> recommendedFriends = [];

  @override
  void initState() {
    super.initState();
    getuserList();
  }

  getuserList() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('user').get();

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.data() != null && doc.get('friendList') != null) {
      friends = Map<String, bool>.from(doc.get('friendList'));
    }

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['uid'] == FirebaseAuth.instance.currentUser!.uid) continue;
      var friendCheck = false;
      for (var entry in friends.entries) {
        String key = entry.key;
        if (key == data['uid']) friendCheck = true;
      }
      if (friendCheck) continue;
      recommendedFriends.add(
          {'name': data['name'], 'status': data['status'], 'uid': data['uid'],'imageURL':data['imageURL']});
    }

    // List<Future<void>> friendFetchFutures = friends.map((element) async {
    //   print(element['uid']);
    //   print(element['accept']);
    //   if(element['accept']){
    //     var friend = await FirebaseFirestore.instance.collection('user').doc(element['uid']).get();
    //     friendsNameStatus.add({'name':friend.get('name'), 'status':friend.get('status'), 'uid':friend.get('uid')});
    //   }
    // }).toList();

    // await Future.wait(friendFetchFutures);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title:
              Text('👋 새로운 친구를 찾아보세요!', style: TextStyle(color: Colors.black)),
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
          itemCount: recommendedFriends.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                    recommendedFriends[index]['imageURL'] as String),
                    
              ),
              title: Text(recommendedFriends[index]['name']!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(recommendedFriends[index]['status']!),
              trailing: ElevatedButton(
                onPressed: () async {
                  DocumentSnapshot doc = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();
                  var myFriends = Map<String, bool>.from(doc.get('friendList'));
                  myFriends[recommendedFriends[index]['uid'] as String] = true;
                  DocumentSnapshot friendDoc = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(recommendedFriends[index]['uid'])
                      .get();
                  var friendsFriends =
                      Map<String, bool>.from(friendDoc.get('friendList'));
                  friendsFriends[appState.currentuser.uid] = false;
                  appState.requestFriend(
                      appState.currentuser.uid,
                      recommendedFriends[index]['uid'] as String,
                      myFriends,
                      friendsFriends);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  elevation: 0,
                ),
                child: Text(
                  '친구 추가',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      );
    });
  }
}
