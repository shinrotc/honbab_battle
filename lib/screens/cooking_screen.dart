import 'package:flutter/material.dart';
import 'dart:async';

class CookingScreen extends StatefulWidget {
  // [중요] 외부에서 요리 순서 데이터를 받아오도록 구멍을 뚫어둠!
  final List<Map<String, dynamic>> steps;

  const CookingScreen({super.key, required this.steps});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  // 타이머 변수들
  Timer? _timer;
  int _remainingTime = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer(int duration) {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      if (_remainingTime == 0) _remainingTime = duration;
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _isTimerRunning = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("⏰ 시간이 다 됐어요!")),
            );
          }
        });
      });
    }
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 이제 widget.steps 로 외부에서 받은 데이터를 사용함!
    final steps = widget.steps; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / steps.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                "${_currentIndex + 1} / ${steps.length}",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _remainingTime = 0;
            _timer?.cancel();
            _isTimerRunning = false;
          });
        },
        itemBuilder: (context, index) {
          final step = steps[index];
          final hasTimer = step['timer'] > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "STEP ${index + 1}", // 순서는 자동으로 1, 2, 3...
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2.0),
                ),
                const SizedBox(height: 30),
                Text(
                  step['text'], // 받아온 텍스트 표시
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4, color: Colors.black87),
                ),
                const SizedBox(height: 50),
                if (hasTimer)
                  GestureDetector(
                    onTap: () => _toggleTimer(step['timer']),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isTimerRunning ? Colors.orange[50] : Colors.grey[50],
                        border: Border.all(color: _isTimerRunning ? Colors.orange : Colors.grey[300]!, width: 4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow, size: 40, color: _isTimerRunning ? Colors.orange : Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            _remainingTime == 0 && !_isTimerRunning ? _formatTime(step['timer']) : _formatTime(_remainingTime),
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _isTimerRunning ? Colors.orange : Colors.grey[400], fontFamily: "monospace"),
                          ),
                          const SizedBox(height: 5),
                          Text(_isTimerRunning ? "일시정지" : "타이머 시작", style: TextStyle(fontSize: 12, color: _isTimerRunning ? Colors.orange : Colors.grey))
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("이전", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                )
              else
                const Spacer(flex: 1),
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < steps.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("요리 완성! 🍽️")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_currentIndex == steps.length - 1 ? "요리 완성! 🎉" : "다음 단계 >", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}