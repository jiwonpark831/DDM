import 'package:flutter/material.dart';
import 'recommend_friends.dart'; // Import the recommended friends page

class friendPage extends StatelessWidget {
  final List<Map<String, String>> friends = [
    {'name': '강시온', 'status': '휴학생 아닌 것 같다'},
    {'name': '박지원', 'status': '공강메이트 구함 !!'},
    {'name': '서규영', 'status': '촬영 바쁘다...!!'},
    {'name': '송승언', 'status': '벌써 막학기'},
    {'name': '최서은', 'status': '6학기 빡세다...ㅠㅠ'},
    {'name': '소당골', 'status': '우리 앱 이름 뭐하지'},
    {'name': '소다', 'status': '학회실 소라 3층'},
  ];

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => RecommendFriendsPage()),
              );
            },
            child: Text('+추천 친구', style: TextStyle(color: Colors.black)),
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
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(friends[index]['name']!,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(friends[index]['status']!),
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
  }
}
