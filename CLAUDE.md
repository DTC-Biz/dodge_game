# Dodge Game - 프로젝트 컨텍스트

## 프로젝트 개요
- **앱명**: Dodge Game
- **회사**: 다운타운컴퍼니 (대표)
- **Bundle ID**: com.downtowncompany.dodgegame
- **플랫폼**: iOS + Android (Flutter)
- **프로젝트 경로**: ~/Desktop/dodge_game
- **GitHub**: DTC-Biz/dodge_game
- **🚀 런칭일**: 2026년 5월 11일 (iOS + Android 동시)
- **현재 버전**: 1.0.0+2

## 앱 스펙
- 미니멀 지오메트릭 스타일, 배경 블랙
- 4방향 장애물 회피 게임
- 무료 플레이: 첫날 3회 / 이후 매일 **2회**
- 광고 보고 +1회 추가
- 무제한 플레이 ₩1,000 영구 언락 (인앱결제 연동 후 활성화)
- Firebase 리더보드 (명예의전당 + 주간베스트)

## 기술 스택
- Flutter + Firebase (Firestore)
- Google AdMob (전면광고 + 보상형광고)
- SharedPreferences (로컬 저장)
- package_info_plus, in_app_purchase
- share_plus, path_provider (점수 공유 이미지 카드)

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
- 주간 key: ISO 8601 기준 (firebase_service.dart _weekKey)

## 런칭 일정
```
3월 23일 ~ 3월 31일  → 코드 작업 마무리 ✅ (2026-03-23 완료)
4월  6일             → D-U-N-S 발급 예상 (신청 완료)
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

## Android 빌드 설정
- applicationId: `com.downtowncompany.dodgegame` (build.gradle.kts 수정 완료)
- google-services 플러그인: settings.gradle.kts + app/build.gradle.kts 에 추가 완료
- APK 빌드: `flutter build apk --debug`
- APK 경로: `build/app/outputs/flutter-apk/app-debug.apk`

## ✅ 완료된 작업
- [x] settings_screen.dart (설정화면)
- [x] legal_screen.dart (이용약관 + 개인정보처리방침) → 날짜 2026.05.11 적용 완료
- [x] ad_service.dart (AdMob 전면 + 보상형 광고)
- [x] firebase_service.dart (리더보드 CRUD, ISO 8601 주간 key, 부정행위 감지)
- [x] home_screen.dart (배경 파티클, 설정버튼, 대회 배너, 조작 안내)
- [x] gameover_screen.dart (닉네임 입력 + Firebase 등록 + 역대/주간 순위 동시 표시)
- [x] game_screen.dart (광고 연동, 일시정지, 앱 생명주기, 공유 이미지 카드)
- [x] leaderboard_screen.dart (대회 배너, 내 닉네임 하이라이트)
- [x] splash_screen.dart (다운타운컴퍼니 로고 로딩화면)
- [x] paywall_screen.dart (구매 준비 중 처리, 구매 복원 기능)
- [x] theme.dart (색감 개선)
- [x] 앱 아이콘 PNG 세트 적용 완료
- [x] Info.plist (GADApplicationIdentifier, SKAdNetworkItems)
- [x] GoogleService-Info.plist (Firebase iOS 연동)
- [x] android/app/google-services.json (Firebase Android 연동)
- [x] AndroidManifest.xml (AdMob meta-data 오류 수정)
- [x] android/app/build.gradle.kts (applicationId 수정, google-services 플러그인 추가)
- [x] android/settings.gradle.kts (google-services 플러그인 등록)
- [x] Android APK 디버그 빌드 확인
- [x] 부정행위 감지 (wall-clock 검증, 최소/최대 점수 차단)
- [x] 앱 설명문 작성 (한국어 + 영어) → 스토어 등록 시 사용
- [x] 게임물등급분류 가이드 → IARC 자체등급분류로 처리 (별도 신청 불필요)

## ⬜ 미완료 작업 (우선순위 순)
- [ ] **인앱결제 연동** (Apple Developer 계정 승인 후) → paywall_screen.dart TODO 참고
- [ ] **스크린샷 제작** (App Store / Google Play용) → 실기기/시뮬레이터 캡처 필요
- [ ] **효과음 추가** → sound_manager.dart 파일 존재, 연결 미완료

## 인앱결제 연동 시 작업 목록
```
1. paywall_screen.dart → 구매 버튼 실결제 로직으로 교체 (TODO 주석 위치)
2. play_limit.dart → setUnlimited() 는 결제 완료 콜백에서만 호출
3. in_app_purchase 패키지 이미 pubspec.yaml에 포함됨
4. Apple: App Store Connect에서 IAP 상품 등록 (dodge_unlimited, ₩1,000)
5. Android: Google Play Console에서 인앱 상품 등록
```

## 주요 파일 구조
```
lib/
  main.dart
  screens/
    splash_screen.dart
    home_screen.dart
    game_screen.dart          # 일시정지, 공유카드, 생명주기
    gameover_screen.dart      # 역대+주간 순위 동시 표시
    leaderboard_screen.dart   # 내 닉네임 하이라이트
    settings_screen.dart
    legal_screen.dart
    paywall_screen.dart       # IAP 연동 전 비활성화 상태
  services/
    firebase_service.dart     # 부정행위 검증 포함
    ad_service.dart
  game/
    player.dart, obstacle.dart, collision.dart, score_manager.dart
  utils/
    theme.dart, difficulty.dart, constants.dart, play_limit.dart
    sound_manager.dart        # 미연결 (효과음 추가 시 연동 필요)
assets/
  images/
    DTC-Simple.png
```

## 코딩 컨벤션
- 배경색: #090909 (AppTheme.background)
- 포인트색: #E63946 (레드), #7B9CFF (블루), #9F99F0 (퍼플)
- 모든 화면 블랙 배경 유지, 미니멀 스타일, 한국어 UI
- Color.withOpacity 사용 금지 → withValues(alpha:) 사용

## 개발 루틴
```bash
# 출근
cd ~/Desktop/dodge_game && git pull origin main && open ios/Runner.xcworkspace

# 퇴근
cd ~/Desktop/dodge_game && git add . && git commit -m "내용" && git push
```
