import 'package:cloud_firestore/cloud_firestore.dart'; // new
// import 'package:finalterm/home.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:location/location.dart';

import 'dart:async';

import 'firebase_options.dart';

import 'user.dart';




class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
    // initLocation();
    // uploadLocation();
  }
  Reference get firebasestorage => FirebaseStorage.instance.ref();

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  int requestCount = 0;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  final Location location = new Location();
  LocationData? _locationData;

  CurrentUser currentuser=
          CurrentUser(
            name: "Unknown",
            email:"Unknown",
            age: 0,
            dday: [{'date':'','option':true,'title':''},{'date':'','option':true,'title':''}],
            friendList: {},
            schedule: [],
            gender: "Unknown",
            status: "Unknown",
            uid: "Unknown",
            tag_index: "카공해요",
            gonggang: true,
          );
  // List<Product> _productList = [];
  // List<Product> get productList => _productList;

  // List<Product> wishlist = [];
  List<String> wishlistcheck=[];
  
  // uploadLocation() {
  // Timer.periodic(Duration(seconds:10),(timer) async {
  //   if (_locationData != null){
  //     debugPrint('${_locationData!.latitude} / ${_locationData!.longitude}');
  //     await FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser?.uid).update(<String, dynamic>{
  //       'location': [_locationData!.latitude,_locationData!.longitude],
  //     });
  //   }
  // });
  // }

  // initLocation() async {
  //   bool _serviceEnabled;
  //   PermissionStatus _permissionGranted;

  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }

  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   location.onLocationChanged.listen((LocationData currentLocation){
  //     _locationData=currentLocation;
  //   });
  // }

  Future<void> init() async {

    // print('init() Start');
    // FirebaseFirestore.instance
    //     .collection('user')
    //     .snapshots()
    //     .listen((snapshot) {
    //   // _attendees = snapshot.docs.length;
    //   notifyListeners();
    // });
    // print('notify listener Start');
    // final uid = FirebaseAuth.instance.currentUser!.uid;
    // print(uid);
    
    // DocumentSnapshot? userDoc = await FirebaseFirestore.instance
    //   .collection('user')
    //   .doc(uid)
    //   .get();
    // print(userDoc.exists);

    // notifyListeners();
    // print(userDoc);

    // print('userDoc finish');
    // final data = userDoc.data() as Map<String, dynamic>;
    // print('data finish');
    // notifyListeners();
    // currentuser=CurrentUser(
    //   name: data['name'] as String,
    //   email: data['email'] as String,
    //   age: data['age'] as num,
    //   gender: data['gender'] as String,
    //   status: data['status'] as String,
    //   uid: data['uid'] as String,
    //   tag_index: data['tag_index'] as String,
    //   gonggang: data['gonggang'] as bool
    // );
    // print('initialize Finished!');

    _userSubscription = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .listen((snapshot) {
        print(snapshot.data()?['dday']);
        currentuser=
          CurrentUser(
            name: snapshot.data()?['name'] as String? ?? "Unknown",
            email: snapshot.data()?['email'] as String? ?? "Unknown",
            age: snapshot.data()?['age'] as num? ?? 0,
            dday: snapshot.data()?['dday'] as List<dynamic>? ?? [{'date':'','option':true,'title':''},{'date':'','option':true,'title':''}],
            friendList: snapshot.data()?['friendList'] as Map<dynamic,dynamic>? ?? {},
            schedule: snapshot.data()?['schedule'] as List<dynamic>? ?? [],
            gender: snapshot.data()?['gender'] as String? ?? "Unknown",
            status: snapshot.data()?['status'] as String? ?? "Unknown",
            uid: snapshot.data()?['uid'] as String? ?? "Unknown",
            tag_index: snapshot.data()?['tag_index'] as String? ?? "카공해요",
            gonggang: snapshot.data()?['gonggang'] as bool? ?? true,
          );
      // }
      notifyListeners();
    });
    print('subscribe finish!');


    FirebaseAuth.instance.userChanges().listen((user) async {
      // debugPrint(FirebaseAuth.instance.currentUser!.uid);
      if (user != null) {
        _loggedIn = true;
        _userSubscription = await FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots()
            .listen((snapshot) {
            // if (snapshot.data()?['name'] != null
            // && snapshot.data()?['gender'] != null
            // && snapshot.data()?['major'] != null
            // && snapshot.data()?['birth'] != null
            // && snapshot.data()?['status'] != null
            // && snapshot.data()?['uid'] != null
            // && snapshot.data()?['imageURL'] != null
            // && snapshot.data()?['tagCheck'] != null
            // && snapshot.data()?['isGonggang'] != null
            // && snapshot.data()?['schedule'] != null
            // && snapshot.data()?['friendsList'] != null
            // && snapshot.data()?['groupList'] != null){
              // currentuser=
              //   CurrentUser(
              //     name: snapshot.data()!['name'] as String,
              //     gender: snapshot.data()!['gender'] as String,
              //     major: snapshot.data()!['major'] as String,
              //     birth: snapshot.data()!['birth'] as String,
              //     status: snapshot.data()!['status'] as String,
              //     uid: snapshot.data()!['uid'] as String,
              //     imageURL: snapshot.data()!['imageURL'] as String,
              //     tagCheck: List.from(snapshot.data()!['tagCheck']),
              //     isGonggang: snapshot.data()!['isGonggang'] as bool,
              //     schedule: List.from(snapshot.data()!['schedule']),
              //     friendList: List.from(snapshot.data()!['friendsList']),
              //     groupList: List.from(snapshot.data()!['groupList'])
              //   );
            // }
          
          notifyListeners();
        });

        // _attendingSubscription = FirebaseFirestore.instance
        //     .collection('attendees')
        //     .doc(user.uid)
        //     .snapshots()
        //     .listen((snapshot) {
        //   if (snapshot.data() != null) {
        //     if (snapshot.data()!['attending'] as bool) {
        //       _attending = Attending.yes;
        //     } else {
        //       _attending = Attending.no;
        //     }
        //   } else {
        //     _attending = Attending.unknown;
        //   }
        //   notifyListeners();
        // });
      } else {
        _loggedIn = false;
        // _guestBookMessages = [];
        // _guestBookSubscription?.cancel();
        // _attendingSubscription?.cancel(); // new

      }
      notifyListeners();
    });
  }

  Future<void> requestFriend(String myid, String friendid, Map<String,bool> myfriends, Map<String,bool> friendsFriends) async {
    await FirebaseFirestore.instance.collection('user').doc(myid).update({
        'friendList': myfriends
    });
    await FirebaseFirestore.instance.collection('user').doc(friendid).update({
        'friendList': friendsFriends
    });
    notifyListeners();
  }

  Future<void> gonggangOnOff(bool value) async {
    await FirebaseFirestore.instance.collection('user').doc(currentuser!.uid).update({
      'gonggang': value, // 기본값
    });
  }

  Future<void> changeTag(String value) async {
    await FirebaseFirestore.instance.collection('user').doc(currentuser!.uid).update({
      'tag_index': value, // 기본값
    });
  }
  Future<void> changeStatus(String value) async {
    await FirebaseFirestore.instance.collection('user').doc(currentuser!.uid).update({
      'status': value, // 기본값
    });
  }
  Future<void> changeDDay(String title, String date, bool option, int index) async {
    var currentdday = currentuser.dday;
    currentdday[index]={'title':title,'date':date,'option':option};

    await FirebaseFirestore.instance.collection('user').doc(currentuser!.uid).update({
      'dday': currentdday, // 기본값
    });
  }
  Future<void> getFriendRequestCount() async {
    DocumentSnapshot? userDoc = await FirebaseFirestore.instance
      .collection('user')
      .doc(currentuser!.uid)
      .get();
    print(currentuser!.uid);
    print(userDoc.exists);
      
    Map<String, dynamic> friendList = userDoc.get('friendList');

    Iterable<dynamic> values = friendList.values;
    int count = 0;
    for (var value in values){
      print(value);
      if (value == false){
        count++;
      }
    }
    requestCount = count;
  }
  
  Future<void> profileUpdate(String name, String major, String studentNumber, String status, List<dynamic> schedule) async {
    
    await FirebaseFirestore.instance.collection('user').doc(currentuser!.uid).update({
      // 'name': name, // 기본값
      'schedule': schedule,
      // 'status': status
    });
  }


  // Future<DocumentReference> addMessageToGuestBook(String message) {
  //   if (!_loggedIn) {
  //     throw Exception('Must be logged in');
  //   }

  //   return FirebaseFirestore.instance
  //       .collection('guestbook')
  //       .add(<String, dynamic>{
  //     'text': message,
  //     'timestamp': DateTime.now().millisecondsSinceEpoch,
  //     'name': FirebaseAuth.instance.currentUser!.displayName,
  //     'userId': FirebaseAuth.instance.currentUser!.uid,
  //   });
  // }
  
  // Future<void> deleteMessageToGuestBook(String docId) {
  //   if (!_loggedIn) {
  //     throw Exception('Must be logged in');
  //   }
  //   return FirebaseFirestore.instance
  //       .collection('guestbook')
  //       .doc(docId).delete();
  // }
  
  // Future<void> reordering()async {

  //   _productSubscription = FirebaseFirestore.instance
  //       .collection('product')
  //       .orderBy('price', descending: !asc)
  //       .snapshots()
  //       .listen((snapshot) {
  //     _productList = [];
  //     for (final document in snapshot.docs) {
  //       if (document.data()['name'] != null
  //       && document.data()['price'] != null
  //       && document.data()['url'] != null
  //       && document.data()['description'] != null
  //       && document.data()['uid'] != null
  //       && document.data()['created_time'] != null
  //       && document.data()['modified_time'] != null){
  //         _productList.add(
  //           Product(
  //             name: document.data()['name'] as String,
  //             price: document.data()['price'] as num,
  //             imageURL: document.data()['url'] as String,
  //             description: document.data()['description'] as String,
  //             docId: document.id,
  //             uid: document.data()['uid'] as String,
  //             createdTime: document.data()['created_time'] as Timestamp,
  //             modifiedTime: document.data()['modified_time'] as Timestamp,
  //             likeList: List.from(document.data()['likeList'])
  //           ),
  //         );
  //       }
  //     }
  //     notifyListeners();
  //   });
  // }
}
