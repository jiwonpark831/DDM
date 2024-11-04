import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginUser(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      // Firebase Auth를 사용하여 이메일로 로그인
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Step 5. Firestore에 사용자 기본 정보가 있는지 확인
        final userDoc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

        if (!userDoc.exists) {
          // Step 6. 새 사용자일 경우 Firestore에 기본값 저장
          await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'Unknown',
            'email': user.email ?? 'Unknown',
            'age': 0, // 기본값
            'gender': 'unknown', // 기본값
            'dday': [{'date':'','option':true,'title':''},{'date':'','option':true,'title':''}],
            'friendList': {},
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
      }



      

      // 로그인 성공 시 홈 페이지로 이동 (예: Navigator.pushReplacement)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인에 성공했습니다.")),
      );

      // 예: 로그인 후 이동할 페이지로의 네비게이션
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homePage()),
      );

    } on FirebaseAuthException catch (e) {
      // 로그인 오류 처리
      String message = "로그인에 실패했습니다.";
      if (e.code == 'user-not-found') {
        message = "사용자가 존재하지 않습니다.";
      } else if (e.code == 'wrong-password') {
        message = "비밀번호가 올바르지 않습니다.";
      } else if (e.code == 'invalid-email') {
        message = "유효하지 않은 이메일 형식입니다.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인하기"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "이메일(email@example.com)",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "비밀번호",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _loginUser(context);
              },
              child: Text("로그인하기"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.green[200],
                minimumSize: Size(double.infinity, 50), // 버튼이 가로로 꽉 차도록 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
