import 'package:flutter/material.dart';
// [중요] 네 파일 이름이 'battle_write_screen.dart'니까 이걸로 가져와야 해!
import 'battle_write_screen.dart'; 

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // [1] 앱바: 뒤로가기 가능
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("진행 중인 배틀 🔥", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      
      // [2] 하단 '도전하기' 버튼 고정
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              // [수정 완료] 버튼 누르면 'battle_write_screen.dart'로 이동! 🚀
              // 혹시 여기서 빨간 줄 뜨면 'battle_write_screen.dart' 파일 안의 클래스 이름이
              // 'BattleWriteScreen'인지 'BattleWritePage'인지 확인해봐!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BattleWriteScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800], // 아주 진한 오렌지
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("이 미션에 도전하기 (참전) ⚔️", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [3] 메인 포스터 이미지
            Stack(
              children: [
                Image.network(
                  "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha:0.8), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SEASON 1", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("편의점 5,000원의 행복", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [4] 미션 설명
                  const Text("📜 미션 내용", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "주머니가 가벼운 자취생들을 위해!\n단돈 5,000원으로 만들 수 있는 최고의 편의점 꿀조합을 소개해주세요. 영수증 인증은 필수!",
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                  ),
                  
                  const SizedBox(height: 30),

                  // [5] 우승 상품
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.orange, size: 30),
                        const SizedBox(width: 15),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("우승 상품", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("편의점 상품권 50,000원", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // [6] 현재 참가자 리스트
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("🔥 현재 참가작", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("14명 참여 중", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // 참가작 미리보기 (가로 스크롤)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildEntryCard("마라로제 떡볶이", "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80"),
                        _buildEntryCard("치즈 폭탄 라면", "https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=200&q=80"),
                        _buildEntryCard("편의점 정식 A", "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=200&q=80"),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(String title, String image) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(image, height: 140, width: 140, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Text("by 익명", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}