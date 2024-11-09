import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddm/board/board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chat/chat.dart';
import 'friend/friend.dart';
import 'map.dart';

import 'setting.dart';
import 'notification.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'dday_edit.dart';

import 'profile.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    boardPage(),
    friendPage(),
    mainPage(),
    mapPage(),
    chatPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xff64DCAC),
        unselectedItemColor: Color(0xff1C1B1F),
        selectedLabelStyle: TextStyle(color: Color(0xff64DCAC)),
        unselectedLabelStyle: TextStyle(color: Color(0xff1C1B1F)),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list_alt,
            ),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '위치',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final List<String> statusOptions = ['카공해요', '밥 먹어요', '편의점 가요', '한한 해요'];
  Text makeDDay(String title, String date, bool option) {
    if (title.isEmpty || date.isEmpty) {
      return Text('X', style: TextStyle(color: Colors.black));
    }
    var difference =
        DateFormat("yyyy.MM.dd").parse(date).difference(DateTime.now()).inDays;
    if (difference > 0) {
      difference++;
      return Text('D-$difference', style: TextStyle(color: Colors.red));
    } else if (difference == 0) {
      return Text('D-Day', style: TextStyle(color: Colors.black));
    } else {
      difference = -difference;
      return Text('D+$difference', style: TextStyle(color: Colors.blue));
    }
  }

  Map<String, bool> friends = {};
  List<Map<String, String>> friendsNameStatus = [];

  @override
  void initState() {
    super.initState();
    getfriendList();
  }

  getfriendList() async {
    friends = {};
    friendsNameStatus = [];
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.data() != null && doc.get('friendList') != null) {
      friends = Map<String, bool>.from(doc.get('friendList'));
    }

    for (var entry in friends.entries) {
      String key = entry.key;
      bool value = entry.value;
      if (value) {
        var friend =
            await FirebaseFirestore.instance.collection('user').doc(key).get();
        if (friend.get('friendList')[FirebaseAuth.instance.currentUser!.uid] &&
            friend.get('gonggang')) {
          friendsNameStatus.add({
            'name': friend.get('name'),
            'status': friend.get('status'),
            'uid': friend.get('uid'),
            'imageURL': friend.get('imageURL')
          });
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      String selectedStatus =
          appState.currentuser!.tag_index; // Default dropdown value
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Image.asset(
            'assets/ddm_image.png', // Replace with your actual asset path
            width: 100,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                // Settings button action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                // Settings button action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
          leading: SizedBox(), // Placeholder to center the title
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 종강 카드
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => EditPage(title: "종강")),
                        // );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              appState.currentuser.dday[0]['title'].isEmpty
                                  ? 'X'
                                  : appState.currentuser.dday[0]['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            makeDDay(
                                appState.currentuser.dday[0]['title'],
                                appState.currentuser.dday[0]['date'],
                                appState.currentuser.dday[0]['option'])
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // 간격
                    // 2학기 카드
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => EditPage(title: "2학기")),
                        // );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              appState.currentuser.dday[1]['title'].isEmpty
                                  ? 'X'
                                  : appState.currentuser.dday[1]['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            makeDDay(
                                appState.currentuser.dday[1]['title'],
                                appState.currentuser.dday[1]['date'],
                                appState.currentuser.dday[1]['option'])
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // 간격
                    // 수정 버튼
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DDaySettingsPage()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.chevron_right),
                      ),
                    ),
                  ],
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Text('종강', style: TextStyle(fontSize: 18)),
              //     Text('D-65', style: TextStyle(fontSize: 18, color: Colors.red)),
              //     Text('2학기', style: TextStyle(fontSize: 18)),
              //     Text('D+16', style: TextStyle(fontSize: 18, color: Colors.blue)),
              //   ],
              // ),

              SizedBox(height: 20),
              SizedBox(height: 10),

              // Row(children: [
              //   Icon(Icons.people),
              //   Column(children: [
              //     Text(
              //       appState.currentuser.name,
              //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     ),
              //     SizedBox(height: 10),
              //     Text(
              //       appState.currentuser!.status,
              //       style: TextStyle(fontSize: 16),
              //     ),
              //   ],)
              // ],),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 프로필 이미지
                  Column(
                    children: [
                      GestureDetector(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyProfilePage()),
                          );
                        }),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 70,
                          child: Image.network(
                            // default image
                            appState.currentuser.imageURL,
                            width: 200,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // 이름
                      Text(
                        appState.currentuser.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                  SizedBox(width: 20), // 이미지와 텍스트 간 간격
                  // 이름과 상태 메시지를 세로로 정렬
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상태 메시지

                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.green[50], // 말풍선 배경색
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(children: [
                            Text(
                              appState.currentuser.status,
                              style: TextStyle(fontSize: 15),
                            ),
                            TextButton(
                                child: Text('편집'),
                                onPressed: (() {
                                  TextEditingController _controller =
                                      TextEditingController(
                                          text: appState.currentuser.status);
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Edit Status Message"),
                                        content: TextField(
                                          controller: _controller,
                                          decoration: InputDecoration(
                                            hintText:
                                                "Enter your status message",
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                appState.changeStatus(
                                                    _controller
                                                        .text); // 상태 메시지 업데이트
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Save"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }))
                          ])),

                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('공강', style: TextStyle(fontSize: 16)),
                          Switch(
                            value: appState.currentuser!.gonggang,
                            onChanged: (value) {
                              appState.gonggangOnOff(value);
                              setState(() {});
                            },
                            activeColor: Colors.greenAccent,
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedStatus,
                            icon: Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {
                              appState.changeTag(newValue as String);
                              setState(() {});
                            },
                            items: statusOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    Text(value),
                                    SizedBox(width: 8),
                                    Icon(
                                      _getStatusIcon(value),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Text(
              //   appState.currentuser.name,
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 10),
              // Text(
              //   appState.currentuser!.status,
              //   style: TextStyle(fontSize: 16),
              // ),

              SizedBox(height: 20),
              SizedBox(height: 20),
              Text(
                '현재 친구의 공강 상태를 확인하세요!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),

              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: (() {
                      return List.generate(friendsNameStatus.length, (index) {
                        return Container(
                            width: 80,
                            height: 80,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: (() {
                                    debugPrint(
                                        friendsNameStatus[index]['imageURL']);
                                    debugPrint(
                                        friendsNameStatus[index]['name']);
                                    debugPrint(
                                        friendsNameStatus[index]['status']);
                                    debugPrint(friendsNameStatus[index]['uid']);
                                  }),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                        friendsNameStatus[index]['imageURL']
                                            as String),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(friendsNameStatus[index]['name'] as String)
                              ],
                            ));
                      });
                    })(),
                  )),

              SizedBox(height: 20),
              Text(
                '내 친구들이 모인 게시판을 확인하세요!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '카공해요':
        return Icons.book;
      case '밥 먹어요':
        return Icons.restaurant;
      case '편의점 가요':
        return Icons.local_convenience_store;
      case '한한 해요':
        return Icons.directions_walk;
      default:
        return Icons.help;
    }
  }
}
