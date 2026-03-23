import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/play_limit.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('인앱결제 준비 중이에요. 곧 이용 가능해요!'),
        backgroundColor: Color(0xFF1A1A2E),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _restorePurchase(BuildContext context) async {
    final isUnlimited = await PlayLimit.isUnlimited();
    if (!context.mounted) return;
    if (isUnlimited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 무제한 플레이가 활성화되어 있어요.'),
          backgroundColor: Color(0xFF1A2A1A),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복원할 구매 내역이 없어요.'),
          backgroundColor: Color(0xFF222222),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, foregroundColor: Colors.white),
      body: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(40)),
            child: const Center(child: Text('∞', style: TextStyle(color: Colors.white, fontSize: 36)))),
          const SizedBox(height: 24),
          const Text('무제한 플레이', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('₩1,000 영구 언락', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 32),
          Container(width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _BenefitRow(text: '횟수 제한 없음'), SizedBox(height: 10),
              _BenefitRow(text: '광고 없음'), SizedBox(height: 10),
              _BenefitRow(text: '영구 보관'),
            ])),
          const SizedBox(height: 32),
          // TODO: 인앱결제 연동 후 실결제 로직으로 교체
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => _showComingSoon(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF534AB7).withValues(alpha: 0.5),
                foregroundColor: Colors.white54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text('₩1,000 구매하기  (준비 중)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _restorePurchase(context),
            child: const Text('구매 복원', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ]),
      ))),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.check, color: Colors.white70, size: 16),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    ]);
  }
}
