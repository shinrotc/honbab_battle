import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // [추가] 마우스/터치 제스처 설정을 위해 필요!
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'screens/login_screen.dart';

void main() async {
  // 플러터 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 파이어베이스 연결
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HonbabApp());
}

class HonbabApp extends StatelessWidget {
  const HonbabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '혼밥대전',
      
      // [핵심 추가] 크롬(웹)에서도 마우스 드래그로 스와이프가 가능하게 만드는 설정
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch, // 터치스크린
          PointerDeviceKind.mouse, // 마우스 드래그 활성화!
          PointerDeviceKind.trackpad, // 트랙패드
        },
      ),

      theme: ThemeData(
        fontFamily: 'Pretendard',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        primaryColor: Colors.orange,
      ),
      
      // 앱의 첫 시작 화면은 로그인 화면으로 설정
      home: const LoginScreen(),
    );
  }
}