import 'package:flutter/material.dart';
import 'detail_screen.dart'; // 상세 페이지 연결

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // [1] 예산 슬라이더 변수
  double _budget = 5000;

  // [2] 선택된 재료들을 저장할 리스트
  List<String> selectedIngredients = ["라면", "계란"];

  // [3] 전체 재료 목록 (여기에 사용자가 추가한 것도 들어갈 거야!)
  final List<String> allIngredients = [
    "라면", "계란", "참치캔", "스팸/햄", "김치", "치즈", "냉동만두", "밥", "대파", "양파"
  ];

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
          child: const TextField(
            decoration: InputDecoration(
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
        // 키보드가 올라와도 가려지지 않게 bottom padding 넉넉히
        padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 20),
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
                        text: "${_budget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
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
                // 전체 재료 리스트 보여주기
                for (String ingredient in allIngredients)
                  _buildChip(ingredient),
                  
                // [기능 추가됨] 직접 입력 버튼
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

      // 하단 검색 버튼
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
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
                Text("맞춤 레시피 찾기 (${selectedIngredients.length * 15 + 2}건)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // [수정됨] 직접 입력 버튼 (누르면 팝업 뜸!)
  Widget _buildPlusBtn() {
    return GestureDetector(
      onTap: () {
        _showAddIngredientDialog(); // 팝업창 호출
      },
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

  // [새로 추가된 함수] 재료 추가 팝업창
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
            autofocus: true, // 팝업 뜨자마자 키보드 올라오게
            decoration: InputDecoration(
              hintText: "예: 삼겹살, 우유",
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    String newIngredient = textController.text;
                    // 전체 리스트에 없으면 추가
                    if (!allIngredients.contains(newIngredient)) {
                      allIngredients.add(newIngredient);
                    }
                    // 자동으로 선택된 상태로 만들기!
                    if (!selectedIngredients.contains(newIngredient)) {
                      selectedIngredients.add(newIngredient);
                    }
                  });
                  Navigator.pop(context); // 팝업 닫기
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
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text("$rank", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rank == 1 ? Colors.orange : Colors.black)),
            ),
            Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (isNew)
              const Text("NEW", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}