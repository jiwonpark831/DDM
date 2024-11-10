import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../theme/color.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.meetingData['title']),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      isJoined ? AppColor.secondary : AppColor.primary),
              onPressed: isJoined ? null : joinMeeting,
              child: Text(
                isJoined ? '참여 완료' : '참여하기',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('${widget.meetingData['organizer']}'),
            Text('🗓️${widget.meetingData['date']}'),
            Text('⏰${widget.meetingData['time']}'),
            Text('📍${widget.meetingData['location']}'),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: isJoined ? null : joinMeeting,
            //   child: Text(isJoined ? '참여 완료' : '참여하기'),
            // ),
            if (isJoined) ...[
              SizedBox(height: 20),
              if (widget.meetingData['type'] == '장기' && _tabController != null)
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '일정'),
                    Tab(text: '게시판'),
                  ],
                  labelStyle: TextStyle(color: Colors.black),
                  indicatorColor: AppColor.primary,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: meetings.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          var meeting = meetings[index];
          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.secondary,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Card(
              margin: EdgeInsets.only(bottom: 16),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(12.0),
              // ),
              elevation: 0,
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
                  color: Colors.white,
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: meeting['imageUrl'] != null &&
                                meeting['imageUrl'].startsWith('http')
                            ? NetworkImage(meeting['imageUrl'])
                            : (meeting['imageUrl'] != null
                                    ? FileImage(File(meeting['imageUrl']))
                                    : NetworkImage(
                                        'https://your-default-image-url.com/default.jpg'))
                                as ImageProvider,
                        radius: 40,
                      ),
                      SizedBox(width: 20),
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
                            Text('${meeting['organizer']}'),
                            Text('🗓️${meeting['date']}'),
                            Text('⏰${meeting['time']}'),
                            Text('📍${meeting['location']}'),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ],
                  ),
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
    final bool isLocalFile = meetingData['imageUrl'] != null &&
        !meetingData['imageUrl'].startsWith('http');
    final imageProvider = isLocalFile
        ? FileImage(File(meetingData['imageUrl']))
        : NetworkImage(meetingData['imageUrl'] ??
            'https://your-default-image-url.com/default.jpg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xffD9D9D9)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                image: DecorationImage(
                  image: imageProvider as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetingData['title'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8),
                  // Text('주최자: ${meetingData['organizer'] ?? ''}',
                  //     overflow: TextOverflow.ellipsis),
                  Text('🗓️${meetingData['date'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                  Text('⏰${meetingData['time'] ?? ''}',
                      overflow: TextOverflow.ellipsis),
                  Text('📍${meetingData['location'] ?? ''}',
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
