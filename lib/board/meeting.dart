import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'shared.dart';

class MeetingDetailPage extends StatefulWidget {
  final Map<String, dynamic> meetingData;

  MeetingDetailPage({required this.meetingData});

  @override
  _MeetingDetailPageState createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isJoined = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    checkIfJoined();
    if (widget.meetingData['type'] == '장기') {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void checkIfJoined() {
    if (widget.meetingData['members'] != null &&
        widget.meetingData['members'].contains(userId)) {
      setState(() {
        isJoined = true;
      });
    }
  }

  Future<void> joinMeeting() async {
    if (userId != null) {
      await _firestore
          .collection('board')
          .doc(widget.meetingData['id'])
          .update({
        'members': FieldValue.arrayUnion([userId!]),
      });
      setState(() {
        isJoined = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.meetingData['title'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('주최자: ${widget.meetingData['organizer']}'),
            Text('날짜: ${widget.meetingData['date']}'),
            Text('시간: ${widget.meetingData['time']}'),
            Text('장소: ${widget.meetingData['location']}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isJoined ? null : joinMeeting,
              child: Text(isJoined ? '참여 완료' : '참여하기'),
            ),
            if (isJoined) ...[
              SizedBox(height: 20),
              if (widget.meetingData['type'] == '장기' && _tabController != null)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '공유 캘린더'),
                    Tab(text: '게시판'),
                  ],
                ),
              Expanded(
                child: widget.meetingData['type'] == '장기' &&
                        _tabController != null
                    ? TabBarView(
                        controller: _tabController,
                        children: [
                          SharedCalendarPage(
                              meetingId: widget.meetingData['id']),
                          SharedBoardPage(meetingId: widget.meetingData['id']),
                        ],
                      )
                    : SharedBoardPage2(meetingId: widget.meetingData['id']),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MeetingListPage extends StatelessWidget {
  final List<Map<String, dynamic>> meetings;
  final String title;

  MeetingListPage({required this.meetings, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: meetings.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          var meeting = meetings[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 3,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeetingDetailPage(meetingData: meeting),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: meeting['imageUrl'] != null
                          ? (meeting['imageUrl'].startsWith('http')
                                  ? NetworkImage(meeting['imageUrl'])
                                  : FileImage(File(meeting['imageUrl'])))
                              as ImageProvider
                          : NetworkImage(
                              'https://your-default-image-url.com/default.jpg'),
                      radius: 30,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('주최자: ${meeting['organizer']}'),
                          Text('날짜: ${meeting['date']}'),
                          Text('시간: ${meeting['time']}'),
                          Text('장소: ${meeting['location']}'),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final Map<String, dynamic> meetingData;
  final VoidCallback onTap;

  MeetingCard({required this.meetingData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isLocalFile = meetingData['imageUrl'] != null &&
        File(meetingData['imageUrl']).existsSync();
    final imageWidget = isLocalFile
        ? FileImage(File(meetingData['imageUrl']))
        : NetworkImage(meetingData['imageUrl'] ??
            'https://your-default-image-url.com/default.jpg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: imageWidget as ImageProvider,
                radius: 40,
              ),
            ),
            SizedBox(height: 8),
            Text(
              meetingData['title'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주최자: ${meetingData['organizer'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                  Text('날짜: ${meetingData['date'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                  Text('시간: ${meetingData['time'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                  Text('장소: ${meetingData['location'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
