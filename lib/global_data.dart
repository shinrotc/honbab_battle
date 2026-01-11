import 'models/recipe_model.dart';

// 앱 전체에서 공통으로 사용하는 카테고리 명단이야.
const List<String> categories = ["전체", "혼밥", "다이어트", "혼술안주"];

// [통일] 모든 샘플 데이터에 promo를 넣었고, 깨진 404 사진 주소를 최신 주소로 바꿨어.
List<RecipeModel> allRecipes = [
  RecipeModel(
    title: "불닭+치즈+소시지 조합",
    promo: "편의점 최고의 맵단 조합! 🔥",
    category: "혼밥",
    recipe: "면 익히고 물 버리기\n소스와 재료 섞기\n전자레인지 2분 돌리기",
    cost: 4200,
    ingredients: ["불닭볶음면", "소시지", "치즈"],
    // [수정] 404 에러가 나지 않는 고화질 Unsplash 이미지 주소야.
    imagePath: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800",
  ),
];
