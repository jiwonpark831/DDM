import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import 'package:provider/provider.dart';
import 'package:time_scheduler_table/time_scheduler_table.dart';
import 'package:flutter/services.dart';


class FriendProfilePage extends StatefulWidget {
  final String frienduid;

  const FriendProfilePage({super.key, required this.frienduid});

  @override
  _FriendProfilePageState createState() => _FriendProfilePageState(frienduid: frienduid);
}

class _FriendProfilePageState extends State<FriendProfilePage> {


  final String frienduid;



  _FriendProfilePageState({required this.frienduid});
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('user')
          .doc(frienduid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        else {
          var userData= snapshot.data!;
          return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("친구 정보"),
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
                            NetworkImage(userData['imageURL']),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text("이름  ${userData['name']}",
                            style: TextStyle(fontSize: 18)),
                        Text("전공  ${userData['major']}",
                            style: TextStyle(fontSize: 18)),
                        Text("학번  ${userData['year']}",
                            style: TextStyle(fontSize: 18)),
                        Text("소개  ${userData['status']}",
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: _TimetablePreview(userData['schedule']),
                ),
              ],
            ),
          ),
        );}
      }
    );
  }
  
}
