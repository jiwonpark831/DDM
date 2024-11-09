import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': '00모임 소식',
      'subtitle': '새로운 팀원이 추가되었어요!',
    },
    {
      'title': '현재 4명의 친구가 공강입니다.',
      'subtitle': '지금 바로 확인해보세요!',
    },
    {
      'title': '00님과 친구가 되었어요.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림', style: TextStyle(color: Colors.black)),
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
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            title: Text(
              notifications[index]['title']!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: notifications[index].containsKey('subtitle')
                ? Text(
                    notifications[index]['subtitle']!,
                    style: TextStyle(color: Colors.grey),
                  )
                : null,
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
