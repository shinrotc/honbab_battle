import 'package:flutter/material.dart';
import 'notification_screen.dart'; // 알림 화면
import 'sub_pages.dart'; // 서브 페이지 (UniversalListScreen, CustomerServiceScreen 포함)
import 'login_screen.dart'; // 로그아웃 시 이동할 화면

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // [1] 상단 앱바
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("마이 프로필", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // [2] 본문
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 2-1. 프로필 섹션 (사진 + 이름 + 자기소개)
            _buildProfileSection(context),

            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

            // 2-2. 메뉴 리스트 (연결 경로 복구 완료!)
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  // 프로필 디자인: 블랙 & 주황 포인트
  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        // 프로필 이미지
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage("https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=200"),
          ),
        ),
        const SizedBox(height: 16),
        
        // 닉네임
        const Text(
          "자취9단 승규",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)), // 블랙 포인트
        ),
        const SizedBox(height: 12),

        // [중요] 자기소개 공간
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "\"한 번 먹어보면 대부분 만듭니다. 가성비와 맛을 모두 잡는 자취 요리 연구가입니다!\" 🍳",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 프로필 관리 버튼
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit, size: 14, color: Colors.orange),
          label: const Text("프로필 수정", style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // 메뉴 리스트: sub_pages.dart와 다시 연결!
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildListTile(context, Icons.description_outlined, "내가 쓴 레시피", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UniversalListScreen(title: "내가 쓴 레시피")));
        }),
        _buildListTile(context, Icons.favorite_border, "찜한 레시피", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UniversalListScreen(title: "찜한 레시피")));
        }),
        _buildListTile(context, Icons.headset_mic_outlined, "고객센터", () {
          // 끊겼던 고객센터 경로 연결!
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerServiceScreen()));
        }),
        const Divider(height: 20, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
        _buildListTile(context, Icons.logout, "로그아웃", () => _showLogoutDialog(context), isRed: true),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isRed ? Colors.red[50] : Colors.grey[50], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isRed ? Colors.red : Colors.black87, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isRed ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 로그아웃 다이얼로그
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              // 모든 화면 기록을 지우고 초기 로그인 화면으로 이동
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("로그아웃", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}