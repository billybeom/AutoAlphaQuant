// 플랫폼 채널 이름(E11p · 설계 e11p-map P5).
//
// 🔴 Kotlin `OperatorChannels` 와 같은 글자다 — 바꾸면 양쪽을 한 커밋에서 바꾼다.
// 🔴 오류는 코드만 건너온다(message · details 는 읽지 않는다) — 값 · 경로가 Dart 문자열에 섞이지 않게.

/// 채널 이름.
abstract final class OperatorChannelNames {
  /// 키 금고(`SecretVault`).
  static const String vault = 'aaq/vault';

  /// 봉함(`SealedBox`).
  static const String sealedBox = 'aaq/sealed_box';

  /// 🆕 E11p2 — 운영(FGS 알림 · 정확 알람 · 깨어남 · 자가진단).
  static const String ops = 'aaq/ops';
}

/// 🆕 E11p2 — FGS 채널 표시 이름(OS 알림 설정에 보이는 **정적 라벨** · 사유 문구가 아니다).
///
/// 키 = `FgsChannel.id`(trading_runtime) — 글자 대조 시험이 묶는다.
const Map<String, String> kOpsChannelNames = <String, String>{
  'ops_status': '운영 상태',
  'ops_p0': '긴급 알림(P0)',
};

/// Kotlin 이 보내는 오류 코드.
abstract final class OperatorChannelCodes {
  /// 인자 꼴이 틀렸다.
  static const String badArgs = 'bad_args';

  /// 금고 칸 이름 꼴이 아니다.
  static const String badId = 'bad_id';

  /// 금고 칸을 열 수 없다(키 소실 · 변조 · 판).
  static const String unreadable = 'unreadable';

  /// Keystore 를 지금 쓸 수 없다.
  static const String unavailable = 'unavailable';

  /// 파일 입출력 실패.
  static const String io = 'io';

  /// 봉함 실패.
  static const String sealFailed = 'seal_failed';
}
