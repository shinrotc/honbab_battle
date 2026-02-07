import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // [핵심] 2초 뒤에 로그인 화면으로 이동!
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        // 아래에서 위로 올라오는 애니메이션 적용 (승규의 기존 컨셉 유지!)
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.0, 1.0); // 아래에서
            var end = Offset.zero; // 제자리로
            var curve = Curves.easeOutQuart;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 혼밥대전의 메인 테마색인 주황색 배경
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 아이콘
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant, color: Colors.orange, size: 60),
            ),
            const SizedBox(height: 24),
            // 앱 이름
            const Text(
              "혼밥대전",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "자취생들의 리얼 요리 배틀",
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}