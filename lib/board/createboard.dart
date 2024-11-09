import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_calendar/table_calendar.dart';

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
  String _imageUrl = '';

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      await _uploadImageToStorage(); // 이미지를 선택한 후에 업로드 및 URL 업데이트
    }
  }

  Future<void> _uploadImageToStorage() async {
    if (_selectedImage == null) return;

    try {
      final fileName =
          'meeting_images/${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      // Firebase Storage에 이미지 업로드
      await ref.putFile(_selectedImage!);

      // 업로드가 완료된 후 다운로드 URL 가져오기
      String downloadUrl = await ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading image to Firebase Storage: $e");
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
                      ? FileImage(_selectedImage!) // 선택된 이미지 표시
                      : (_imageUrl.isNotEmpty
                              ? NetworkImage(_imageUrl) // 업로드된 이미지 URL 표시
                              : NetworkImage(
                                  'https://your-default-image-url.com/default.jpg'))
                          as ImageProvider,
                  child: _selectedImage == null && _imageUrl.isEmpty
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
                      imageUrl: _imageUrl.isNotEmpty ? _imageUrl : '',
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
