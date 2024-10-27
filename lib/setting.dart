import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationEnabled = true;
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey),
            title: Text('내 정보', style: TextStyle(fontSize: 16)),
            onTap: () {
              // Navigate to profile page
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.grey),
            title: Text('계정', style: TextStyle(fontSize: 16)),
            onTap: () {
              // Navigate to account settings
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.grey),
            title: Text('알림 설정', style: TextStyle(fontSize: 16)),
            trailing: Switch(
              value: isNotificationEnabled,
              activeColor: Colors.greenAccent,
              onChanged: (bool value) {
                setState(() {
                  isNotificationEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode, color: Colors.grey),
            title: Text('다크모드', style: TextStyle(fontSize: 16)),
            trailing: Switch(
              value: isDarkModeEnabled,
              activeColor: Colors.greenAccent,
              onChanged: (bool value) {
                setState(() {
                  isDarkModeEnabled = value;
                });
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bookmark, color: Colors.grey),
            title: Text('이용안내', style: TextStyle(fontSize: 16)),
            onTap: () {
              // Navigate to guide page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey),
            title: Text('로그아웃', style: TextStyle(fontSize: 16)),
            onTap: () {
              // Handle logout
            },
          ),
          SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                // Handle account deletion
              },
              child: Text(
                '회원탈퇴',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
