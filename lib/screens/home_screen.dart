import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // [핵심] 웹/모바일 판단용
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

  @override
  Widget build(BuildContext context) {
    // 데이터 필터링 로직
    List<RecipeModel> filteredRecipes = _selectedCategory == "전체"
        ? allRecipes
        : allRecipes.where((r) => r.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      
      // [디자인 유지] 상단 앱바 디자인 (로고 + 알림 종 모양)
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
            const Text("혼밥대전", style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black, size: 26),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                },
              ),
              Positioned(
                right: 12, top: 12,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // [디자인 유지] 주황색 그라데이션 이벤트 배너
            _buildBanner(context),
            
            // [디자인 유지] 카테고리 가로 스크롤
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: categories.map((c) => _buildCategoryButton(c)).toList(),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text("$_selectedCategory 레시피 (${filteredRecipes.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // [데이터 연결] 필터링된 레시피 카드 출력
                  ...filteredRecipes.map((recipe) => _buildFeedCard(
                    context,
                    recipe: recipe,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // [수정] MainScreen에서 글쓰기를 담당하므로, 중복되는 floatingActionButton(연필 아이콘)을 삭제했어!
    );
  }

  // --- 부품 위젯들 (승규의 디자인 원본 유지) ---

  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.red], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Text("🔥 D-2 남음", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          const Text("편의점 5,000원의\n행복을 찾아라!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EventScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Text("참전하기 >", style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
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

  Widget _buildFeedCard(BuildContext context, {required RecipeModel recipe}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(recipeData: recipe))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImageWidget(recipe.imagePath),
                ),
                Positioned(
                  bottom: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text("${recipe.cost}원", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
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
                  Text(recipe.recipe, style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(radius: 10, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 12, color: Colors.white)),
                      const SizedBox(width: 6),
                      Text("자취9단승규", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      const Text("128", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  // [웹 대응 이미지 로직] 크롬에서도 에러 없이 작동해!
  Widget _buildImageWidget(String? path) {
    if (path == null) return Container(height: 220, color: Colors.grey[200]);
    if (path.startsWith('http')) return Image.network(path, height: 220, width: double.infinity, fit: BoxFit.cover);
    
    return kIsWeb 
      ? Image.network(path, height: 220, width: double.infinity, fit: BoxFit.cover)
      : Image.file(File(path), height: 220, width: double.infinity, fit: BoxFit.cover);
  }
}