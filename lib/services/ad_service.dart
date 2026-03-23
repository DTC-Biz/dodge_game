import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ─────────────────────────────────────────────
  // 광고 ID
  // ─────────────────────────────────────────────
  static String get _interstitialAdUnitId {
  // 테스트 완료 후 실제 ID로 교체
  if (kDebugMode) {
    return Platform.isIOS
        ? 'ca-app-pub-3940256099942544/4411468910'  // iOS 테스트
        : 'ca-app-pub-3940256099942544/1033173712'; // Android 테스트
  }
  return Platform.isIOS
      ? 'ca-app-pub-6254209542168445/2715722543'
      : 'ca-app-pub-6254209542168445/8715956435';
}

static String get _rewardedAdUnitId {
  if (kDebugMode) {
    return Platform.isIOS
        ? 'ca-app-pub-3940256099942544/1712485313'  // iOS 테스트
        : 'ca-app-pub-3940256099942544/5224354917'; // Android 테스트
  }
  return Platform.isIOS
      ? 'ca-app-pub-6254209542168445/6281364782'
      : 'ca-app-pub-6254209542168445/2701212423';
}
  // ─────────────────────────────────────────────
  // 상태
  // ─────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;

  bool get isRewardedReady => _isRewardedReady;

  // ─────────────────────────────────────────────
  // 초기화
  // ─────────────────────────────────────────────
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // ─────────────────────────────────────────────
  // 전면 광고 (게임오버 시)
  // ─────────────────────────────────────────────
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (!_isInterstitialReady || _interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        loadInterstitialAd(); // 다음 광고 미리 로드
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        loadInterstitialAd();
        onAdDismissed?.call();
      },
    );

    _interstitialAd!.show();
  }

  // ─────────────────────────────────────────────
  // 보상형 광고 (+1회 플레이)
  // ─────────────────────────────────────────────
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
        },
      ),
    );
  }

  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onAdDismissed,
  }) {
    if (!_isRewardedReady || _rewardedAd == null) {
      onAdDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        loadRewardedAd(); // 다음 광고 미리 로드
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedReady = false;
        loadRewardedAd();
        onAdDismissed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(); // +1회 플레이 지급
      },
    );
  }

  // ─────────────────────────────────────────────
  // 정리
  // ─────────────────────────────────────────────
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
