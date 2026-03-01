import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import '../models/recipe_model.dart';

class WriteScreen extends StatefulWidget {
  // 🚀 [추가] 수정 모드인지 확인하기 위한 필드
  final RecipeModel? recipeForEdit;
  const WriteScreen({super.key, this.recipeForEdit});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  // 승규의 소중한 컨트롤러들 (보존)
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
    // 🚀 [수정 모드 대응] 데이터가 있으면 채우고, 없으면 기본값
    if (widget.recipeForEdit != null) {
      final e = widget.recipeForEdit!;
      _titleController.text = e.title;
      _promoController.text = e.promo;
      _ingredientsController.text = e.ingredients.join('\n'); // 리스트 -> 텍스트 변환
      _recipeController.text = e.recipe;
      _costController.text = e.cost.toString();
      selectedCategory = e.category;
    } else {
      selectedCategory = writeCategories[0];
    }
  }

  // 승규의 이미지 피커 로직 (보존)
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 1024);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile; 
        if (kIsWeb) _webImagePath = pickedFile.path;
        else _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 🚀 업로드 및 수정 로직 통합
  Future<void> _uploadRecipe() async {
    // 사진 체크 로직 수정 (수정 모드일 땐 기존 사진 있어도 됨)
    bool hasImage = (_pickedFile != null) || (widget.recipeForEdit?.imagePath != null);
    
    if (_titleController.text.isEmpty || _ingredientsController.text.isEmpty || _recipeController.text.isEmpty || !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("사진, 제목, 재료, 조리법은 모두 필수입니다! 🍳")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String downloadUrl = widget.recipeForEdit?.imagePath ?? "";

      // 새 사진을 골랐을 때만 Storage 업로드
      if (_pickedFile != null) {
        String fileName = "recipe_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child('recipes/$fileName');
        if (kIsWeb) {
          await ref.putData(await _pickedFile!.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(_selectedImage!);
        }
        downloadUrl = await ref.getDownloadURL();
      }

      final data = {
        'title': _titleController.text.trim(),
        'promo': _promoController.text.trim(),
        'category': selectedCategory,
        'ingredients': _ingredientsController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        'recipe': _recipeController.text.trim(),
        'cost': int.tryParse(_costController.text) ?? 0,
        'imagePath': downloadUrl,
        'authorId': widget.recipeForEdit?.authorId ?? "자취9단승규", 
        'likesCount': widget.recipeForEdit?.likesCount ?? 0,
        'likedUsers': widget.recipeForEdit?.likedUsers ?? [],
        'createdAt': widget.recipeForEdit?.createdAt ?? FieldValue.serverTimestamp(),
      };

      if (widget.recipeForEdit == null) {
        await FirebaseFirestore.instance.collection('recipes').add(data);
      } else {
        // 🚀 수정 모드: update 사용
        await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeForEdit!.id).update(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.recipeForEdit == null ? "등록 완료! 🚀" : "수정 완료! ✨")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("실패: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose(); _promoController.dispose(); _ingredientsController.dispose();
    _recipeController.dispose(); _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.recipeForEdit != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, title: Text(isEdit ? "레시피 수정" : "새 레시피 공유", style: const TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 승규의 카테고리 칩 UI (보존) ---
            const Text("카테고리 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(children: writeCategories.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: selectedCategory == c, onSelected: (s) { if(s) setState(()=>selectedCategory=c); }))).toList()),
            const SizedBox(height: 30),

            // --- 승규의 이미지 영역 UI (보존) ---
            const Text("요리 완성샷 *", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[300]!), 
                image: _buildPreviewImage()),
                child: (_selectedImage == null && _webImagePath == null && widget.recipeForEdit?.imagePath == null) ? const Icon(Icons.camera_alt, color: Colors.grey) : null,
              ),
            ),
            const SizedBox(height: 30),

            // --- 승규의 입력창들 (보존) ---
            _buildLabel("요리 이름"),
            TextField(controller: _titleController, decoration: InputDecoration(hintText: "제목 입력", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            _buildLabel("한 줄 홍보"),
            TextField(controller: _promoController, decoration: InputDecoration(hintText: "홍보 문구", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            _buildLabel("필수 재료"),
            TextField(controller: _ingredientsController, maxLines: 3, decoration: InputDecoration(hintText: "엔터로 구분", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            _buildLabel("조리 방법"),
            TextField(controller: _recipeController, maxLines: 8, decoration: InputDecoration(hintText: "조리법 작성", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            _buildLabel("총 비용"),
            TextField(controller: _costController, keyboardType: TextInputType.number, decoration: InputDecoration(suffixText: "원", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: _isLoading ? null : _uploadRecipe, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEdit ? "수정 완료" : "등록 완료", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  DecorationImage? _buildPreviewImage() {
    if (kIsWeb && _webImagePath != null) return DecorationImage(image: NetworkImage(_webImagePath!), fit: BoxFit.cover);
    if (!kIsWeb && _selectedImage != null) return DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover);
    if (widget.recipeForEdit?.imagePath != null) return DecorationImage(image: NetworkImage(widget.recipeForEdit!.imagePath!), fit: BoxFit.cover);
    return null;
  }
}