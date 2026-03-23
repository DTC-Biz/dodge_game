import 'package:flutter/material.dart';

enum LegalType { terms, privacy }

class LegalScreen extends StatelessWidget {
  final LegalType type;
  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalType.terms;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          isTerms ? '이용약관' : '개인정보처리방침',
          style: const TextStyle(
            fontFamily: 'monospace',
            letterSpacing: 2,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: isTerms ? _buildTerms() : _buildPrivacy(),
      ),
    );
  }

  Widget _buildTerms() {
    return _LegalContent(
      title: '이용약관',
      effectiveDate: '2026년 5월 11일',
      sections: [
        _LegalSection(
          heading: '제1조 (목적)',
          body: '이 약관은 다운타운컴퍼니(이하 "회사")가 제공하는 닷지게임(DODGE GAME) 애플리케이션(이하 "서비스") 이용에 관한 조건 및 절차, 회사와 이용자의 권리·의무·책임사항을 규정함을 목적으로 합니다.',
        ),
        _LegalSection(
          heading: '제2조 (서비스 내용)',
          body: '회사는 다음의 서비스를 제공합니다.\n① 장애물 회피 캐주얼 게임 서비스\n② 온라인 리더보드(명예의전당, 주간베스트) 서비스\n③ 무제한 플레이 인앱결제 서비스 (₩1,000 영구 언락)\n④ 기타 회사가 추가 개발하거나 제휴를 통해 제공하는 서비스',
        ),
        _LegalSection(
          heading: '제3조 (이용 조건 및 제한)',
          body: '① 서비스는 기본적으로 무료로 제공됩니다. 단, 일부 유료 기능은 별도의 결제가 필요합니다.\n② 무료 이용자는 첫날 3회, 이후 매일 1회 무료 플레이가 제공됩니다.\n③ 부정행위, 핵, 점수 조작 등이 확인될 경우 리더보드에서 즉시 제외됩니다.\n④ 회사는 서비스 운영 상 필요한 경우 사전 고지 없이 서비스 내용을 변경할 수 있습니다.',
        ),
        _LegalSection(
          heading: '제4조 (인앱결제)',
          body: '① 무제한 플레이 언락(₩1,000)은 1회 결제로 영구 제공됩니다.\n② 결제는 Apple App Store 또는 Google Play 결제 정책을 따릅니다.\n③ 결제 관련 환불은 각 스토어 정책에 따릅니다.',
        ),
        _LegalSection(
          heading: '제5조 (면책조항)',
          body: '① 회사는 천재지변, 시스템 장애 등 불가항력으로 인한 서비스 중단에 대해 책임지지 않습니다.\n② 이용자의 귀책 사유로 인한 서비스 이용 장애에 대해서는 회사가 책임지지 않습니다.',
        ),
        _LegalSection(
          heading: '제6조 (준거법 및 분쟁 해결)',
          body: '본 약관은 대한민국 법률에 따라 해석되며, 분쟁 발생 시 회사의 주소지를 관할하는 법원을 관할법원으로 합니다.',
        ),
        _LegalSection(
          heading: '부칙',
          body: '이 약관은 2026년 5월 11일부터 시행됩니다.',
        ),
      ],
    );
  }

  Widget _buildPrivacy() {
    return _LegalContent(
      title: '개인정보처리방침',
      effectiveDate: '2026년 5월 11일',
      sections: [
        _LegalSection(
          heading: '1. 수집하는 개인정보 항목',
          body: '[필수 수집 항목]\n• 닉네임 (리더보드 등록 시 이용자가 직접 입력)\n• 게임 플레이 기록 (점수, 플레이 횟수)\n• 기기 정보 (OS 버전, 기기 모델명)\n\n[자동 수집 항목]\n• Firebase Analytics를 통한 앱 사용 통계 (익명화 처리)\n• AdMob을 통한 광고 식별자 (광고 제공 목적)',
        ),
        _LegalSection(
          heading: '2. 개인정보 수집 및 이용 목적',
          body: '• 리더보드 운영 및 순위 표시\n• 서비스 품질 개선 및 오류 분석\n• 맞춤형 광고 제공 (AdMob)\n• 대회 운영 및 상금 지급 (이벤트 기간 한정)',
        ),
        _LegalSection(
          heading: '3. 개인정보 보유 및 이용 기간',
          body: '• 리더보드 닉네임 및 점수: 서비스 운영 기간 동안 보관\n• 대회 참가 정보: 대회 종료 후 6개월\n• 법령에 의해 보존이 필요한 경우 해당 기간 동안 보관',
        ),
        _LegalSection(
          heading: '4. 개인정보의 제3자 제공',
          body: '회사는 원칙적으로 이용자의 개인정보를 외부에 제공하지 않습니다. 단, 다음의 경우는 예외입니다.\n• 이용자가 사전에 동의한 경우\n• 법령의 규정에 의거하거나 수사기관의 요구가 있는 경우',
        ),
        _LegalSection(
          heading: '5. 외부 서비스 이용',
          body: '• Firebase (Google LLC): 리더보드, 인증, 분석\n• Google AdMob: 광고 제공\n각 서비스의 개인정보처리방침은 해당 회사 웹사이트에서 확인하실 수 있습니다.',
        ),
        _LegalSection(
          heading: '6. 이용자의 권리',
          body: '이용자는 언제든지 다음 권리를 행사할 수 있습니다.\n• 개인정보 조회 및 수정 요청\n• 개인정보 삭제 요청 (리더보드 기록 삭제)\n• 개인정보 처리 정지 요청\n\n문의: contact@downtowncompany.kr',
        ),
        _LegalSection(
          heading: '7. 개인정보 보호책임자',
          body: '책임자: 다운타운컴퍼니 대표\n이메일: contact@downtowncompany.kr',
        ),
        _LegalSection(
          heading: '부칙',
          body: '이 방침은 2026년 5월 11일부터 시행됩니다.',
        ),
      ],
    );
  }
}

class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection({required this.heading, required this.body});
}

class _LegalContent extends StatelessWidget {
  final String title;
  final String effectiveDate;
  final List<_LegalSection> sections;

  const _LegalContent({
    required this.title,
    required this.effectiveDate,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          effectiveDate,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 24),
        ...sections.map((s) => _buildSection(s)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection(_LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
