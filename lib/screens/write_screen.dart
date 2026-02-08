import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../models/recipe_model.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promoController = TextEditingController(); 
  final TextEditingController _ingredientsController = TextEditingController(); // [추가] 재료 전용
  final TextEditingController _recipeController = TextEditingController();      // [수정] 조리법 전용
  final TextEditingController _costController = TextEditingController();

  File? _selectedImage;
  XFile? _pickedFile; 
  String? _webImagePath; 
  final ImagePicker _picker = ImagePicker();

  final List<String> writeCategories = ["혼밥", "다이어트", "혼술안주"];
  late String selectedCategory;

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
        _pickedFile = pickedFile; 
        if (kIsWeb) {
          _webImagePath = pickedFile.path;
        } else {
          _selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _uploadRecipe() async {
    bool hasImage = kIsWeb ? _webImagePath != null : _selectedImage != null;
    
    // 필수 입력값 체크 (재료와 조리법도 필수!)
    if (_titleController.text.isEmpty || 
        _ingredientsController.text.isEmpty || 
        _recipeController.text.isEmpty || 
        !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사진, 제목, 재료, 조리법은 모두 필수입니다! 🍳"))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String downloadUrl = "";

      if (_pickedFile != null) {
        String fileName = "recipe_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child('recipes/$fileName');

        if (kIsWeb) {
          Uint8List bytes = await _pickedFile!.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(_selectedImage!);
        }

        downloadUrl = await ref.getDownloadURL();
      }

      // [핵심 변경] 재료는 리스트로 쪼개고, 조리법은 통글로 저장
      final newRecipe = RecipeModel(
        title: _titleController.text.trim(),
        promo: _promoController.text.isEmpty ? "맛있는 레시피를 확인해보세요!" : _promoController.text.trim(),
        category: selectedCategory,
        ingredients: _ingredientsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(), // 👈 재료 컨트롤러 사용!
        recipe: _recipeController.text.trim(), // 👈 조리법만 담기
        cost: int.tryParse(_costController.text) ?? 0,
        imagePath: downloadUrl,
        authorId: "자취9단승규", 
        likesCount: 0,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('recipes')
          .add(newRecipe.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("[$selectedCategory] 레시피가 완벽하게 등록됐어요! 🚀"))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("등록 실패: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promoController.dispose();
    _ingredientsController.dispose(); // [추가]
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

            // [수정 포인트 1] 필수 재료 입력창
            const Text("필수 재료", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "예: 냉동 새우 15마리\n마라소스 3스푼\n(엔터로 구분해서 적어주세요)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            // [수정 포인트 2] 조리 방법 입력창
            const Text("조리 방법", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _recipeController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "1. 새우를 깨끗이 씻어줍니다.\n2. 팬에 기름을 두르고...",
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
            onPressed: _isLoading ? null : _uploadRecipe,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
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