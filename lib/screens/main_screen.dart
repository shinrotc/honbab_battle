import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'search_screen.dart';
import 'mypage_screen.dart';
import 'write_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const RankingScreen(),
    const SearchScreen(),
    const MyPageScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // 🚀 [수정] 글쓰기 화면으로 갈 때 닉네임과 UID('my_profile')를 모두 챙겨갑니다.
  Future<void> _navigateToWrite() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .get();

      String latestNick = "자취9단승규";
      if (doc.exists && doc.data() != null) {
        latestNick = doc.data()!['nickname'] ?? "자취9단승규";
      }

      if (!mounted) return;
      
      // ✅ [핵심 수정] currentUid를 'my_profile'로 확실하게 함께 전달합니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WriteScreen(
            currentNickname: latestNick,
            currentUid: 'my_profile', // 👈 불변의 지문 UID 추가!
          ),
        ),
      );
    } catch (e) {
      debugPrint("닉네임 가져오기 실패: $e");
      if (!mounted) return;
      
      // ✅ 에러 시에도 UID를 함께 전달합니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WriteScreen(
            currentNickname: "자취9단승규",
            currentUid: 'my_profile', // 👈 에러 방어용 UID 추가!
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),

      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: _navigateToWrite, 
          backgroundColor: const Color(0xFF111827),
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, Icons.home, "홈"),
              _buildTabItem(1, Icons.emoji_events, "랭킹"),
              const SizedBox(width: 40),
              _buildTabItem(2, Icons.search, "재료검색"),
              _buildTabItem(3, Icons.person, "MY"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: isSelected ? Colors.orange : Colors.grey[400],
            size: 24
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey[400],
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}