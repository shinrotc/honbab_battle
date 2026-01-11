import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // [1] 상단 앱바
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("알림", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // '모두 읽음' 같은 기능이 들어갈 자리 (지금은 텍스트만)
          TextButton(
            onPressed: () {}, 
            child: const Text("모두 읽음", style: TextStyle(color: Colors.grey))
          )
        ],
      ),

      // [2] 알림 리스트
      body: ListView.separated(
        padding: const EdgeInsets.all(0),
        itemCount: 8, // 샘플 알림 8개
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF5F5F5)), // 연한 회색 구분선
        itemBuilder: (context, index) {
          // 샘플 데이터를 위한 로직 (순서에 따라 다른 알림 보여주기)
          if (index == 0) {
            return _buildNotificationItem(
              icon: Icons.emoji_events, 
              iconColor: Colors.orange, 
              title: "축하합니다! 🏆", 
              message: "승규님이 '전설의 마라 마스터' 칭호를 획득하셨습니다.", 
              time: "방금 전",
              isUnread: true
            );
          } else if (index == 1) {
            return _buildNotificationItem(
              icon: Icons.favorite, 
              iconColor: Colors.red, 
              title: "좋아요 알림", 
              message: "누군가 내 '치즈 폭탄 라면' 레시피를 좋아합니다.", 
              time: "10분 전",
              isUnread: true
            );
          } else if (index == 2) {
            return _buildNotificationItem(
              icon: Icons.local_fire_department, 
              iconColor: Colors.deepOrange, 
              title: "새로운 배틀 시작! 🔥", 
              message: "이번 주 주제는 '냉장고 파먹기'입니다. 지금 참전해보세요!", 
              time: "1시간 전",
              isUnread: false
            );
          } else {
            // 나머지 더미 데이터
            return _buildNotificationItem(
              icon: Icons.comment, 
              iconColor: Colors.blue, 
              title: "새 댓글이 달렸습니다", 
              message: "맛있어 보이네요! 레시피 공유 감사합니다 ^^", 
              time: "어제",
              isUnread: false
            );
          }
        },
      ),
    );
  }

  // 알림 아이템 디자인 함수
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      color: isUnread ? const Color(0xFFFFF9F0) : Colors.white, // 안 읽은 알림은 살짝 연한 오렌지 배경
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 22,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (isUnread)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )
          ],
        ),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: isUnread ? FontWeight.bold : FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
        onTap: () {
          // 알림 클릭 시 이동 기능 (나중에 구현)
        },
      ),
    );
  }
}