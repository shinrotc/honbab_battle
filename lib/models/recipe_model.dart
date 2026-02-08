import 'package:cloud_firestore/cloud_firestore.dart';

// 요리 데이터를 담는 바구니의 표준 설계도 (서버 연동형)
class RecipeModel {
  final String? id;          // 서버에서 부여하는 고유 번호 (수정/삭제 시 필요)
  final String title;       // 요리 이름
  final String promo;       // 매력적인 한 줄 홍보 문구
  final String category;    // 카테고리 (혼밥, 다이어트 등)
  final String recipe;      // 조리법 텍스트
  final int cost;           // 예상 비용
  final List<String> ingredients; // 재료 리스트
  final String? imagePath;  // 사진 경로 (URL)
  final String? authorId;   // 작성자 고유 ID (플랫폼 관리를 위해 추가)
  final int likesCount;     // 좋아요/투표 수 (랭킹 시스템용)
  final DateTime? createdAt; // 작성 시간 (최신순 정렬용)

  RecipeModel({
    this.id,
    required this.title,
    required this.promo,
    required this.category,
    required this.recipe,
    required this.cost,
    required this.ingredients,
    this.imagePath,
    this.authorId,
    this.likesCount = 0,    // 처음 만들 때는 기본 0개
    this.createdAt,
  });

  // 📦 1. [포장하기] 앱의 데이터를 파이어베이스 창고로 보낼 때 사용 (Map으로 변환)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'promo': promo,
      'category': category,
      'recipe': recipe,
      'cost': cost,
      'ingredients': ingredients,
      'imagePath': imagePath,
      'authorId': authorId,
      'likesCount': likesCount,
      // 서버에 저장되는 순간의 시간을 기록해!
      'createdAt': createdAt ?? FieldValue.serverTimestamp(), 
    };
  }

  // 🎁 2. [포장뜯기] 서버 창고에서 가져온 데이터를 앱에서 읽을 때 사용 (Model로 변환)
  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '제목 없음',
      promo: map['promo'] ?? '',
      category: map['category'] ?? '일반',
      recipe: map['recipe'] ?? '',
      cost: map['cost'] ?? 0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      imagePath: map['imagePath'],
      authorId: map['authorId'],
      likesCount: map['likesCount'] ?? 0,
      // 서버의 Timestamp를 앱의 DateTime으로 변환해줘
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}