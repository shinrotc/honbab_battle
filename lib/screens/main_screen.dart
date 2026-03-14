import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 [추가] DB 접근을 위해 필요!
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

  // 🚀 [추가] 글쓰기 화면으로 가기 전 최신 닉네임을 가져오는 함수
  Future<void> _navigateToWrite() async {
    try {
      // 1. 프로필 수정에서 저장했던 'my_profile' 문서를 읽어옵니다.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc('my_profile')
          .get();

      // 2. 저장된 닉네임이 있으면 가져오고, 없으면 기본값을 씁니다.
      String latestNick = "자취9단승규";
      if (doc.exists && doc.data() != null) {
        latestNick = doc.data()!['nickname'] ?? "자취9단승규";
      }

      // 3. 최신 닉네임을 들고 글쓰기 화면으로 이동!
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WriteScreen(currentNickname: latestNick),
        ),
      );
    } catch (e) {
      print("닉네임 가져오기 실패: $e");
      // 에러가 나도 글은 쓸 수 있게 기본값으로 이동
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WriteScreen(currentNickname: "자취9단승규"),
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

      // 2. 가운데 둥둥 떠 있는 글쓰기 버튼
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          // 🚀 [수정] 바로 이동하는 대신, 닉네임을 챙겨서 이동하는 함수를 실행합니다.
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