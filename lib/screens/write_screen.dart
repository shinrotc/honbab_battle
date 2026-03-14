import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../models/recipe_model.dart';

class WriteScreen extends StatefulWidget {
  final RecipeModel? recipeForEdit;
  
  // 🚀 [추가] 현재 사용자의 닉네임을 외부(마이페이지 등)에서 받아옵니다.
  final String currentNickname;

  const WriteScreen({
    super.key, 
    this.recipeForEdit,
    this.currentNickname = "자취9단승규", // 🚀 기본값을 설정해두면 혹시 모를 오류를 방지해요.
  });

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _promoController = TextEditingController(); 
  final TextEditingController _ingredientsController = TextEditingController(); 
  final TextEditingController _recipeController = TextEditingController();      
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
    // 수정 모드일 때 기존 데이터 채우기
    if (widget.recipeForEdit != null) {
      final edit = widget.recipeForEdit!;
      _titleController.text = edit.title;
      _promoController.text = edit.promo;
      _ingredientsController.text = edit.ingredients.join('\n');
      _recipeController.text = edit.recipe;
      _costController.text = edit.cost.toString();
      selectedCategory = edit.category;
    } else {
      selectedCategory = writeCategories[0];
    }
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
    bool hasImage = (_pickedFile != null) || (widget.recipeForEdit?.imagePath != null);
    
    if (_titleController.text.isEmpty || 
        _ingredientsController.text.isEmpty || 
        _recipeController.text.isEmpty || 
        !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사진, 제목, 재료, 조리법은 모두 필수입니다! 🍳")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String downloadUrl = widget.recipeForEdit?.imagePath ?? "";

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

      final recipeData = {
        'title': _titleController.text.trim(),
        'promo': _promoController.text.isEmpty ? "맛있는 레시피를 확인해보세요!" : _promoController.text.trim(),
        'category': selectedCategory,
        'ingredients': _ingredientsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        'recipe': _recipeController.text.trim(),
        'cost': int.tryParse(_costController.text) ?? 0,
        'imagePath': downloadUrl,
        // 🚀 [핵심 수정] 하드코딩된 이름 대신, 전달받은 닉네임을 사용합니다!
        'authorId': widget.recipeForEdit?.authorId ?? widget.currentNickname, 
        'likesCount': widget.recipeForEdit?.likesCount ?? 0,
        'likedUsers': widget.recipeForEdit?.likedUsers ?? [],
        'createdAt': widget.recipeForEdit?.createdAt ?? FieldValue.serverTimestamp(),
      };

      if (widget.recipeForEdit == null) {
        await FirebaseFirestore.instance.collection('recipes').add(recipeData);
      } else {
        await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeForEdit!.id).update(recipeData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.recipeForEdit == null ? "레시피가 등록됐어요! 🚀" : "레시피가 수정됐어요! ✨")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _promoController.dispose();
    _ingredientsController.dispose();
    _recipeController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.recipeForEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(isEditMode ? "레시피 수정" : "새 레시피 공유", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    label: Text(
                      category, 
                      style: TextStyle(
                        color: selectedCategory == category ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: selectedCategory == category,
                    selectedColor: Colors.orange,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      }
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
                child: (_selectedImage == null && _webImagePath == null && widget.recipeForEdit?.imagePath == null)
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

            _buildLabel("요리 이름"),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "예: 기적의 마라 로제 떡볶이",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("한 줄 홍보 (피드 노출용)"),
            TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: "예: 입안에서 터지는 매콤함의 신세계! 🔥",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("필수 재료"),
            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "재료를 엔터로 구분해서 적어주세요",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("조리 방법"),
            TextField(
              controller: _recipeController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "순서대로 조리법을 적어주세요",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            _buildLabel("총 비용 (선택)"),
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
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEditMode ? "수정 완료" : "등록 완료", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  DecorationImage? _buildPreviewImage() {
    if (kIsWeb && _webImagePath != null) {
      return DecorationImage(image: NetworkImage(_webImagePath!), fit: BoxFit.cover);
    } else if (!kIsWeb && _selectedImage != null) {
      return DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover);
    } else if (widget.recipeForEdit?.imagePath != null) {
      return DecorationImage(image: NetworkImage(widget.recipeForEdit!.imagePath!), fit: BoxFit.cover);
    }
    return null;
  }
}