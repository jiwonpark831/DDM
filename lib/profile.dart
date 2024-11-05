import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // 예제 데이터
  String name = "000";
  String major = "전산전자공학부";
  String year = "23학번";
  String intro = "공강메이트 많다부 ~";
  String imageUrl = "https://via.placeholder.com/150";

  // 편집 페이지로 이동
  void _goToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: name,
          major: major,
          year: year,
          intro: intro,
          imageUrl: imageUrl,
          onSave: (newName, newMajor, newYear, newIntro, newImageUrl) {
            setState(() {
              name = newName;
              major = newMajor;
              year = newYear;
              intro = newIntro;
              imageUrl = newImageUrl;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 정보"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _goToEditPage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(imageUrl),
            ),
            SizedBox(height: 20),
            Text("이름: $name", style: TextStyle(fontSize: 18)),
            Text("전공: $major", style: TextStyle(fontSize: 18)),
            Text("학번: $year", style: TextStyle(fontSize: 18)),
            Text("소개: $intro", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text("소당곰님의 시간표"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String name;
  final String major;
  final String year;
  final String intro;
  final String imageUrl;
  final Function(String, String, String, String, String) onSave;

  EditProfilePage({
    required this.name,
    required this.major,
    required this.year,
    required this.intro,
    required this.imageUrl,
    required this.onSave,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController majorController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController introController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    majorController.text = widget.major;
    yearController.text = widget.year;
    introController.text = widget.intro;
    _imageUrl = widget.imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    widget.onSave(
      nameController.text,
      majorController.text,
      yearController.text,
      introController.text,
      _imageFile != null ? _imageFile!.path : _imageUrl!,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 정보 편집"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : NetworkImage(_imageUrl!) as ImageProvider,
                child: Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "이름"),
            ),
            TextField(
              controller: majorController,
              decoration: InputDecoration(labelText: "전공"),
            ),
            TextField(
              controller: yearController,
              decoration: InputDecoration(labelText: "학번"),
            ),
            TextField(
              controller: introController,
              decoration: InputDecoration(labelText: "소개"),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text("소당곰님의 시간표"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(foregroundColor: Colors.greenAccent),
              child: Text("완료"),
            ),
          ],
        ),
      ),
    );
  }
}
