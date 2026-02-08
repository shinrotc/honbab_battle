import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // [추가] 파이어베이스 연결용
import '../models/recipe_model.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promoController = TextEditingController(); 
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  File? _selectedImage;
  String? _webImagePath; 
  final ImagePicker _picker = ImagePicker();

  final List<String> writeCategories = ["혼밥", "다이어트", "혼술안주"];
  late String selectedCategory;

  // [추가] 서버 전송 중인지 확인하는 변수 (중복 등록 방지!)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedCategory = writeCategories[0];
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImagePath = pickedFile.path;
        } else {
          _selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  // 🔥 [핵심 추가] 파이어베이스에 레시피 저장하는 함수
  Future<void> _uploadRecipe() async {
    // 1. 유효성 검사 (제목/사진 필수)
    bool hasImage = kIsWeb ? _webImagePath != null : _selectedImage != null;
    if (_titleController.text.isEmpty || !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사진과 제목은 필수입니다! 📸"))
      );
      return;
    }

    setState(() => _isLoading = true); // 로딩 시작!

    try {
      // 2. 새로운 레시피 객체 생성 (우리가 업그레이드한 모델 사용)
      final newRecipe = RecipeModel(
        title: _titleController.text.trim(),
        promo: _promoController.text.isEmpty ? "맛있는 레시피를 확인해보세요!" : _promoController.text.trim(),
        category: selectedCategory,
        recipe: _recipeController.text.trim(),
        cost: int.tryParse(_costController.text) ?? 0,
        ingredients: _recipeController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        // [주의] 이미지는 나중에 Firebase Storage에 올리는 로직을 따로 배워야 해!
        // 지금은 일단 경로 문자열만 저장해서 텍스트 연동부터 확인하자.
        imagePath: kIsWeb ? _webImagePath : _selectedImage?.path,
        authorId: "test_user_sy", // 나중에 실제 로그인 유저 ID로 교체!
        likesCount: 0,
        createdAt: DateTime.now(),
      );

      // 3. 파이어베이스 Firestore 'recipes' 컬렉션에 발사!
      await FirebaseFirestore.instance
          .collection('recipes')
          .add(newRecipe.toMap());

      if (mounted) {
        Navigator.pop(context); // 성공하면 화면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("[$selectedCategory] 섹션에 실시간 등록되었습니다! 🚀"))
        );
      }
    } catch (e) {
      // 에러 발생 시 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("등록 실패: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // 로딩 끝!
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promoController.dispose();
    _recipeController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("새 레시피 공유", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("카테고리 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: writeCategories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category, 
                      style: TextStyle(
                        color: selectedCategory == category ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    selected: selectedCategory == category,
                    selectedColor: Colors.orange,
                    onSelected: (bool selected) {
                      setState(() { if (selected) selectedCategory = category; });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            const Text("요리 완성샷 *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  image: _buildPreviewImage(),
                ),
                child: (_selectedImage == null && _webImagePath == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        const Text("맛있는 요리 사진을 올려주세요", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 30),

            const Text("요리 이름", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "예: 기적의 마라 로제 떡볶이",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            const Text("한 줄 홍보 (피드 노출용)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: "예: 입안에서 터지는 매콤함의 신세계! 🔥",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            const Text("간단 레시피 & 재료", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _recipeController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "재료를 엔터(줄바꿈)로 구분해서 적어주세요.",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            const Text("총 비용 (선택)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: "원",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            // [수정] _isLoading이 true일 때는 클릭 안 되게 막기!
            onPressed: _isLoading ? null : _uploadRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            // [수정] 로딩 중일 때는 동그라미 로딩바 보여주기
            child: _isLoading 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : const Text("등록 완료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  DecorationImage? _buildPreviewImage() {
    if (kIsWeb && _webImagePath != null) {
      return DecorationImage(image: NetworkImage(_webImagePath!), fit: BoxFit.cover);
    } else if (!kIsWeb && _selectedImage != null) {
      return DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover);
    }
    return null;
  }
}