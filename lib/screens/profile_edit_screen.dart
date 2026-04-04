import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileEditScreen extends StatefulWidget {
  final String currentNickname;
  final String currentIntro;
  final String? currentImageUrl;

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

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (selected != null) {
      setState(() => _pickedFile = selected);
    }
  }

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

  // 🚀 [핵심 추가] 프로필 저장 로직 (중복 검사 포함)
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    String newNickname = _nicknameController.text.trim();
    String newIntro = _introController.text.trim();
    String oldNickname = widget.currentNickname;
    final String? oldImageUrl = widget.currentImageUrl;

    // 1. 닉네임 입력 확인
    if (newNickname.isEmpty) {
      _showSnackBar("닉네임을 입력해주세요!");
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 🚀 2. [닉네임 중복 검사] 
      // 내 현재 닉네임과 다를 때만 검사합니다.
      if (newNickname != oldNickname) {
        final duplicateCheck = await FirebaseFirestore.instance
            .collection('users')
            .where('nickname', isEqualTo: newNickname)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          _showSnackBar("이미 사용 중인 닉네임입니다. 다른 이름을 골라보세요! 😊");
          setState(() => _isLoading = false);
          return; // 중복이면 여기서 중단!
        }
      }

      // 3. 사진 업로드 및 서버 청소
      String? newImageUrl = await _uploadProfileImage();
      if (newImageUrl != oldImageUrl && oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        } catch (e) {
          debugPrint("이전 사진 삭제 실패: $e");
        }
      }

      // 4. 파이어베이스 일괄 업데이트 (Batch)
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc('my_profile');
      
      batch.set(userRef, {
        'nickname': newNickname,
        'intro': newIntro,
        'profileImagePath': newImageUrl, 
      }, SetOptions(merge: true));

      QuerySnapshot myRecipes = await FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: oldNickname)
          .get();

      for (var doc in myRecipes.docs) {
        batch.update(doc.reference, {'authorId': newNickname});
      }

      await batch.commit();

      if (!mounted) return;
      _showSnackBar("프로필이 성공적으로 수정되었습니다! ✨");
      Navigator.pop(context);

    } catch (e) {
      debugPrint("수정 에러: $e");
      _showSnackBar("수정 중 오류가 발생했습니다.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("프로필 수정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
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
                          bottom: 0, right: 0,
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.grey[50],
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