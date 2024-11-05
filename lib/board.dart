import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 100, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내 모임',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 160,
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
            SizedBox(height: 32),
            Text(
              '모임 게시판',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
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
            Divider(),
            ListTile(
              title: Text('찜한 모임'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            Divider(),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateMeetingPage()),
                  );
                },
                child: Text('+ 모임 만들기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingDetailPage extends StatefulWidget {
  final Map<String, dynamic> meetingData;

  MeetingDetailPage({required this.meetingData});

  @override
  _MeetingDetailPageState createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isJoined = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
    checkIfJoined();
  }

  Future<void> checkIfJoined() async {
    DocumentSnapshot doc = await _firestore
        .collection('board')
        .doc(widget.meetingData['id'])
        .get();
    List<dynamic> members = doc['members'] ?? [];
    setState(() {
      isJoined = userId != null && members.contains(userId);
    });
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

      final boardPageState = context.findAncestorStateOfType<_boardPageState>();
      boardPageState?.fetchMeetings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meetingData['title']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.meetingData['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Date: ${widget.meetingData['date']}'),
            Text('Time: ${widget.meetingData['time']}'),
            Text('Location: ${widget.meetingData['location']}'),
            SizedBox(height: 16),
            Text('멤버 리스트',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: (widget.meetingData['members'] as List).map((member) {
                  return ListTile(title: Text(member));
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isJoined ? null : joinMeeting,
              child: Text(isJoined ? '참여 완료' : '참여하기'),
            ),
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
                      backgroundImage: NetworkImage(meeting['imageUrl']),
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
                          Text(
                            '${meeting['date']}\n ${meeting['location']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
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

class CreateMeetingPage extends StatefulWidget {
  @override
  _CreateMeetingPageState createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _type = '단기';
  String _imageUrl = 'https://your-default-image-url.com/default.jpg';

  Future<void> createMeeting() async {
    DocumentReference docRef = await _firestore.collection('board').add({
      'title': _titleController.text,
      'date': _dateController.text,
      'time': _timeController.text,
      'location': _locationController.text,
      'type': _type,
      'imageUrl': _imageUrl,
      'members': [],
    });

    await docRef.update({'id': docRef.id});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('모임 만들기')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '모임 제목'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: '날짜'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: '시간'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '장소'),
            ),
            DropdownButton<String>(
              value: _type,
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
              items: <String>['단기', '장기'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createMeeting,
              child: Text('모임 만들기'),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meetingData['title'], style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(meetingData['date']),
            Text(meetingData['location']),
          ],
        ),
      ),
    );
  }
}
