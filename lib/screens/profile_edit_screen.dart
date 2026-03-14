import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentNickname;
  final String currentIntro;

  const ProfileEditScreen({
    super.key, 
    required this.currentNickname, 
    required this.currentIntro
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _introController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 마이페이지에서 받아온 현재 정보를 입력창에 미리 넣어둠
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _introController = TextEditingController(text: widget.currentIntro);
  }

  // 🚀 [핵심 로직] 프로필 저장 + 작성한 모든 글 이름 변경 (Batch Operation)
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    String newNickname = _nicknameController.text.trim();
    String newIntro = _introController.text.trim();
    String oldNickname = widget.currentNickname;

    try {
      // 1. 파이어베이스 일괄 작업(Batch) 시작
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 2. [내 정보 수정] users 컬렉션의 내 문서 저장 (set 사용)
      // 🚀 주소를 'my_profile'로 통일하고, 없으면 생성하도록 set을 사용합니다.
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc('my_profile');
      batch.set(userRef, {
        'nickname': newNickname,
        'intro': newIntro,
      }, SetOptions(merge: true)); // merge: true를 넣어야 기존 데이터와 합쳐집니다.

      // 3. [작성 글 수정] 내가 쓴 모든 레시피 찾아오기
      QuerySnapshot myRecipes = await FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: oldNickname)
          .get();

      // 찾은 모든 레시피 문서의 작성자명을 새 닉네임으로 변경 예약
      for (var doc in myRecipes.docs) {
        batch.update(doc.reference, {'authorId': newNickname});
      }

      // 4. 예약된 모든 작업(내 정보 + 모든 글 수정) 한꺼번에 실행!
      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필과 작성한 글이 모두 수정되었습니다! ✨")),
      );
      
      // 수정 완료 후 마이페이지로 돌아가기
      Navigator.pop(context);

    } catch (e) {
      debugPrint("수정 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("수정 중 오류가 발생했습니다.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("프로필 수정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: "새로운 닉네임을 입력하세요",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("자기소개", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _introController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "나를 멋지게 소개해 보세요!",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("수정 완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }
}