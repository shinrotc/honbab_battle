import 'package:flutter/material.dart';
import 'detail_screen.dart'; // 상세 페이지 연결

// [1] 만능 리스트 화면 (내가 쓴 글, 찜한 레시피 공용)
class UniversalListScreen extends StatelessWidget {
  final String title; // 화면 제목 ("내가 쓴 글" 또는 "찜한 레시피")

  const UniversalListScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // 가짜 데이터 (제목에 따라 조금 다르게 보이게 함)
    final List<Map<String, String>> dummyData = List.generate(5, (index) => {
      "title": title == "내가 쓴 글" ? "내 레시피 $index : 마라 떡볶이" : "찜한 요리 $index : 치즈 불닭",
      "date": "2024.12.${10 + index}",
      "image": "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80"
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyData.length,
        separatorBuilder: (context, index) => const Divider(height: 30),
        itemBuilder: (context, index) {
          final item = dummyData[index];
          return GestureDetector(
            onTap: () {
              // 상세 페이지로 이동
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailScreen()));
            },
            child: Row(
              children: [
                // 썸네일 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(item["image"]!, width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["title"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(item["date"]!, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      const SizedBox(height: 8),
                      // 찜한 목록일 때만 하트 표시
                      if (title == "찜한 레시피")
                        const Row(
                          children: [
                            Icon(Icons.favorite, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text("찜 취소", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          );
        },
      ),
    );
  }
}

// [2] 고객센터 화면 (FAQ + 문의하기)
class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("고객센터", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("자주 묻는 질문 (FAQ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildFAQItem("Q. 레시피 등록은 어떻게 하나요?", "하단 중앙의 (+) 버튼을 눌러서 작성할 수 있습니다."),
            _buildFAQItem("Q. 랭킹은 언제 바뀌나요?", "랭킹은 매일 자정에 업데이트됩니다."),
            _buildFAQItem("Q. 닉네임을 변경하고 싶어요.", "마이페이지 > 설정에서 변경 가능합니다."),
            
            const SizedBox(height: 40),
            
            const Text("1:1 문의", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text("궁금한 점이 해결되지 않으셨나요?\n개발자에게 직접 메일을 보내주세요.", textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 나중에 이메일 앱 띄우기 연결
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📧 이메일 앱을 실행합니다 (준비중)")));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: const Text("이메일 문의하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          color: Colors.grey[50],
          child: Text(answer, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      ],
    );
  }
}