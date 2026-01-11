import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'search_screen.dart';
import 'mypage_screen.dart';
import 'write_screen.dart'; // 글쓰기 화면 연결

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 번호

  // [1] 스와이프를 제어하기 위한 컨트롤러 추가
  final PageController _pageController = PageController();

  // 화면 리스트
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),     // 0번
    const RankingScreen(),  // 1번
    const SearchScreen(),   // 2번 (냉장고)
    const MyPageScreen(),   // 3번
  ];

  @override
  void dispose() {
    // [2] 컨트롤러 사용 후 메모리 해제 (중요!)
    _pageController.dispose();
    super.dispose();
  }

  // 탭 버튼을 눌렀을 때 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // [3] 아이콘 클릭 시 해당 페이지로 부드럽게 이동
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // [4] body를 PageView로 변경하여 스와이프 기능 활성화
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // 손으로 밀어서 페이지가 바뀌면 하단 아이콘 불빛도 동기화
          });
        },
        children: _widgetOptions,
      ),

      // 2. 가운데 둥둥 떠 있는 글쓰기 버튼 (Floating Action Button)
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WriteScreen()),
            );
          },
          backgroundColor: const Color(0xFF111827), // 진한 검정
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      
      // 3. 버튼 위치 설정
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 4. 하단 내비게이션 바 (BottomAppBar)
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
              const SizedBox(width: 40), // 중앙 글쓰기 버튼 자리
              _buildTabItem(2, Icons.search, "재료검색"),
              _buildTabItem(3, Icons.person, "MY"),
            ],
          ),
        ),
      ),
    );
  }

  // 탭 아이템 만드는 함수
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