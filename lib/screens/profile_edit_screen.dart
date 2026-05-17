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
  final String? currentCareer;
  final List<String>? currentCookingStyles;

  const ProfileEditScreen({
    super.key,
    required this.currentNickname,
    required this.currentIntro,
    this.currentImageUrl,
    this.currentCareer,
    this.currentCookingStyles,
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

  String? _selectedCareer;
  List<String> _selectedStyles = [];

  final List<String> _careerOptions = ["1년 미만", "1~3년", "3~5년", "5년 이상", "자취 만렙"];
  final List<String> _styleOptions = ["가성비파", "초간단파", "건강식파", "술안주파", "장인정신파"];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _introController = TextEditingController(text: widget.currentIntro);
    _currentImageUrl = widget.currentImageUrl;

    _selectedCareer = widget.currentCareer;
    _selectedStyles = widget.currentCookingStyles != null 
        ? List<String>.from(widget.currentCookingStyles!) 
        : [];
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

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    String newNickname = _nicknameController.text.trim();
    String newIntro = _introController.text.trim();
    String oldNickname = widget.currentNickname;
    final String? oldImageUrl = widget.currentImageUrl;

    if (newNickname.isEmpty) {
      _showSnackBar("닉네임을 입력해주세요!");
      setState(() => _isLoading = false);
      return;
    }

    try {
      if (newNickname != oldNickname) {
        final duplicateCheck = await FirebaseFirestore.instance
            .collection('users')
            .where('nickname', isEqualTo: newNickname)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          _showSnackBar("이미 사용 중인 닉네임입니다. 다른 이름을 골라보세요! 😊");
          setState(() => _isLoading = false);
          return;
        }
      }

      String? newImageUrl = await _uploadProfileImage();
      if (newImageUrl != oldImageUrl && oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        } catch (e) {
          debugPrint("이전 사진 삭제 실패: $e");
        }
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc('my_profile');
      
      batch.set(userRef, {
        'nickname': newNickname,
        'intro': newIntro,
        'profileImagePath': newImageUrl, 
        'career': _selectedCareer,
        'cookingStyles': _selectedStyles,
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

                _buildInputLabel("자취 경력"),
                DropdownButtonFormField<String>(
                  value: _selectedCareer,
                  items: _careerOptions.map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) => setState(() => _selectedCareer = newValue),
                  decoration: _buildInputDecoration("자취 경력을 선택해 주세요"),
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 30),

                _buildInputLabel("나의 요리 성향 (다중 선택)"),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _styleOptions.map((style) {
                      final isSelected = _selectedStyles.contains(style);
                      return FilterChip(
                        label: Text(style),
                        selected: isSelected,
                        selectedColor: Colors.orange.withOpacity(0.15),
                        checkmarkColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.orange[800] : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey[50],
                        // 🚀 [수정 완료] 기존의 'border: Border.all()'을 FilterChip 전용인 'side: BorderSide()'로 교체했습니다!
                        side: BorderSide(color: isSelected ? Colors.orange : Colors.grey[200]!),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStyles.add(style);
                            } else {
                              _selectedStyles.remove(style);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
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