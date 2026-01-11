import 'package:flutter/material.dart';

class BattleWriteScreen extends StatefulWidget {
  const BattleWriteScreen({super.key});

  @override
  State<BattleWriteScreen> createState() => _BattleWriteScreenState();
}

class _BattleWriteScreenState extends State<BattleWriteScreen> {
  // 금액 입력 컨트롤러
  final TextEditingController _priceController = TextEditingController();
  
  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("참전 신청서 📝", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // 등록 완료 처리
              Navigator.pop(context); // 닫기
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("참전 등록 완료! 우승을 기원합니다 🙏")));
            },
            child: const Text("제출", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [1] 경고문 (규칙)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "총 재료비가 5,000원을 넘으면\n자동으로 탈락 처리됩니다!",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // [2] 요리 제목
            const Text("요리 이름 (필살기명)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: "예) 눈물 젖은 마라 치즈 밥",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 30),

            // [3] 총 비용 (핵심!)
            const Text("총 지출 금액 (영수증 기준)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
              decoration: InputDecoration(
                hintText: "4,500",
                suffixText: "원",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 30),

            // [4] 사진 첨부 (완성샷 + 영수증)
            const Text("증빙 자료", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPhotoBox("요리 완성샷 📸"),
                const SizedBox(width: 15),
                _buildPhotoBox("영수증 인증 🧾"),
              ],
            ),

            const SizedBox(height: 30),

            // [5] 레시피 설명
            const Text("비법 전수 (레시피)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "심사위원들의 마음을 사로잡을 비법을 적어주세요.\n(편의점 제품명 필수 기재)",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // 사진 첨부 박스 (디자인용)
  Widget _buildPhotoBox(String text) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), // 점선 효과는 패키지 필요해서 실선으로
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Colors.grey),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}