import 'package:ddm/board.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'friend.dart';
import 'map.dart';

import 'setting.dart';
import 'notification.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

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
  final List<String> statusOptions = [
    '카공해요',
    '밥 먹어요',
    '편의점 가요',
    '한한 해요'
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(builder: (context, appState, _) {
      String selectedStatus = appState.currentuser!.tag_index; // Default dropdown value
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
              icon: Icon(Icons.notifications , color: Colors.black),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('종강', style: TextStyle(fontSize: 18)),
                  Text('D-65', style: TextStyle(fontSize: 18, color: Colors.red)),
                  Text('2학기', style: TextStyle(fontSize: 18)),
                  Text('D+16', style: TextStyle(fontSize: 18, color: Colors.blue)),
                ],
              ),
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
                  Column(children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 70,
                      child: Image.network( // default image sdf
                        'https://firebasestorage.googleapis.com/v0/b/ddm-project-32430.appspot.com/o/default.png?alt=media&token=2a5eb741-f462-404e-a3b1-b57d9c564e86',
                        width: 200,
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
                  ],),
                  SizedBox(width: 20), // 이미지와 텍스트 간 간격
                  // 이름과 상태 메시지를 세로로 정렬
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상태 메시지
                    
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.green[50], // 말풍선 배경색
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: 
                      Row(
                        children:[
                          Text(
                            appState.currentuser.status,
                            style: TextStyle(fontSize: 15),
                          ),
                          TextButton(
                            child: Text('편집'),
                            onPressed:(() {
                              TextEditingController _controller = TextEditingController(text: appState.currentuser.status);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Edit Status Message"),
                                    content: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        hintText: "Enter your status message",
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
                                            appState.changeStatus(_controller.text); // 상태 메시지 업데이트
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            })
                          )
                      ])
                    ),
                      
                      

                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('공강', style: TextStyle(fontSize: 16)),
                          Switch(
                            value: appState.currentuser!.gonggang,
                            onChanged: (value) {
                              appState.gonggangOnOff(value);
                              setState((){});
                            },
                            activeColor: Colors.greenAccent,
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedStatus,
                            icon: Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {
                              appState.changeTag(newValue as String);
                              setState((){});
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 30),
                  CircleAvatar(radius: 30),
                  CircleAvatar(radius: 30),
                  CircleAvatar(radius: 30),
                  CircleAvatar(radius: 30),
                ],
              ),
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
      }
    );
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
