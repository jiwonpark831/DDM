import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'createboard.dart';
import 'meeting.dart';

class boardPage extends StatefulWidget {
  const boardPage({super.key});

  @override
  State<boardPage> createState() => _boardPageState();
}

class _boardPageState extends State<boardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> myMeetings = [];
  List<Map<String, dynamic>> shortMeetings = [];
  List<Map<String, dynamic>> longMeetings = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    QuerySnapshot snapshot = await _firestore.collection('board').get();
    List<Map<String, dynamic>> allMeetings =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    shortMeetings =
        allMeetings.where((meeting) => meeting['type'] == '단기').toList();
    longMeetings =
        allMeetings.where((meeting) => meeting['type'] == '장기').toList();

    myMeetings = allMeetings
        .where((meeting) =>
            meeting['members'] != null && meeting['members'].contains(userId))
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 70, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 모임',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: myMeetings.length,
                itemBuilder: (context, index) {
                  var meeting = myMeetings[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: MeetingCard(
                      meetingData: meeting,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MeetingDetailPage(meetingData: meeting)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 60),
            Text('모임 게시판',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              width: 400,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  ListTile(
                    title: Text('단기모임'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MeetingListPage(
                                meetings: shortMeetings, title: '단기모임')),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('장기모임'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MeetingListPage(
                                meetings: longMeetings, title: '장기모임')),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateMeetingPage()),
                  );
                },
                child: Text('+ 모임 만들기',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
