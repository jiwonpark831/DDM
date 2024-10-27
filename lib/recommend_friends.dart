import 'package:flutter/material.dart';

class RecommendFriendsPage extends StatelessWidget {
  final List<Map<String, String>> recommendedFriends = [
    {'name': '추천 1', 'status': '친구 구해요'},
    {'name': '추천 2', 'status': '공강메이트 구함 !!'},
    {'name': '친구 3', 'status': '친구 추가 ?'},
    {'name': '친구 4', 'status': '공강 많다 ~'},
    {'name': '친구 5', 'status': '공강때 만날 사람~'},
    {'name': '친구 6', 'status': '우리 앱 이름 뭐하지'},
    {'name': '친구 7', 'status': '학회실 소라 3층'},
    {'name': '친구 8', 'status': '글로컬 경축'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👋새로운 친구를 찾아보세요!', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(8.0),
        itemCount: recommendedFriends.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(recommendedFriends[index]['name']!,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(recommendedFriends[index]['status']!),
            trailing: ElevatedButton(
              onPressed: () {
                // Add friend action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              child: Text('친구 추가'),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
