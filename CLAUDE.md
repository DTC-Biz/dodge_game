# Dodge Game - 프로젝트 컨텍스트

## 프로젝트 개요
- **앱명**: Dodge Game
- **회사**: 다운타운컴퍼니 (대표)
- **Bundle ID**: com.downtowncompany.dodgegame
- **플랫폼**: iOS + Android (Flutter)
- **프로젝트 경로**: ~/Desktop/dodge_game
- **GitHub**: DTC-Biz/dodge_game
- **🚀 런칭일**: 2026년 5월 11일 (iOS + Android 동시)

## 앱 스펙
- 미니멀 지오메트릭 스타일, 배경 블랙
- 4방향 장애물 회피 게임
- 무료 플레이: 첫날 3회 / 이후 매일 1회
- 광고 보고 +1회 추가
- 무제한 플레이 ₩1,000 영구 언락
- Firebase 리더보드 (명예의전당 + 주간베스트)

## 기술 스택
- Flutter + Firebase (Firestore)
- Google AdMob (전면광고 + 보상형광고)
- SharedPreferences (로컬 저장)
- package_info_plus, in_app_purchase

## AdMob ID
- iOS App ID: ca-app-pub-6254209542168445~9541952945
- Android App ID: ca-app-pub-6254209542168445~2397960091
- iOS Interstitial: ca-app-pub-6254209542168445/2715722543
- iOS Rewarded: ca-app-pub-6254209542168445/6281364782
- Android Interstitial: ca-app-pub-6254209542168445/8715956435
- Android Rewarded: ca-app-pub-6254209542168445/2701212423
- 시뮬레이터 테스트 시 kDebugMode 조건으로 테스트 ID 사용

## Firebase
- 프로젝트: dodge-game-11aa7
- Firestore 컬렉션: hall_of_fame (역대), weekly_best (주간)
- 닉네임 기준으로 본인 최고기록만 유지
- 닉네임은 SharedPreferences에 저장 (key: user_nickname)

## 런칭 일정
```
3월 23일 ~ 3월 31일  → 코드 작업 마무리
4월  6일             → D-U-N-S 발급 예상
4월  7일 ~ 4월 10일  → Apple Developer 계정 등록
4월 11일 ~ 4월 14일  → 인앱결제 연동 + 빌드 테스트
4월 15일             → iOS + Android 스토어 동시 제출
4월 15일 ~ 5월 10일  → 심사 대기
5월 11일 (월)        → 🚀 iOS + Android 동시 런칭!
```

## 런칭 대회 일정
```
대회 기간: 5월 11일 ~ 5월 24일 (2주)
top3 상금: ₩100,000
결과 발표: 5월 25일 (월)
상금 지급: 5월 28일 (목)
```

## ✅ 완료된 작업
- [x] settings_screen.dart (설정화면)
- [x] legal_screen.dart (이용약관 + 개인정보처리방침) → 날짜 2026.05.11로 입력 필요
- [x] ad_service.dart (AdMob 전면 + 보상형 광고)
- [x] firebase_service.dart (리더보드 CRUD)
- [x] home_screen.dart (배경 파티클 애니메이션, 설정버튼)
- [x] gameover_screen.dart (닉네임 입력 + Firebase 등록 + 순위 표시)
- [x] game_screen.dart (광고 연동)
- [x] splash_screen.dart (다운타운컴퍼니 로고 로딩화면)
- [x] theme.dart (색감 개선)
- [x] 앱 아이콘 PNG 세트 적용 완료
- [x] Info.plist (GADApplicationIdentifier, SKAdNetworkItems)
- [x] GoogleService-Info.plist (Firebase iOS 연동)
- [x] Firestore 보안 규칙 설정
- [x] Google Play 개발자 계정 진행 중 (D-U-N-S 대기)

## ⬜ 미완료 작업 (우선순위 순)
- [ ] 이용약관/개인정보처리방침 날짜 → 2026년 5월 11일 입력
- [ ] 스크린샷 제작 (App Store / Google Play용)
- [ ] 점수 공유 이미지 카드
- [ ] 대회 기간 코드 반영 (5/11 ~ 5/24)
- [ ] 인앱결제 연동 (Apple Developer 계정 필요 - D-U-N-S 신청 완료)
- [ ] Android google-services.json 확인
- [ ] 부정행위 감지 로직
- [ ] 앱 설명문 (한국어 + 영어)
- [ ] 게임물등급분류

## 주요 파일 구조
```
lib/
  main.dart
  screens/
    splash_screen.dart
    home_screen.dart
    game_screen.dart
    gameover_screen.dart
    leaderboard_screen.dart
    settings_screen.dart
    legal_screen.dart
    paywall_screen.dart
  services/
    firebase_service.dart
    ad_service.dart
  game/
    player.dart, obstacle.dart, collision.dart, score_manager.dart
  utils/
    theme.dart, difficulty.dart, constants.dart, play_limit.dart
assets/
  images/
    DTC-Simple.png
```

## 코딩 컨벤션
- 배경색: #090909 (AppTheme.background)
- 포인트색: #E63946 (레드), #7B9CFF (블루), #9F99F0 (퍼플)
- 모든 화면 블랙 배경 유지, 미니멀 스타일, 한국어 UI

## 개발 루틴
```bash
# 출근
cd ~/Desktop/dodge_game && git pull origin main && open ios/Runner.xcworkspace

# 퇴근
cd ~/Desktop/dodge_game && git add . && git commit -m "내용" && git push
```
