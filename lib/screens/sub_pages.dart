import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/recipe_model.dart'; 
import 'detail_screen.dart';
import 'write_screen.dart'; 

class UniversalListScreen extends StatelessWidget {
  final String title; 
  final String? filterAuthorId; 
  // 🚀 [추가] 수정 화면으로 전달할 닉네임을 받습니다.
  final String? currentNickname; 

  const UniversalListScreen({
    super.key, 
    required this.title, 
    this.filterAuthorId,
    this.currentNickname, // 👈 생성자에 추가
  });

  // 삭제 로직 (기존 유지)
  Future<void> _deleteRecipe(BuildContext context, String docId, String recipeTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("레시피 삭제", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("'$recipeTitle'을(를) 정말 삭제할까요?\n이 작업은 되돌릴 수 없습니다. 🗑️"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('recipes').doc(docId).delete();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("삭제되었습니다.")));
    }
  }

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
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.orange));
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text(title == "내가 쓴 레시피" ? "아직 등록한 요리가 없어요. 🍳" : "찜한 요리가 없어요. ❤️"));

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 30, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final recipe = RecipeModel.fromMap(docs[index].id, docs[index].data() as Map<String, dynamic>);
              return _buildRecipeItem(context, recipe);
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    final collection = FirebaseFirestore.instance.collection('recipes');
    // 🚀 [수정] 기본값인 '자취9단승규' 대신 'my_profile'(UID)을 기준으로 검색하게 바꿨어!
    if (title == "내가 쓴 레시피") {
      return collection.where('authorId', isEqualTo: filterAuthorId ?? "my_profile").snapshots();
    } else if (title == "찜한 레시피") {
      return collection.where('likedUsers', arrayContains: filterAuthorId ?? "my_profile").snapshots();
    } else {
      return collection.snapshots();
    }
  }

  Widget _buildRecipeItem(BuildContext context, RecipeModel recipe) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(recipeData: recipe))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: recipe.imagePath != null
                ? Image.network(recipe.imagePath!, width: 85, height: 85, fit: BoxFit.cover)
                : Container(width: 85, height: 85, color: Colors.grey[100], child: const Icon(Icons.restaurant)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(recipe.promo, style: TextStyle(color: Colors.grey[500], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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
        title == "내가 쓴 레시피"
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    // 🚀 [핵심 수정] 수정 화면으로 갈 때도 닉네임과 UID를 챙겨서 보냅니다!
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => WriteScreen(
                          recipeForEdit: recipe,
                          currentNickname: currentNickname ?? "자취9단승규",
                          currentUid: filterAuthorId ?? "my_profile", // 👈 지문(UID) 추가!
                        )
                      )
                    );
                  } else if (value == 'delete') {
                    _deleteRecipe(context, recipe.id!, recipe.title);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text("수정하기")),
                  const PopupMenuItem(value: 'delete', child: Text("삭제하기", style: TextStyle(color: Colors.red))),
                ],
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}

// 고객센터 (기존 유지)
class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, title: const Text("고객센터", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("자주 묻는 질문 (FAQ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ExpansionTile(title: const Text("Q. 레시피 등록은 어떻게 하나요?"), children: [Container(width: double.infinity, padding: const EdgeInsets.all(15), color: Colors.grey[50], child: const Text("하단 중앙의 (+) 버튼을 눌러서 작성할 수 있습니다."))]),
            const SizedBox(height: 40),
            const Text("1:1 문의", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)), child: const Text("개발자에게 직접 메일을 보내주세요.\n(이메일 앱 실행 준비 중)", textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}