import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe_model.dart';

class BattleWriteScreen extends StatefulWidget {
  const BattleWriteScreen({super.key});

  @override
  State<BattleWriteScreen> createState() => _BattleWriteScreenState();
}

class _BattleWriteScreenState extends State<BattleWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // --- 🧺 사진 바구니 분리 ---
  File? _cookingImage;    String? _webCookingPath;  XFile? _pickedCooking;   
  File? _receiptImage;    String? _webReceiptPath;  XFile? _pickedReceipt;   

  Future<void> _pickImage(bool isCooking) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        if (isCooking) {
          _pickedCooking = pickedFile;
          if (kIsWeb) _webCookingPath = pickedFile.path;
          else _cookingImage = File(pickedFile.path);
        } else {
          _pickedReceipt = pickedFile;
          if (kIsWeb) _webReceiptPath = pickedFile.path;
          else _receiptImage = File(pickedFile.path);
        }
      });
    }
  }

  // 🚀 서버 업로드 및 등록 함수
  Future<void> _submitBattleRecipe() async {
    // ✅ [쉼표 해결] 입력값에서 쉼표(,)를 모두 제거하고 숫자로 바꿉니다.
    final String cleanPrice = _priceController.text.replaceAll(',', '');
    final int? cost = int.tryParse(cleanPrice);
    
    bool hasCookingImg = kIsWeb ? _webCookingPath != null : _cookingImage != null;

    if (_titleController.text.isEmpty || !hasCookingImg || cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("완성 사진과 제목, 금액은 필수입니다! 📝")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String cookingUrl = await _uploadToStorage(_pickedCooking!, "cooking");
      String receiptUrl = "";
      if (_pickedReceipt != null) receiptUrl = await _uploadToStorage(_pickedReceipt!, "receipt");

      final newBattleRecipe = RecipeModel(
        title: "[참전] ${_titleController.text.trim()}",
        promo: "5,000원의 행복! 제 필살기 레시피를 공개합니다. 🔥",
        category: "혼밥",
        ingredients: ["편의점 꿀조합 재료"], 
        recipe: _recipeController.text.trim(),
        cost: cost,
        imagePath: cookingUrl, 
        authorId: "자취9단승규", 
        likesCount: 0,
        createdAt: DateTime.now(),
      );

      Map<String, dynamic> data = newBattleRecipe.toMap();
      data['receiptImagePath'] = receiptUrl; 

      await FirebaseFirestore.instance.collection('recipes').add(data);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("참전 등록 완료! 우승을 기원합니다 🙏")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("등록 실패: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String> _uploadToStorage(XFile xFile, String prefix) async {
    String fileName = "${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child('recipes/$fileName');
    if (kIsWeb) {
      Uint8List bytes = await xFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(xFile.path));
    }
    return await ref.getDownloadURL();
  }

  @override
  void dispose() {
    _titleController.dispose(); _priceController.dispose(); _recipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black,
        title: const Text("참전 신청서 📝", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitBattleRecipe,
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
              : const Text("제출", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildWarningBox(),
            const SizedBox(height: 30),
            _buildTextField("요리 이름 (필살기명)", _titleController, "예) 눈물 젖은 마라 치즈 밥"),
            const SizedBox(height: 30),
            _buildTextField("총 지출 금액 (원)", _priceController, "4,500", isNumber: true),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("증빙 자료", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 10),
            Row(children: [_buildPhotoBox("요리 완성샷 📸", true), const SizedBox(width: 15), _buildPhotoBox("영수증 인증 🧾", false)]),
            const SizedBox(height: 30),
            // ✅ 이제 여기서 시원하게 줄바꿈이 됩니다!
            _buildTextField("비법 전수 (레시피)", _recipeController, "조리 순서를 적어주세요.", maxLines: 5),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox(String text, bool isCooking) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _pickImage(isCooking),
        child: Container(
          height: 150, decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: _buildPreviewContent(text, isCooking),
        ),
      ),
    );
  }

  Widget _buildPreviewContent(String text, bool isCooking) {
    dynamic displayImage = isCooking ? (kIsWeb ? _webCookingPath : _cookingImage) : (kIsWeb ? _webReceiptPath : _receiptImage);
    if (displayImage != null) {
      return ClipRRect(borderRadius: BorderRadius.circular(12), child: kIsWeb ? Image.network(displayImage as String, fit: BoxFit.cover) : Image.file(displayImage as File, fit: BoxFit.cover));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo, color: Colors.grey), const SizedBox(height: 8), Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))]);
  }

  // ✅ [수정된 텍스트 필드] 엔터 줄바꿈 완벽 대응!
  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: maxLines > 1 ? TextInputType.multiline : (isNumber ? TextInputType.number : TextInputType.text),
          maxLines: maxLines,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
          decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[100]!)),
      child: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red), SizedBox(width: 10), Expanded(child: Text("총 재료비가 5,000원을 넘으면 자동으로 탈락 처리됩니다!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)))]),
    );
  }
}