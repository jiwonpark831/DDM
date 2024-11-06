import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    checkIfJoined();
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

      // 참여한 모임 새로고침
      final boardPageState = context.findAncestorStateOfType<_boardPageState>();
      boardPageState?.fetchMeetings();
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meetingData['title'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('주최자: ${meetingData['organizer']}'),
            Text('날짜: ${meetingData['date']}'),
            Text('시간: ${meetingData['time']}'),
            Text('장소: ${meetingData['location']}'),
          ],
        ),
      ),
    );
  }
}

class CreateMeetingPage extends StatefulWidget {
  @override
  _CreateMeetingPageState createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  String _type = '단기';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("어떤 모임을 만들까요?"),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _type = '단기';
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterMeetingDetailsPage(type: _type),
                ),
              );
            },
            child: Text("단기모임"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _type = '장기';
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterMeetingDetailsPage(type: _type),
                ),
              );
            },
            child: Text("장기모임"),
          ),
        ],
      ),
    );
  }
}

class EnterMeetingDetailsPage extends StatelessWidget {
  final String type;
  final TextEditingController _titleController = TextEditingController();
  final String _imageUrl = 'https://your-default-image-url.com/default.jpg';

  EnterMeetingDetailsPage({required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("모임 정보 입력")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  // Logic to upload/select an image (this is a placeholder)
                },
                iconSize: 100,
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '모임 이름'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetMeetingDatePage(
                      type: type,
                      title: _titleController.text,
                      imageUrl: _imageUrl,
                    ),
                  ),
                );
              },
              child: Text("다음"),
            ),
          ],
        ),
      ),
    );
  }
}

class SetMeetingDatePage extends StatefulWidget {
  final String type;
  final String title;
  final String imageUrl;

  SetMeetingDatePage({
    required this.type,
    required this.title,
    required this.imageUrl,
  });

  @override
  _SetMeetingDatePageState createState() => _SetMeetingDatePageState();
}

class _SetMeetingDatePageState extends State<SetMeetingDatePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _locationController = TextEditingController();
  String _organizerName = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _fetchOrganizerName();
  }

  Future<void> _fetchOrganizerName() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(uid).get();
    setState(() {
      _organizerName = userDoc['name'] ?? '';
    });
  }

  Future<void> createMeeting() async {
    DocumentReference docRef = await _firestore.collection('board').add({
      'title': widget.title,
      'date': widget.type == '단기'
          ? _selectedDate.toIso8601String().split('T').first
          : _selectedDays.join(', '),
      'time':
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
      'location': _locationController.text,
      'organizer': _organizerName,
      'type': widget.type,
      'imageUrl': widget.imageUrl,
      'members': [],
    });

    await docRef.update({'id': docRef.id});
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _buildDateOrDaysSelector() {
    if (widget.type == '단기') {
      // Short-term: Calendar for date selection
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("날짜 선택", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
        ],
      );
    } else {
      // Long-term: Day selection with ChoiceChips
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("요일 선택", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
              return ChoiceChip(
                label: Text(day),
                selected: _selectedDays.contains(day),
                onSelected: (isSelected) {
                  setState(() {
                    isSelected
                        ? _selectedDays.add(day)
                        : _selectedDays.remove(day);
                  });
                },
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("시간 선택", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Row(
          children: [
            // Hour dropdown
            DropdownButton<int>(
              value: _selectedTime.hour,
              items: List.generate(24, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString().padLeft(2, '0')),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTime =
                        TimeOfDay(hour: value, minute: _selectedTime.minute);
                  });
                }
              },
            ),
            Text(" : "),
            // Minute dropdown
            DropdownButton<int>(
              value: _selectedTime.minute,
              items: List.generate(60, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString().padLeft(2, '0')),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTime =
                        TimeOfDay(hour: _selectedTime.hour, minute: value);
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("모임 날짜와 시간 설정")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("주최자: $_organizerName"),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: '장소'),
            ),
            SizedBox(height: 16),
            _buildDateOrDaysSelector(),
            SizedBox(height: 16),
            _buildTimeSelector(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createMeeting,
              child: Text("모임 만들기"),
            ),
          ],
        ),
      ),
    );
  }
}
