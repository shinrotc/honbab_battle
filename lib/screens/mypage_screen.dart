import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_screen.dart';
import 'sub_pages.dart'; 
import 'login_screen.dart';
import 'profile_edit_screen.dart'; // 🚀 [추가] 수정 페이지 연결

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  // 🔥 닉네임을 변수로 받아서 해당 유저의 통계를 가져오는 스트림
  Stream<Map<String, int>> _getUserStats(String nickname) {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('authorId', isEqualTo: nickname)
        .snapshots()
        .map((snapshot) {
      int postCount = snapshot.docs.length;
      int totalLikes = 0;
      for (var doc in snapshot.docs) {
        totalLikes += (doc.data()['likesCount'] as int? ?? 0);
      }
      return {'postCount': postCount, 'totalLikes': totalLikes};
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 [핵심] users 컬렉션의 내 정보를 실시간으로 감시합니다.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc('sg_user').snapshots(),
      builder: (context, userSnapshot) {
        // 기본값 설정 (데이터가 아직 없거나 로딩 중일 때)
        String nickname = "자취9단 승규";
        String intro = "한 번 먹어보면 대부분 만듭니다. 가성비와 맛을 모두 잡는 자취 요리 연구가입니다! 🍳";

        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          nickname = userData['nickname'] ?? nickname;
          intro = userData['intro'] ?? intro;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text("마이 프로필", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // 🚀 수정된 프로필 섹션 (닉네임, 소개 전달)
                _buildProfileSection(context, nickname, intro),
                
                // 🚀 실시간 활동 통계 보드 (바뀐 닉네임으로 쿼리)
                _buildStatsBoard(nickname),

                const SizedBox(height: 30),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                _buildMenuSection(context, nickname),
              ],
            ),
          ),
        );
      }
    );
  }

  // 1. 프로필 섹션 (수정 버튼 활성화!)
  Widget _buildProfileSection(BuildContext context, String nickname, String intro) {
    return Column(
      children: [
        Stack( // 🚀 이미지 위에 편집 버튼을 올리기 위해 Stack 사용
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2)),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage("https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=200"),
              ),
            ),
            // 🔥 [수정 버튼 클릭 이벤트 추가]
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfileEditScreen(currentNickname: nickname, currentIntro: intro)
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.orange, 
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(nickname, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
            child: Text(
              "\"$intro\"",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // 2. 통계 보드 (닉네임 연동)
  Widget _buildStatsBoard(String nickname) {
    return StreamBuilder<Map<String, int>>(
      stream: _getUserStats(nickname),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'postCount': 0, 'totalLikes': 0};
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("작성 레시피", "${stats['postCount']}"),
              Container(width: 1, height: 30, color: Colors.grey[200]),
              _buildStatItem("받은 좋아요", "${stats['totalLikes']}"),
              Container(width: 1, height: 30, color: Colors.grey[200]),
              _buildStatItem("랭킹", "TOP 10"),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // 3. 메뉴 리스트 (닉네임 전달)
  Widget _buildMenuSection(BuildContext context, String nickname) {
    return Column(
      children: [
        _buildListTile(context, Icons.description_outlined, "내가 쓴 레시피", () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => UniversalListScreen(
              title: "내가 쓴 레시피", 
              filterAuthorId: nickname, 
            )
          ));
        }),
        _buildListTile(context, Icons.favorite_border, "찜한 레시피", () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const UniversalListScreen(title: "찜한 레시피")
          ));
        }),
        _buildListTile(context, Icons.headset_mic_outlined, "고객센터", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerServiceScreen()));
        }),
        const Divider(height: 20, thickness: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
        _buildListTile(context, Icons.logout, "로그아웃", () => _showLogoutDialog(context), isRed: true),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isRed ? Colors.red[50] : Colors.grey[50], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isRed ? Colors.red : Colors.black87, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isRed ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("로그아웃", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            child: const Text("로그아웃", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}