import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/recipe_model.dart'; 
import 'detail_screen.dart';

// [1] 만능 리스트 화면 (실시간 필터링 버전)
class UniversalListScreen extends StatelessWidget {
  final String title; 
  final String? filterAuthorId; 

  const UniversalListScreen({
    super.key, 
    required this.title, 
    this.filterAuthorId, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🚀 [핵심 로직] 제목에 따라 다른 쿼리를 실행합니다.
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    title == "내가 쓴 레시피" 
                        ? "아직 등록한 요리가 없어요. 🍳" 
                        : "찜한 요리가 없어요. ❤️",
                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 30, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final recipe = RecipeModel.fromMap(
                docs[index].id, 
                docs[index].data() as Map<String, dynamic>
              );

              return _buildRecipeItem(context, recipe);
            },
          );
        },
      ),
    );
  }

  // 🔥 쿼리 분기 처리 함수
  Stream<QuerySnapshot> _getFilteredStream() {
    final collection = FirebaseFirestore.instance.collection('recipes');
    
    if (title == "내가 쓴 레시피") {
      // 내가 쓴 글: authorId가 일치하는 것만!
      return collection.where('authorId', isEqualTo: "자취9단승규").snapshots();
    } else if (title == "찜한 레시피") {
      // 찜한 글: likedUsers 리스트 안에 내 아이디가 포함된 것만!
      return collection.where('likedUsers', arrayContains: "자취9단승규").snapshots();
    } else {
      // 기본: 전체 목록
      return collection.snapshots();
    }
  }

  // 리스트 아이템 디자인
  Widget _buildRecipeItem(BuildContext context, RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailScreen(recipeData: recipe)
        ));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: recipe.imagePath != null
                ? Image.network(recipe.imagePath!, width: 85, height: 85, fit: BoxFit.cover)
                : Container(width: 85, height: 85, color: Colors.grey[100], child: const Icon(Icons.restaurant, color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 6),
                Text(
                  recipe.promo, 
                  style: TextStyle(color: Colors.grey[500], fontSize: 13), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text("${recipe.likesCount}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text("${recipe.cost}원", style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

// [2] 고객센터 화면 (기존 디자인 유지)
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