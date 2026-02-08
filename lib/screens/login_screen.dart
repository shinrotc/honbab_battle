import 'package:flutter/material.dart';
import 'main_screen.dart'; // 메인 화면 연결

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // [1] 배경 이미지
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
              fit: BoxFit.cover,
            ),
          ),
          // [2] 배경 그라데이션
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha:0.9),
                  ],
                ),
              ),
            ),
          ),
          // [3] 내용물 (애니메이션 적용)
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // ✨ 로고와 텍스트
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      children: [
                        // [수정 1] 아이콘 박스
                        Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // [색상 변경] 더 진한 오렌지색 (orange[800])
                            color: Colors.orange[800], 
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // 반투명 링 효과
                              BoxShadow(
                                color: Colors.white.withValues(alpha:0.3),
                                blurRadius: 0,
                                spreadRadius: 6,
                                offset: const Offset(0, 0),
                              ),
                              // 그림자
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          // [크기 변경] 아이콘 사이즈 45 -> 52 (더 꽉 차게!)
                          child: const Icon(Icons.restaurant_rounded, color: Colors.white, size: 52),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // "혼밥대전" 텍스트
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.0,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))],
                            ),
                            children: [
                              const TextSpan(text: "혼밥"),
                              // [색상 변경] 텍스트도 똑같이 진한 오렌지색으로 통일
                              TextSpan(text: "대전", style: TextStyle(color: Colors.orange[800])),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "자취생을 위한 초간단 요리 서바이벌",
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),
                
                // [4] 하단 버튼 영역
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, -10))],
                    ),
                    child: Column(
                      children: [
                        const Text("환영합니다! 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("오늘의 한 끼, 더 이상 고민하지 마세요.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 30),
                        
                        _buildLoginButton(
                          text: "카카오로 3초 만에 시작하기",
                          icon: Icons.chat_bubble,
                          color: const Color(0xFFFEE500),
                          textColor: const Color(0xFF3C1E1E),
                          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildLoginButton(
                          text: "Google로 계속하기",
                          icon: Icons.g_mobiledata,
                          color: Colors.white,
                          textColor: Colors.black87,
                          hasBorder: true,
                          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen())),
                        ),
                        const SizedBox(height: 20),
                         Text.rich(
                          TextSpan(
                            text: "계속 진행하면 ",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            children: const [
                              TextSpan(text: "이용약관", style: TextStyle(decoration: TextDecoration.underline)),
                              TextSpan(text: " 및 "),
                              TextSpan(text: "개인정보처리방침", style: TextStyle(decoration: TextDecoration.underline)),
                              TextSpan(text: "에\n동의하는 것으로 간주합니다."),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: hasBorder ? const BorderSide(color: Color(0xFFE5E7EB)) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}