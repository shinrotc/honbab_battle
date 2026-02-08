import 'package:flutter/material.dart';
import 'detail_screen.dart'; // [필수] 상세 페이지 연결

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // 현재 선택된 정렬 기준 (기본값: 추천순)
  String _selectedSort = "추천순";

  // [더미 데이터] 정렬 테스트를 위해 날짜와 가격, 좋아요를 다양하게 넣었어!
  final List<Map<String, dynamic>> _originalData = [
    {
      "title": "마크정식 업그레이드",
      "author": "편의점고인물",
      "price": 6500,
      "likes": 150, // 좋아요 1등
      "date": "2024-12-10", // 좀 된 날짜
      "image": "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80"
    },
    {
      "title": "순두부 열라면",
      "author": "맵찔이탈출",
      "price": 3800,
      "likes": 120, // 좋아요 2등
      "date": "2024-12-13",
      "image": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80"
    },
    {
      "title": "불닭 리조또",
      "author": "치즈러버",
      "price": 4500,
      "likes": 95,
      "date": "2024-12-15", // [최신순 1등] 가장 최근 날짜!
      "image": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=200&q=80"
    },
    {
      "title": "편의점 어묵탕 꿀조합",
      "author": "혼술남녀",
      "price": 3000, // [가격순 1등] 가장 쌈!
      "likes": 80,
      "date": "2024-12-11",
      "image": "https://images.unsplash.com/photo-1574484284008-be9d62827038?auto=format&fit=crop&w=200&q=80"
    },
    {
      "title": "자이언트 떡볶이 라볶이",
      "author": "먹방요정",
      "price": 5000,
      "likes": 45,
      "date": "2024-12-12",
      "image": "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=200&q=80"
    },
  ];

  // 화면에 보여줄(정렬된) 리스트
  late List<Map<String, dynamic>> _displayList;

  @override
  void initState() {
    super.initState();
    _sortList(); // 앱 켜지자마자 정렬 한 번 하기
  }

  // [핵심] 정렬 로직
  void _sortList() {
    _displayList = List.from(_originalData); // 원본 복사

    if (_selectedSort == "추천순") {
      // 좋아요 많은 순 (내림차순)
      _displayList.sort((a, b) => b["likes"].compareTo(a["likes"]));
    } else if (_selectedSort == "최신순") {
      // 날짜 최신 순 (내림차순)
      _displayList.sort((a, b) => b["date"].compareTo(a["date"]));
    } else if (_selectedSort == "가격낮은순") {
      // 가격 낮은 순 (오름차순)
      _displayList.sort((a, b) => a["price"].compareTo(b["price"]));
    }
  }

  // 탭 누르면 실행되는 함수
  void _onSortChanged(String sortType) {
    setState(() {
      _selectedSort = sortType; // 선택된 탭 이름 바꾸고
      _sortList(); // 그 기준대로 다시 정렬!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("명예의 전당 🏆", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // [2] 정렬 탭 버튼들
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildSortTab("추천순"),
                const SizedBox(width: 10),
                _buildSortTab("최신순"),
                const SizedBox(width: 10),
                _buildSortTab("가격낮은순"),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // [3] 랭킹 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _displayList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = _displayList[index];
                
                // [중요] 추천순일 때만 메달을 보여줌!
                final bool showMedal = (_selectedSort == "추천순");
                
                return _buildRankItem(
                  rank: index + 1,
                  item: item,
                  showMedal: showMedal,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 탭 버튼 만드는 부품
  Widget _buildSortTab(String text) {
    bool isSelected = _selectedSort == text;
    return GestureDetector(
      onTap: () => _onSortChanged(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 리스트 아이템 만드는 부품
  Widget _buildRankItem({required int rank, required Map<String, dynamic> item, required bool showMedal}) {
    // 메달 색깔 정하기
    Color? medalColor;
    String rankText = "$rank";
    
    // 추천순일 때만 1,2,3등에게 메달을 줌
    if (showMedal) {
      if (rank == 1) {
        medalColor = const Color(0xFFFFD700);
        rankText = "🥇";
      } else if (rank == 2) {
        medalColor = const Color(0xFFC0C0C0);
        rankText = "🥈";
      } else if (rank == 3) {
        medalColor = const Color(0xFFCD7F32);
        rankText = "🥉";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // 1등이고 추천순이면 주황색 테두리
            color: (showMedal && rank == 1) ? Colors.orange.withValues(alpha:0.5) : Colors.grey[200]!,
            width: (showMedal && rank == 1) ? 2 : 1
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            // 순위 (메달 또는 숫자)
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  rankText,
                  style: TextStyle(
                    fontSize: showMedal && rank <= 3 ? 24 : 18, 
                    fontWeight: FontWeight.w900,
                    color: medalColor ?? Colors.black, 
                    fontStyle: showMedal && rank <= 3 ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item["image"],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),

            // 정보 (제목, 가격, 좋아요/날짜)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("${item["author"]} 쉐프", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "${item["price"]}원", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)
                      ),
                      const Spacer(),
                      // [핵심] 최신순이면 날짜를, 아니면 좋아요를 보여줌
                      if (_selectedSort == "최신순")
                         Text(item["date"], style: TextStyle(fontSize: 11, color: Colors.grey[400]))
                      else
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 12, color: Colors.red),
                            const SizedBox(width: 2),
                            Text("${item["likes"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}