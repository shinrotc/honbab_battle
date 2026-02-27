import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import 'detail_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  String _selectedSort = "추천순";

  // 1. 파이어베이스 쿼리 설정 (descending 문법 정확히 적용)
  Stream<QuerySnapshot> _getRankingStream() {
    final collection = FirebaseFirestore.instance.collection('recipes');
    
    if (_selectedSort == "추천순") {
      return collection.orderBy('likesCount', descending: true).snapshots();
    } else if (_selectedSort == "최신순") {
      return collection.orderBy('createdAt', descending: true).snapshots();
    } else {
      // 가격낮은순 (오름차순)
      return collection.orderBy('cost', descending: false).snapshots();
    }
  }

  void _onSortChanged(String sortType) {
    setState(() {
      _selectedSort = sortType;
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
        title: const Text("명예의 전당 🏆", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Column(
        children: [
          // 상단 정렬 탭
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

          // 랭킹 리스트 (실시간 Stream 연동)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getRankingStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("데이터를 불러올 수 없습니다."));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("아직 등록된 레시피가 없어요! 😅"));

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    // ✅ [수정] 승규의 모델 설계도 순서에 맞춤 (ID 먼저, Map 데이터 나중)
                    final recipe = RecipeModel.fromMap(
                      docs[index].id,
                      docs[index].data() as Map<String, dynamic>,
                    );
                    
                    return _buildRankItem(
                      rank: index + 1,
                      recipe: recipe, 
                      showMedal: (_selectedSort == "추천순"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 부품: 정렬 탭 ---
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
        child: Text(text, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600], 
            fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  // --- UI 부품: 랭킹 아이템 카드 ---
  Widget _buildRankItem({required int rank, required RecipeModel recipe, required bool showMedal}) {
    Color? medalColor;
    String rankText = "$rank";
    
    if (showMedal) {
      if (rank == 1) { medalColor = const Color(0xFFFFD700); rankText = "🥇"; }
      else if (rank == 2) { medalColor = const Color(0xFFC0C0C0); rankText = "🥈"; }
      else if (rank == 3) { medalColor = const Color(0xFFCD7F32); rankText = "🥉"; }
    }

    return GestureDetector(
      onTap: () {
        // ✅ [수정] DetailScreen이 기다리는 이름 'recipeData'로 정확히 매칭!
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailScreen(recipeData: recipe)
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (showMedal && rank == 1) ? Colors.orange.withValues(alpha: 0.5) : Colors.grey[200]!,
            width: (showMedal && rank == 1) ? 2 : 1
          ),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            SizedBox(width: 40, child: Center(child: Text(rankText, 
              style: TextStyle(
                fontSize: showMedal && rank <= 3 ? 24 : 18, 
                fontWeight: FontWeight.w900, 
                color: medalColor ?? Colors.black)))),
            const SizedBox(width: 10),
            // 이미지 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: recipe.imagePath != null 
                ? Image.network(recipe.imagePath!, width: 70, height: 70, fit: BoxFit.cover)
                : Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.restaurant)),
            ),
            const SizedBox(width: 15),
            // 정보 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text("${recipe.authorId ?? '익명'} 쉐프", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("${recipe.cost}원", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                      const Spacer(),
                      // ✅ [수정] 리스트 내부 if문에 중괄호 {}를 제거하여 에러 방지
                      if (_selectedSort == "최신순")
                         Text(
                           recipe.createdAt != null 
                           ? "${recipe.createdAt!.year}.${recipe.createdAt!.month}.${recipe.createdAt!.day}" 
                           : "날짜 정보 없음", 
                           style: const TextStyle(fontSize: 11, color: Colors.grey)
                         )
                      else
                        Row(
                          children: [
                            const Icon(Icons.favorite, size: 12, color: Colors.red),
                            const SizedBox(width: 2),
                            Text("${recipe.likesCount}", 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
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