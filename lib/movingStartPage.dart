import 'package:flutter/material.dart';

import 'home.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StartPage(),
//     );
//   }
// }

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showLogin = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo Image
          AnimatedPositioned(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: _showLogin ? 100 : MediaQuery.of(context).size.height / 2 - 50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/ddm_image.png', // Replace with your actual asset path
                width: 100,
              ),
            ),
          ),
          // Login Options
          AnimatedOpacity(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            opacity: _showLogin ? 1 : 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Google login action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => homePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        icon: Icon(Icons.g_mobiledata, size: 24),
                        label: Text('구글 계정으로 시작하기'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Apple login action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => homePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        icon: Icon(Icons.apple, size: 24),
                        label: Text('애플 계정으로 시작하기'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Email login action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => homePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        icon: Icon(Icons.email, color: Colors.white),
                        label: Text('이메일로 시작하기'),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Existing account action
                        },
                        child: Text(
                          '이메일로 만든 계정이 있나요?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
