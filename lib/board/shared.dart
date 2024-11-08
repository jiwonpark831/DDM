import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

  void _showEventsDialog(List<Map<String, dynamic>> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일정 목록"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) {
              return ListTile(
                title: Text(event['title']),
                subtitle: Text("날짜: ${event['date']}"),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("닫기"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              List<Map<String, dynamic>> selectedEvents = _events
                  .where((event) =>
                      event['date'] ==
                      selectedDay.toIso8601String().split('T').first)
                  .toList();
              if (selectedEvents.isNotEmpty) {
                _showEventsDialog(selectedEvents);
              }
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
        ],
      ),
    );
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
  final String? userId = FirebaseAuth.instance.currentUser?.displayName;

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
      'author': userId ?? 'Anonymous',
      'timestamp': Timestamp.now(),
    };
    await _firestore.collection('board').doc(widget.meetingId).update({
      'boardPosts': FieldValue.arrayUnion([newPost]),
    });
    fetchPosts();
  }

  void _showAddPostDialog() {
    final TextEditingController _postController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("새 게시물 작성"),
          content: TextField(
            controller: _postController,
            decoration: InputDecoration(labelText: "내용을 입력하세요"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                if (_postController.text.isNotEmpty) {
                  await addPost(_postController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("작성"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                var post = _posts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['author'] ?? 'Anonymous',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(post['content']),
                        SizedBox(height: 5),
                        Text(
                          post['timestamp'].toDate().toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: Icon(Icons.add),
        tooltip: '새 게시물 작성',
      ),
    );
  }
}

class SharedBoardPage2 extends StatefulWidget {
  final String meetingId;

  SharedBoardPage2({required this.meetingId});

  @override
  _SharedBoardPage2State createState() => _SharedBoardPage2State();
}

class _SharedBoardPage2State extends State<SharedBoardPage2> {
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
