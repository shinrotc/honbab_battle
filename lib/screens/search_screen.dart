import 'package:flutter/material.dart';
import 'search_result_screen.dart'; // 👈 검색 결과 화면 연결 확인!

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // [1] 검색어 제어를 위한 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // [2] 예산 슬라이더 변수
  double _budget = 5000;

  // [3] 선택된 재료들을 저장할 리스트
  List<String> selectedIngredients = ["라면", "계란"];

  // [4] 전체 재료 목록
  final List<String> allIngredients = [
    "라면", "계란", "참치캔", "스팸/햄", "김치", "치즈", "냉동만두", "밥", "대파", "양파"
  ];

  @override
  void dispose() {
    _searchController.dispose(); // 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 상단 검색바
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController, // 👈 컨트롤러 연결
            decoration: const InputDecoration(
              hintText: "재료나 요리명을 입력하세요",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),

      // 본문
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120, left: 20, right: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 2-1. 예산 슬라이더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("💰 오늘의 예산", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _budget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.orange)
                      ),
                      const TextSpan(text: "원 이하", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Colors.grey[200],
                thumbColor: Colors.orange,
                trackHeight: 4.0,
              ),
              child: Slider(
                value: _budget,
                min: 0,
                max: 20000,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _budget = value;
                  });
                },
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0원", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("2만원+", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 30),

            // 2-2. 냉장고 재료 태그
            const Text("🧊 냉장고에 뭐가 있나요?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("선택한 재료가 포함된 레시피를 찾아드려요.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 15),

            Wrap(
              spacing: 8, 
              runSpacing: 8, 
              children: [
                for (String ingredient in allIngredients)
                  _buildChip(ingredient),
                _buildPlusBtn(),
              ],
            ),

            const SizedBox(height: 30),

            // 2-3. 실시간 검색어
            const Text("🔥 지금 뜨는 검색어", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildRankItem(1, "마크정식 업그레이드", isNew: true),
            _buildRankItem(2, "불닭 리조또", isNew: false),
            _buildRankItem(3, "순두부 열라면", isNew: false),
          ],
        ),
      ),

      // 🔥 [결정적 수정] 하단 검색 버튼 로직
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              // ✅ 이제 상세페이지가 아니라 '검색 결과 화면'으로 모든 데이터를 들고 이동합니다!
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => SearchResultScreen(
                    budget: _budget.toInt(),
                    ingredients: selectedIngredients,
                    searchQuery: _searchController.text,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                Text("맞춤 레시피 찾기", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 재료 칩 위젯
  Widget _buildChip(String text) {
    bool isSelected = selectedIngredients.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedIngredients.remove(text);
          } else {
            selectedIngredients.add(text);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  // 직접 입력 버튼
  Widget _buildPlusBtn() {
    return GestureDetector(
      onTap: () => _showAddIngredientDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text("+ 직접입력", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  // 재료 추가 팝업
  void _showAddIngredientDialog() {
    TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("재료 추가하기", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "예: 삼겹살"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    if (!allIngredients.contains(textController.text)) {
                      allIngredients.add(textController.text);
                    }
                    if (!selectedIngredients.contains(textController.text)) {
                      selectedIngredients.add(textController.text);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("추가", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRankItem(int rank, String text, {required bool isNew}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$rank", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rank == 1 ? Colors.orange : Colors.black))),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (isNew) const Text("NEW", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}