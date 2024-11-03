import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'recommend_friends.dart'; // Import the recommended friends page
import 'friendsRequest.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

import 'user.dart';

class friendPage extends StatefulWidget {
  const friendPage({super.key});

  @override
  State<friendPage> createState() => friendPageState();
}

class friendPageState extends State<friendPage> {
  // List<Map<String, String>> friends = [
  //   {'name': '강시온', 'status': '휴학생 아닌 것 같다'},
  //   {'name': '박지원', 'status': '공강메이트 구함 !!'},
  //   {'name': '서규영', 'status': '촬영 바쁘다...!!'},
  //   {'name': '송승언', 'status': '벌써 막학기'},
  //   {'name': '최서은', 'status': '6학기 빡세다...ㅠㅠ'},
  //   {'name': '소당골', 'status': '우리 앱 이름 뭐하지'},
  //   {'name': '소다', 'status': '학회실 소라 3층'},
  // ];
  Map<String,bool> friends = {};
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
      friends = Map<String,bool>.from(doc.get('friendList'));
    }

    for (var entry in friends.entries){
      String key = entry.key;
      bool value = entry.value;
      if(value){
        var friend = await FirebaseFirestore.instance.collection('user').doc(key).get();
        if(friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]) friendsNameStatus.add({'name':friend.get('name'), 'status':friend.get('status'), 'uid':friend.get('uid')});
      }
    }
    
    // friends.forEach((key, value) async {
    //   print(key);
    //   print(value);
    //   if(value){
    //     var friend = await FirebaseFirestore.instance.collection('user').doc(key).get();
    //     print(friend.get('name'));
    //     print(friend.get('status'));
    //     print(friend.get('uid'));
    //     print(friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]);
    //     if(friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid]) friendsNameStatus.add({'name':friend.get('name'), 'status':friend.get('status'), 'uid':friend.get('uid')});
    //   };
    // });

    // Map<Future<String>,Future<bool>> friendFetchFutures = friends.map((key, value) async {
      
    // },);
    // List<Future<void>> friendFetchFutures = friends.map((uid,accept) async {
    //   print(element['uid']);
    //   print(element['accept']);
    //   if(element['accept']){
    //     var friend = await FirebaseFirestore.instance.collection('user').doc(element['uid']).get();
    //     print(friend.get('name'));
    //     print(friend.get('status'));
    //     print(friend.get('uid'));
    //     print(friend.get('accept'));
    //     if(friend.get('accept')) friendsNameStatus.add({'name':friend.get('name'), 'status':friend.get('status'), 'uid':friend.get('uid')});
    //   }
    // }).();

    // await Future.wait(friendFetchFutures);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        appBar: AppBar(
          title: Text('내 친구', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendsRequestPage()),
                );
              },
              child: Text('친구 요청', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecommendFriendsPage()),
                );
              },
              child: Text('+ 추천 친구', style: TextStyle(color: Colors.black)),
            ),
          ],
          leading: SizedBox(),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '친구를 검색해보세요',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
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
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Start chat action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                      ),
                      child: Text('1:1 채팅'),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  // Add new friend action
                },
                child: Text(
                  '+ 친구 추가',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.article), label: '게시판'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.location_on), label: '위치'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          ],
        ),
      );
    });
  }
}
