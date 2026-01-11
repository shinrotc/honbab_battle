import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // [추가] 웹/모바일 판단용
import 'package:image_picker/image_picker.dart';
import '../models/recipe_model.dart';
import '../global_data.dart'; // 전역 바구니와 카테고리 명단 가져오기

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  // [1] 데이터 수집용 컨트롤러 (promo 추가)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promoController = TextEditingController(); // [추가] 한 줄 홍보용
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  File? _selectedImage;
  String? _webImagePath; // 웹 환경을 위한 이미지 경로 저장
  final ImagePicker _picker = ImagePicker();

  // [2] 홈 화면과 일치시킨 카테고리 명단
  final List<String> writeCategories = ["혼밥", "다이어트", "혼술안주"];
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = writeCategories[0]; // 초기값: 혼밥
  }

  // [3] 사진 선택 및 압축 함수
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // 용량 최적화를 위한 50% 압축
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

  @override
  void dispose() {
    _titleController.dispose();
    _promoController.dispose(); // [추가]
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
            // 카테고리 선택
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

            // 사진 등록 영역 (웹 대응 완료)
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
                  image: _buildPreviewImage(), // 미리보기 로직 분리
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

            // 요리 이름 입력
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

            // [추가] 한 줄 홍보 입력 (에러 해결 핵심 포인트!)
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

            // 레시피 & 재료 입력
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

            // 비용 입력
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
            onPressed: () {
              // 사진 체크 (웹/모바일 통합)
              bool hasImage = kIsWeb ? _webImagePath != null : _selectedImage != null;
              
              if (_titleController.text.isEmpty || !hasImage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("사진과 제목은 필수입니다! 📸"))
                );
                return;
              }

              // [수정] 새로운 레시피 객체 생성 시 promo 전달 (에러 해결!)
              final newRecipe = RecipeModel(
                title: _titleController.text,
                promo: _promoController.text.isEmpty ? "맛있는 레시피를 확인해보세요!" : _promoController.text,
                category: selectedCategory,
                recipe: _recipeController.text,
                cost: int.tryParse(_costController.text) ?? 0,
                ingredients: _recipeController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
                imagePath: kIsWeb ? _webImagePath : _selectedImage?.path,
              );

              allRecipes.insert(0, newRecipe);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("[$selectedCategory] 섹션에 등록되었습니다! 🚀"))
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("등록 완료", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // 웹과 모바일 미리보기를 자동으로 처리해주는 함수야
  DecorationImage? _buildPreviewImage() {
    if (kIsWeb && _webImagePath != null) {
      return DecorationImage(image: NetworkImage(_webImagePath!), fit: BoxFit.cover);
    } else if (!kIsWeb && _selectedImage != null) {
      return DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover);
    }
    return null;
  }
}