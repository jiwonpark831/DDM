import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home.dart';
import '../theme/color.dart';
import 'login.dart';
import 'signup.dart';

Future signInWithGoogle_original() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    return null;
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  // Step 4. Firebase 로그인 실행
  final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
  final User? user = userCredential.user;

  if (user != null) {
    // Step 5. Firestore에 사용자 기본 정보가 있는지 확인
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

    if (!userDoc.exists) {
      // Step 6. 새 사용자일 경우 Firestore에 기본값 저장
      await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '(미입력)',
        'location': {'lat':36.103945,'lng':129.387546},
        'imageURL':
            "https://firebasestorage.googleapis.com/v0/b/ddm-project-32430.appspot.com/o/default.png?alt=media&token=2a5eb741-f462-404e-a3b1-b57d9c564e86",
        'email': user.email ?? '(미입력)',
        'year': "0", // 기본값
        'major': "(미입력)",
        'friendList': {},
        'dday': [
          {'date': '', 'option': true, 'title': ''},
          {'date': '', 'option': true, 'title': ''}
        ],
        'joinedMeetings': [], // 기본값
        'joinedChats': [], // 기본값
        'gonggang': true, // 기본값
        'tag_index': "카공해요",
        'status': "같이 밥 먹을 사람~",
        'createdAt': FieldValue.serverTimestamp(), // 생성 시간 기록
      });
      print("새 사용자 정보가 Firestore에 저장되었습니다.");
    } else {
      print("기존 사용자입니다.");
    }

    return user;
  }

  return null;
}

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // 사용자가 로그인 취소 시

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homePage()),
    );
  } catch (e) {
    print('Google Sign-In Error: $e');
  }
}

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
          AnimatedPositioned(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: _showLogin ? 100 : MediaQuery.of(context).size.height / 2 - 50,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/ddm_image.png',
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
                        onPressed: () async {
                          // Google login action
                          await signInWithGoogle_original();
                          print("Done");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => homePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        icon: Icon(Icons.g_mobiledata, size: 24),
                        label: Text(
                          '구글 계정으로 시작하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 16),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     // Apple login action
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => homePage()),
                      //     );
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.black,
                      //     minimumSize: Size(double.infinity, 50),
                      //   ),
                      //   icon: Icon(Icons.apple, size: 24),
                      //   label: Text('애플 계정으로 시작하기'),
                      // ),
                      // SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Email login action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          minimumSize: Size(double.infinity, 50),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.email, color: Colors.white),
                        label: Text(
                          '이메일로 시작하기',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Existing account action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                        child: Text(
                          '이메일로 만든 계정이 없으신가요?',
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
