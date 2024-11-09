import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import 'package:provider/provider.dart';
import 'package:time_scheduler_table/time_scheduler_table.dart';
import 'package:flutter/services.dart';

import '../theme/color.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // 예제 데이터

  // 편집 페이지로 이동
  // void _goToEditPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditProfilePage(
  //         name: name,
  //         major: major,
  //         year: year,
  //         intro: intro,
  //         imageUrl: imageUrl,
  //         onSave: (newName, newMajor, newYear, newIntro, newImageUrl) {
  //           setState(() {
  //             name = newName;
  //             major = newMajor;
  //             year = newYear;
  //             intro = newIntro;
  //             imageUrl = newImageUrl;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _TimetablePreview(List<dynamic> schedule) {
    List<Event> eventList = [];
    schedule.forEach((element) {
      eventList.add(Event(
        title: element['content'],
        columnIndex: element['time']['column'],
        rowIndex: element['time']['row'],
        color: Color(element['color']),
      ));
      print(element['content']);
      print(element['color']);
      print(element['time']['column']);
      print(element['time']['row']);
    });
    return AbsorbPointer(
        absorbing: true,
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            // width: 400,
            // height: 500,
            // constraints: BoxConstraints(maxWidth:MediaQuery.of(context).size.width),
            child: Column(children: [
              TimeSchedulerTable(
                cellHeight: 40,
                cellWidth: 56,
                columnLabels: const ["Mon", "Tue", "Wed", "Thur", "Fri"],
                rowLabels: const [
                  '1교시',
                  '2교시',
                  '3교시',
                  '4교시',
                  '5교시',
                  '6교시',
                  '7교시',
                  '8교시',
                  '9교시',
                  '10교시',
                ],
                eventList: eventList,
                // isBack: false,
                eventAlert: EventAlert(
                  addAlertTitle: "Add Event",
                  editAlertTitle: "Edit",
                  addButtonTitle: "ADD",
                  deleteButtonTitle: "DELETE",
                  updateButtonTitle: "UPDATE",
                  hintText: "Event Name",
                  textFieldEmptyValidateMessage: "Cannot be empty!",
                  addOnPressed: (event) {
                    // when an event added to your list
                    // Your code after event added.
                    print('addOnPressed');
                  },
                  updateOnPressed: (event) {
                    // when an event updated from your list
                    // Your code after event updated.
                    print('updateOnPressed');
                  },
                  deleteOnPressed: (event) {
                    // when an event deleted from your list
                    // Your code after event deleted.
                    print('deleteOnPressed');
                  },
                ),
              ),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("내 정보"),
          actions: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: (() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                })),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage(appState.currentuser.imageURL),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text("이름  ${appState.currentuser.name}",
                          style: TextStyle(fontSize: 18)),
                      Text("전공  ${appState.currentuser.major}",
                          style: TextStyle(fontSize: 18)),
                      Text("학번  ${appState.currentuser.year}",
                          style: TextStyle(fontSize: 18)),
                      Text("소개  ${appState.currentuser.status}",
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 500,
                child: _TimetablePreview(appState.currentuser.schedule),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class EditProfilePage extends StatefulWidget {
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

  List<dynamic> userSchedule = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    Navigator.pop(context);
  }

  Widget _Timetable(List<dynamic> schedule) {
    List<Event> eventList = [];
    userSchedule = schedule;
    schedule.forEach((element) {
      eventList.add(Event(
        title: element['content'],
        columnIndex: element['time']['column'],
        rowIndex: element['time']['row'],
        color: Color(element['color']),
      ));
    });
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(children: [
          TimeSchedulerTable(
            cellHeight: 40,
            cellWidth: 56,
            columnLabels: const ["Mon", "Tue", "Wed", "Thur", "Fri"],
            rowLabels: const [
              '1교시',
              '2교시',
              '3교시',
              '4교시',
              '5교시',
              '6교시',
              '7교시',
              '8교시',
              '9교시',
              '10교시',
            ],
            eventList: eventList,
            // isBack: false,
            eventAlert: EventAlert(
              addAlertTitle: "Add Event",
              editAlertTitle: "Edit",
              addButtonTitle: "ADD",
              deleteButtonTitle: "DELETE",
              updateButtonTitle: "UPDATE",
              hintText: "Event Name",
              textFieldEmptyValidateMessage: "Cannot be empty!",
              addOnPressed: (event) {
                // when an event added to your list
                // Your code after event added.
                List<dynamic> tmp = [];
                eventList.forEach((cur_event) {
                  tmp.add({
                    'title': cur_event.title,
                    'content': cur_event.title,
                    'time': {
                      'column': cur_event.columnIndex,
                      'row': cur_event.rowIndex
                    },
                    'color': cur_event.color!.value
                  });
                  // print(tmp);
                });
                // setState((){
                userSchedule = tmp;
                print(userSchedule);
                // });
              },
              updateOnPressed: (event) {
                // when an event updated from your list
                // Your code after event updated.
                List<dynamic> tmp = [];
                eventList.forEach((cur_event) {
                  tmp.add({
                    'title': cur_event.title,
                    'content': cur_event.title,
                    'time': {
                      'column': cur_event.columnIndex,
                      'row': cur_event.rowIndex
                    },
                    'color': cur_event.color!.value
                  });
                });
                // setState((){
                userSchedule = tmp;
                print(userSchedule);
                // });
              },
              deleteOnPressed: (event) {
                // when an event deleted from your list
                // Your code after event deleted.
                List<dynamic> tmp = [];
                eventList.forEach((cur_event) {
                  tmp.add({
                    'title': cur_event.title,
                    'content': cur_event.title,
                    'time': {
                      'column': cur_event.columnIndex,
                      'row': cur_event.rowIndex
                    },
                    'color': cur_event.color!.value
                  });
                });
                // setState((){
                userSchedule = tmp;
                print(userSchedule);
                // });
              },
            ),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      // print(appState.currentuser.schedule);
      nameController.text = appState.currentuser.name;
      majorController.text = appState.currentuser.major;
      yearController.text = appState.currentuser.year.toString();
      introController.text = appState.currentuser.status;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("내 정보"),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          // actions: [
          //   IconButton(
          //       icon: Icon(Icons.save),
          //       onPressed: (() {
          //         appState.profileUpdate(
          //             nameController.text,
          //             majorController.text,
          //             yearController.text,
          //             introController.text,
          //             userSchedule);
          //         print(_imageUrl);
          //         if (_imageUrl != null) {
          //           appState.profileImage(_imageUrl as String);
          //         }
          //         Navigator.pop(context);
          //       })),
          // ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (() async {
                  var pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                      _imageUrl = pickedFile.path;
                    });
                  }
                  print(pickedFile!.path);
                }),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : NetworkImage(appState.currentuser.imageURL)
                          as ImageProvider,
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
              SizedBox(
                height: 500,
                child: _Timetable(appState.currentuser.schedule),
              ),
              SizedBox(height: 20),
              Container(
                width: 350,
                height: 60,
                child: ElevatedButton(
                  onPressed: (() {
                    appState.profileUpdate(
                        nameController.text,
                        majorController.text,
                        yearController.text,
                        introController.text,
                        userSchedule);
                    print(_imageUrl);
                    if (_imageUrl != null) {
                      appState.profileImage(_imageUrl as String);
                    }
                    Navigator.pop(context);
                  }),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary, elevation: 0),
                  child: Text(
                    "완료",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      );
    });
  }
}
