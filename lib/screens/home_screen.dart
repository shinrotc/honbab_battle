import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../global_data.dart'; 
import '../models/recipe_model.dart';
import 'detail_screen.dart';
import 'event_screen.dart'; 
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = "전체";
  String _sortBy = "인기순"; 

  // 🔥 실시간 데이터 스트림 (필터링 및 정렬 포함)
  Stream<List<RecipeModel>> _getRecipeStream() {
    Query query = FirebaseFirestore.instance.collection('recipes');
    
    // 1. 정렬 조건 적용
    if (_sortBy == "인기순") {
      query = query.orderBy('likesCount', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }
    
    // 2. 카테고리 필터링 적용
    if (_selectedCategory != "전체") {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), shape: BoxShape.circle),
              child: const Icon(Icons.restaurant, color: Colors.orange, size: 16),
            ),
            const SizedBox(width: 8),
            const Text("혼밥대전", style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          _buildNotificationIcon(),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBanner(context),
            // 카테고리 리스트
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((c) => _buildCategoryButton(c)).toList(),
              ),
            ),
            const SizedBox(height: 15),
            // 정렬 탭
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildSortTab("인기순"),
                  const SizedBox(width: 15),
                  _buildSortTab("최신순"),
                ],
              ),
            ),
            // 레시피 피드 리스트
            StreamBuilder<List<RecipeModel>>(
              stream: _getRecipeStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "데이터를 불러오지 못했어요 😢\n에러 내용: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(80.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  );
                }

                final recipes = snapshot.data ?? [];
                
                if (recipes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(80.0),
                    child: Center(child: Text("등록된 레시피가 없습니다. 🍳")),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15, left: 4),
                          child: Text(_sortBy == "인기순" ? "🏆 지금 가장 핫한 요리" : "🆕 방금 올라온 요리", 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      ...recipes.asMap().entries.map((entry) => 
                        _buildFeedCard(context, recipe: entry.value, rank: _sortBy == "인기순" ? entry.key + 1 : 0)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 위젯 분리 함수들 ---

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black, size: 26),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
        ),
        Positioned(
          right: 12, top: 12,
          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
        ),
      ],
    );
  }

  Widget _buildSortTab(String title) {
    bool isSelected = _sortBy == title;
    return GestureDetector(
      onTap: () => setState(() { _sortBy = title; }),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey[400])),
          if (isSelected) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String text) {
    bool isSelected = _selectedCategory == text;
    return GestureDetector(
      onTap: () => setState(() { _selectedCategory = text; }),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 🚀 [구조 업그레이드] 작성자 닉네임을 실시간으로 유저 창고에서 가져오는 마법의 위젯
  Widget _buildDynamicAuthorName(String? authorId) {
    if (authorId == null || authorId.isEmpty) {
      return Text("무명요리사", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold));
    }

    // 작성자 ID가 'my_profile' (고유 UID)인 경우, 유저 창고에서 실시간으로 닉네임을 긁어옵니다.
    if (authorId == 'my_profile') {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(authorId).snapshots(),
        builder: (context, snapshot) {
          String displayName = "로딩중..."; // 데이터를 가져오는 찰나의 순간
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            displayName = userData['nickname'] ?? "무명요리사";
          }
          return Text(displayName, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold));
        }
      );
    }

    // 만약 옛날에 텍스트("자취9단승규")로 저장된 과거 글이라면 앱이 터지지 않게 그냥 그대로 보여줍니다.
    return Text(authorId, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold));
  }

  Widget _buildFeedCard(BuildContext context, {required RecipeModel recipe, required int rank}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(recipeData: recipe))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: recipe.imagePath != null 
                    ? Image.network(recipe.imagePath!, height: 220, width: double.infinity, fit: BoxFit.cover) 
                    : Container(height: 220, color: Colors.grey[200]),
                ),
                if (rank == 1 && _sortBy == "인기순")
                  Positioned(
                    top: 15, left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(30)),
                      child: const Row(children: [Icon(Icons.whatshot, color: Colors.white, size: 14), SizedBox(width: 4), Text("BEST 1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(recipe.promo, style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      // 🚀 기존 Text 위젯을 지우고 방금 만든 실시간 연동 위젯으로 교체!
                      _buildDynamicAuthorName(recipe.authorId),
                      const Spacer(),
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text("${recipe.likesCount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventScreen())),
      child: Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20), width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.orange, Colors.red], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔥 실시간 랭킹전", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("지금 가장 핫한\n최고의 혼밥 조합은?\n참전하기 >", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
          ],
        ),
      ),
    );
  }
}