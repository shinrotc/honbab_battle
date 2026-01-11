// 요리 데이터를 담는 바구니의 표준 설계도야.
class RecipeModel {
  final String title;      // 요리 이름
  final String promo;      // 홈 화면 피드에 보여줄 매력적인 한 줄 홍보 문구
  final String category;   // 요리 카테고리 (혼밥, 다이어트, 혼술안주 등)
  final String recipe;     // 줄바꿈(\n)으로 구분된 전체 조리법 텍스트
  final int cost;          // 예상 소요 비용 (원)
  final List<String> ingredients; // 필요한 재료들 리스트
  final String? imagePath; // 사진의 경로 (인터넷 주소 또는 기기 내 경로)

  RecipeModel({
    required this.title,
    required this.promo,
    required this.category,
    required this.recipe,
    required this.cost,
    required this.ingredients,
    this.imagePath,
  });
}