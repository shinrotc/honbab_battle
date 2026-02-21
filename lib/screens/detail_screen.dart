import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 파이어베이스 연결
import '../models/recipe_model.dart';
import 'cooking_screen.dart';

class DetailScreen extends StatefulWidget {
  final RecipeModel? recipeData; 

  const DetailScreen({super.key, this.recipeData});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // 데이터 기본값 설정
  RecipeModel get data => widget.recipeData ?? RecipeModel(
    title: "불닭+치즈+소시지 조합",
    promo: "편의점 최고의 맵단 조합! 🔥",
    category: "혼밥",
    recipe: "물 끓여서 면 익히고 물은 3스푼만 남기고 버립니다.\n소스 다 넣고, 소시지 썰어 올리고, 치즈 찢어 올립니다.\n전자레인지 2분 돌리면 끝!",
    cost: 4200,
    ingredients: ["불닭볶음면 큰컵", "의성마늘 후랑크", "스트링 치즈"],
    imagePath: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800",
  );

  // 🔥 투표(좋아요) 기능 함수
  Future<void> _voteRecipe() async {
    // recipeData나 id가 없으면 실행 안 함
    if (widget.recipeData == null || widget.recipeData!.id == null) {
      debugPrint("요리 ID를 찾을 수 없습니다.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeData!.id)
          .update({'likesCount': FieldValue.increment(1)});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("투표가 완료됐어요! 👍")),
        );
      }
    } catch (e) {
      debugPrint("투표 에러: $e");
    }
  }

  Future<void> _launchShopping(String query) async {
    final String encodedQuery = Uri.encodeComponent(query);
    final Uri uri = Uri.parse("https://www.kurly.com/search?words=$encodedQuery");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) debugPrint("실패");
  }

  Future<void> _launchCoupang(String query) async {
    final String encodedQuery = Uri.encodeComponent(query);
    final Uri uri = Uri.parse("https://www.coupang.com/np/search?q=$encodedQuery");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) debugPrint("실패");
  }

  Future<void> _launchMap(String storeName) async {
    final String query = Uri.encodeComponent(storeName);
    final Uri appUri = Uri.parse("nmap://search?query=$query&appname=com.example.honbab_battle");
    final Uri webUri = Uri.parse("https://m.map.naver.com/search2/search.naver?query=$query&sm=hty&style=v5");
    if (await canLaunchUrl(appUri)) { await launchUrl(appUri); } 
    else { await launchUrl(webUri, mode: LaunchMode.externalApplication); }
  }

  @override
  Widget build(BuildContext context) {
    // 실시간 데이터 감시
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('recipes').doc(widget.recipeData?.id).snapshots(),
      builder: (context, snapshot) {
        int currentLikes = data.likesCount;
        if (snapshot.hasData && snapshot.data!.exists) {
          currentLikes = snapshot.data!.get('likesCount') ?? 0;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderImage(data.imagePath),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(data.promo, style: TextStyle(fontSize: 14, color: Colors.orange[700], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      _buildAuthorRow(currentLikes),
                      const SizedBox(height: 30),
                      const Text("🛒 준비물", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ...data.ingredients.map((ing) => _buildIngredientCard(context, name: ing, isEssential: true)),
                      const SizedBox(height: 20),
                      _buildTipBox(), 
                      const SizedBox(height: 40),
                      _buildRecipeHeader(context),
                      const SizedBox(height: 15),
                      ...data.recipe.split('\n').where((s) => s.trim().isNotEmpty).toList().asMap().entries.map((entry) {
                        return _buildStep(entry.key + 1, entry.value);
                      }),
                      const SizedBox(height: 40),
                      _buildCommentHeader(),
                      const SizedBox(height: 20),
                      const CommentItem(name: "라면요정", date: "1시간 전", content: "와 진짜 편의점 꿀조합 인정합니다!", initLikes: 12),
                      const CommentItem(name: "자취생1년차", date: "5시간 전", content: "치즈는 무조건 많이 넣으세요 ㅋㅋ", initLikes: 5),
                      const SizedBox(height: 10),
                      _buildCommentInput(),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomVoteBar(context),
        );
      }
    );
  }

  Widget _buildHeaderImage(String? path) {
    if (path == null) return Container(color: Colors.grey);
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover);
    return kIsWeb ? Image.network(path, fit: BoxFit.cover) : Image.file(File(path), fit: BoxFit.cover);
  }

  Widget _buildIngredientCard(BuildContext context, {required String name, required bool isEssential}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("• $name", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF374151))),
              if (isEssential) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                  child: const Text("필수", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildActionButton(onPressed: () => _launchShopping(name), icon: Icons.shopping_bag_outlined, label: "컬리", color: const Color(0xFF5F0080)),
              const SizedBox(width: 6),
              _buildActionButton(onPressed: () => _launchCoupang(name), icon: Icons.rocket_launch_outlined, label: "쿠팡", color: const Color(0xFFE52528)),
              const SizedBox(width: 6),
              _buildActionButton(onPressed: () => _showSearchOptions(context, name), icon: Icons.map_outlined, label: "찾기", color: Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onPressed, required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: color),
        label: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: BorderSide(color: color.withOpacity(0.3)), // 👈 안전하게 withOpacity로 수정
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildAuthorRow(int likes) => Row(children: [const CircleAvatar(radius: 12, backgroundColor: Colors.grey), const SizedBox(width: 8), Text("자취9단승규", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.favorite, color: Colors.red), Text(" $likes", style: const TextStyle(fontWeight: FontWeight.bold))]);
  Widget _buildTipBox() => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9D5FF))), child: const Row(children: [Icon(Icons.lightbulb, color: Colors.purple, size: 18), SizedBox(width: 15), Expanded(child: Text("[쿠팡]과 [컬리]에서 가격을 비교하고 알뜰하게 쇼핑하세요!", style: TextStyle(color: Color(0xFF9333EA), fontSize: 11, height: 1.3)))]));

  Widget _buildRecipeHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
    children: [
      const Text("👨‍🍳 조리법", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
      TextButton.icon(
        onPressed: () { 
          final recipeList = data.recipe.split('\n').where((s) => s.trim().isNotEmpty).toList();
          List<Map<String, dynamic>> cookingSteps = recipeList.asMap().entries.map((entry) {
            return { "step": entry.key + 1, "text": entry.value, "timer": 0 };
          }).toList();
          Navigator.push(context, MaterialPageRoute(builder: (context) => CookingScreen(steps: cookingSteps))); 
        }, 
        icon: const Icon(Icons.play_circle_fill, size: 20, color: Colors.orange), 
        label: const Text("큰 화면으로 보기", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13))
      )
    ]
  );

  Widget _buildStep(int step, String text) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("$step. ", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)), Expanded(child: Text(text, style: const TextStyle(fontSize: 14)))]));
  Widget _buildCommentHeader() => const Row(children: [Text("댓글", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 6), Text("14", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange))]);
  Widget _buildCommentInput() => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)), child: const Text("댓글을 남겨주세요...", style: TextStyle(color: Colors.grey, fontSize: 14)));

  Widget _buildBottomVoteBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          border: Border(top: BorderSide(color: Colors.grey[200]!)), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text("현재 랭킹", style: TextStyle(fontSize: 11, color: Colors.grey)), 
                Row(children: [Text("🔥", style: TextStyle(fontSize: 14)), SizedBox(width: 4), Text("실시간 3위", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])
              ]
            ),
            const Spacer(),
            SizedBox(
              width: 160, 
              height: 50, 
              child: ElevatedButton(
                onPressed: _voteRecipe, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), 
                child: const Text("투표하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
              )
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchOptions(BuildContext context, String ingredientName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("[$ingredientName] 어디서 찾을까요?", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: const Text("내 주변 편의점 찾기 (네이버 지도)"),
                  onTap: () { Navigator.pop(context); _launchMap("편의점"); },
                ),
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.purple),
                  title: const Text("가까운 CU 매장 찾기"),
                  onTap: () { Navigator.pop(context); _launchMap("CU"); },
                ),
                ListTile(
                  leading: const Icon(Icons.storefront, color: Colors.lightBlue),
                  title: const Text("가까운 GS25 매장 찾기"),
                  onTap: () { Navigator.pop(context); _launchMap("GS25"); },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 👈 사라졌던 댓글 아이템 클래스들 다시 복구!
class CommentItem extends StatefulWidget {
  final String name; final String date; final String content; final int initLikes; 
  const CommentItem({super.key, required this.name, required this.date, required this.content, required this.initLikes});
  @override State<CommentItem> createState() => _CommentItemState();
}
class _CommentItemState extends State<CommentItem> {
  bool isLiked = false; late int likeCount;    
  @override void initState() { super.initState(); likeCount = widget.initLikes; }
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 18, backgroundColor: Colors.grey[100], child: const Icon(Icons.person, color: Colors.grey, size: 20)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 6), Text(widget.date, style: TextStyle(color: Colors.grey[400], fontSize: 11))]), const SizedBox(height: 4), Text(widget.content, style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4))])), const SizedBox(width: 10), GestureDetector(onTap: () { setState(() { isLiked = !isLiked; isLiked ? likeCount++ : likeCount--; }); }, child: Column(children: [Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 18, color: isLiked ? Colors.red : Colors.grey[400]), Text("$likeCount", style: TextStyle(fontSize: 11, color: isLiked ? Colors.red : Colors.grey[500]))]))]));
  }
}