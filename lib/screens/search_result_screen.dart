import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import 'detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final int budget;
  final List<String> ingredients;
  final String searchQuery;

  const SearchResultScreen({
    super.key,
    required this.budget,
    required this.ingredients,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("'$searchQuery' 검색 결과", style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 [서버 필터링] 예산(number) 필터링은 파이어베이스 서버에서 1차로 수행!
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('cost', isLessThanOrEqualTo: budget)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("오류 발생"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));

          final allDocs = snapshot.data!.docs;

          // 💡 [클라이언트 필터링] 재료와 검색어는 여기서 더 똑똑하게 걸러냅니다.
          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String title = data['title'] ?? "";
            final List<dynamic> recipeIngs = data['ingredients'] ?? [];

            // 1. 검색어 필터: 제목에 '마라'가 들어있으면 OK!
            bool matchesSearch = searchQuery.isEmpty || 
                                title.toLowerCase().contains(searchQuery.toLowerCase());

            // 2. 재료 필터: "새우" 칩을 누르면 "냉동 새우 15마리"도 찾을 수 있게 수정!
            bool matchesIngredients = ingredients.isEmpty || 
                ingredients.any((selected) => 
                  recipeIngs.any((ing) => ing.toString().contains(selected))
                );

            return matchesSearch && matchesIngredients;
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("조건에 맞는 마라 요리가 아직 없어요! 😅"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: filteredDocs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final recipe = RecipeModel.fromMap(
                filteredDocs[index].id,
                filteredDocs[index].data() as Map<String, dynamic>,
              );
              
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => DetailScreen(recipeData: recipe)
                )),
                child: _buildResultCard(recipe),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildResultCard(RecipeModel recipe) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(recipe.imagePath ?? "", width: 70, height: 70, fit: BoxFit.cover, 
              errorBuilder: (c,e,s) => const Icon(Icons.restaurant, size: 30)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("${recipe.cost}원", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}