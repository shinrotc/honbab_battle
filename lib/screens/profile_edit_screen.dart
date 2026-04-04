import 'dart:io'; // 🚀 [필수] File 처리를 위해 필요
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🚀 [필수] kIsWeb 사용을 위해 필요
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentNickname;
  final String currentIntro;
  final String? currentImageUrl; // 마이페이지에서 넘겨받은 기존 이미지 주소

  const ProfileEditScreen({
    super.key,
    required this.currentNickname,
    required this.currentIntro,
    this.currentImageUrl,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _introController;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile; 
  String? _currentImageUrl; 

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _introController = TextEditingController(text: widget.currentIntro);
    _currentImageUrl = widget.currentImageUrl;
  }

  // 1. 갤러리에서 이미지 선택
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, // 용량 최적화
    );
    if (selected != null) {
      setState(() => _pickedFile = selected);
    }
  }

  // 2. 새 이미지를 스토리지에 업로드
  Future<String?> _uploadProfileImage() async {
    if (_pickedFile == null) return _currentImageUrl;

    String fileName = "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child('profiles/$fileName');

    if (kIsWeb) {
      await ref.putData(await _pickedFile!.readAsBytes());
    } else {
      await ref.putFile(File(_pickedFile!.path));
    }
    return await ref.getDownloadURL();
  }

  // 3. 프로필 저장 (서버 청소 로직 포함)
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    String newNickname = _nicknameController.text.trim();
    String newIntro = _introController.text.trim();
    String oldNickname = widget.currentNickname;
    // 🚀 [포인트] 기존 이미지 주소를 변수에 담아둡니다. (노란 줄 해결!)
    final String? oldImageUrl = widget.currentImageUrl;

    try {
      // (1) 새 사진 업로드
      String? newImageUrl = await _uploadProfileImage();

      // (2) 🚀 [고수 로직] 새 사진이 올라갔다면 기존 사진은 서버에서 삭제!
      if (newImageUrl != oldImageUrl && oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          // 기존 주소로 서버의 파일 위치를 찾아 삭제합니다.
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
          debugPrint("서버의 이전 프로필 사진 삭제 완료! 🗑️");
        } catch (e) {
          debugPrint("이전 사진 삭제 중 오류 (이미 없거나 경로 오류): $e");
          // 삭제 실패해도 프로필 수정은 계속 진행합니다.
        }
      }

      // (3) 파이어베이스 일괄 작업(Batch) 시작
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc('my_profile');
      
      batch.set(userRef, {
        'nickname': newNickname,
        'intro': newIntro,
        'profileImagePath': newImageUrl, 
      }, SetOptions(merge: true));

      // (4) 내가 쓴 글들의 작성자 이름도 새 닉네임으로 변경
      QuerySnapshot myRecipes = await FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: oldNickname)
          .get();

      for (var doc in myRecipes.docs) {
        batch.update(doc.reference, {'authorId': newNickname});
      }

      // 모든 작업 한꺼번에 실행
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필이 깔끔하게 수정되었습니다! ✨")),
      );
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
              children: [
                // 🚀 프로필 이미지 디자인 영역
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _pickedFile != null 
                              ? (kIsWeb ? NetworkImage(_pickedFile!.path) : FileImage(File(_pickedFile!.path)) as ImageProvider)
                              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty ? NetworkImage(_currentImageUrl!) : null),
                          child: (_pickedFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("프로필 사진 변경", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 40),

                // 입력 필드들
                _buildInputLabel("닉네임"),
                TextField(
                  controller: _nicknameController,
                  decoration: _buildInputDecoration("새로운 닉네임을 입력하세요"),
                ),
                const SizedBox(height: 30),

                _buildInputLabel("자기소개"),
                TextField(
                  controller: _introController,
                  maxLines: 3,
                  decoration: _buildInputDecoration("나를 멋지게 소개해 보세요!"),
                ),
                const SizedBox(height: 50),

                // 수정 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
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

  // UI 보조 위젯: 라벨
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // UI 보조 위젯: 입력창 디자인
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introController.dispose();
    super.dispose();
  }
}