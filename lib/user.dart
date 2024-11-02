import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  CurrentUser({required this.gender,required this.name,required this.email,required this.age, required this.status, required this.uid, required this.tag_index, required this.gonggang});

  final String uid;

  final String name;
  final String gender;
  final String email;
  final num age;
  final String status;

  // final List<String> joinedMeetings;
  // final List<String> joinedChats;
  
  // final String imageURL;
  final String tag_index;
  final bool gonggang;


  // final String schedule;
  // final List<dynamic> schedule;
  // final dynamic schedule;

  // final Timestamp createdTime;
  // final Timestamp modifiedTime;

  // final List<String> friendList;
  // final List<String> groupList;
}