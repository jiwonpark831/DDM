import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';

class SignupPage extends StatelessWidget {
  // TextEditingController 생성
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("이메일로 시작하기"),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController, // 이름 TextField에 컨트롤러 연결
              decoration: InputDecoration(
                labelText: "이름",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: emailController, // 이메일 TextField에 컨트롤러 연결
              decoration: InputDecoration(
                labelText: "이메일(email@example.com)",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: passwordController, // 비밀번호 TextField에 컨트롤러 연결
              obscureText: true,
              decoration: InputDecoration(
                labelText: "비밀번호",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            TextField(
              controller:
                  confirmPasswordController, // 비밀번호 확인 TextField에 컨트롤러 연결
              obscureText: true,
              decoration: InputDecoration(
                labelText: "비밀번호 확인",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 버튼 클릭 시 각 TextField의 값 가져오기
                String name = nameController.text;
                String email = emailController.text;
                String password = passwordController.text;
                String confirmPassword = confirmPasswordController.text;

                // 예시: 입력된 값 출력
                print("Name: $name");
                print("Email: $email");
                print("Password: $password");
                print("Confirm Password: $confirmPassword");

                // 비밀번호 일치 여부 확인
                if (password != confirmPassword) {
                  // 비밀번호가 일치하지 않으면 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
                  );
                }

                try {
                  // Firebase Auth를 사용하여 계정 생성
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // 계정 생성 성공
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("계정이 성공적으로 생성되었습니다.")),
                  );

                  Navigator.pop(context);

                  // 사용자 추가 로직, 예: Firestore에 추가 사용자 정보 저장
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                } on FirebaseAuthException catch (e) {
                  // 계정 생성 중 오류 처리
                  String message = "계정 생성 중 오류가 발생했습니다.";
                  if (e.code == 'email-already-in-use') {
                    message = "이미 사용 중인 이메일입니다.";
                  } else if (e.code == 'weak-password') {
                    message = "비밀번호가 너무 짧습니다. (비밀번호 6자 이상)";
                  } else if (e.code == 'invalid-email') {
                    message = "유효하지 않은 이메일 형식입니다.";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              child: Text(
                "계정 만들기",
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColor.primary,
                minimumSize: Size(double.infinity, 50), // 버튼이 가로로 꽉 차도록 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
