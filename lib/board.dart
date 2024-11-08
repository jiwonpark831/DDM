import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
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
            SizedBox(height: 32),
            Text('모임 게시판',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
    _tabController = TabController(length: 2, vsync: this);
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
            if (isJoined && widget.meetingData['type'] == '장기') ...[
              SizedBox(height: 20),
              _tabController == null
                  ? CircularProgressIndicator()
                  : TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: '공유 캘린더'),
                        Tab(text: '게시판'),
                      ],
                    ),
              Expanded(
                child: _tabController == null
                    ? Container()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          SharedCalendarPage(
                              meetingId: widget.meetingData['id']),
                          SharedBoardPage(meetingId: widget.meetingData['id']),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Define SharedCalendarPage and SharedBoardPage classes as before

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

class SharedCalendarPage extends StatefulWidget {
  final String meetingId;

  SharedCalendarPage({required this.meetingId});

  @override
  _SharedCalendarPageState createState() => _SharedCalendarPageState();
}

class _SharedCalendarPageState extends State<SharedCalendarPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _events = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    DocumentSnapshot doc =
        await _firestore.collection('board').doc(widget.meetingId).get();
    setState(() {
      _events = List<Map<String, dynamic>>.from(doc['calendarEvents'] ?? []);
    });
  }

  Future<void> addEvent(String title, DateTime date) async {
    Map<String, dynamic> newEvent = {
      'title': title,
      'date': date.toIso8601String().split('T').first,
    };

    await _firestore.collection('board').doc(widget.meetingId).update({
      'calendarEvents': FieldValue.arrayUnion([newEvent]),
    });
    fetchEvents();
  }

  void _showAddEventDialog() {
    final _titleController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일정 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "일정 제목"),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text("날짜: ${selectedDate.toLocal()}".split(' ')[0]),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  await addEvent(_titleController.text, selectedDate);
                  Navigator.pop(context);
                }
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return _events
                .where((event) =>
                    event['date'] == day.toIso8601String().split('T').first)
                .toList();
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showAddEventDialog,
          child: Text("일정 추가"),
        ),
        Expanded(
          child: ListView(
            children: _events.map((event) {
              return ListTile(
                title: Text(event['title']),
                subtitle: Text("날짜: ${event['date']}"),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SharedBoardPage extends StatefulWidget {
  final String meetingId;

  SharedBoardPage({required this.meetingId});

  @override
  _SharedBoardPageState createState() => _SharedBoardPageState();
}

class _SharedBoardPageState extends State<SharedBoardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _posts = [];
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    DocumentSnapshot doc =
        await _firestore.collection('board').doc(widget.meetingId).get();
    setState(() {
      _posts = List<Map<String, dynamic>>.from(doc['boardPosts'] ?? []);
    });
  }

  Future<void> addPost(String content) async {
    Map<String, dynamic> newPost = {
      'content': content,
      'timestamp': Timestamp.now(),
    };
    await _firestore.collection('board').doc(widget.meetingId).update({
      'boardPosts': FieldValue.arrayUnion([newPost]),
    });
    fetchPosts();
    _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              var post = _posts[index];
              return ListTile(
                title: Text(post['content']),
                subtitle: Text(post['timestamp'].toDate().toString()),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _postController,
            decoration: InputDecoration(
              labelText: '새 게시물 작성',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => addPost(_postController.text),
              ),
            ),
          ),
        ),
      ],
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

class EnterMeetingDetailsPage extends StatefulWidget {
  final String type;

  EnterMeetingDetailsPage({required this.type});

  @override
  _EnterMeetingDetailsPageState createState() =>
      _EnterMeetingDetailsPageState();
}

class _EnterMeetingDetailsPageState extends State<EnterMeetingDetailsPage> {
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _defaultImageUrl = 'https://your-default-image-url.com/default.jpg';

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("모임 정보 입력")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : NetworkImage(_defaultImageUrl) as ImageProvider,
                  child: _selectedImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : null,
                ),
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
                      type: widget.type,
                      title: _titleController.text,
                      imageUrl: _selectedImage?.path ?? _defaultImageUrl,
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
