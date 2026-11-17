// X1 끼울 자리(E16t2a · 설계 13 §8 R141 V2~V6 · R139 U2 · U3 · SPEC v2.45 04 §3-1 ①②).
//
// 🔴 켜짐 = 기기 id 있음 ∧ live 파일(X1 = live 만 — 모의 파일에는 이전 표가 없다) · 그 밖 = 꺼짐 = 지금과 같다
//    (감싸기 0 · 백업 갭 null · 봉인 0 · 거부 0).
// 🔴 판정은 data_sync 가 한다 — `x1StartupOf` · `MigrationAwareLeaseGate` · `recoveryBackupGapDaysOf`. 여기는 잇기만.
// 🟡 기기 id 원천(백업 제외 자리) · 신뢰 시각 실물 = E16t2b · E11k.

import 'package:core_engine/core_engine.dart' show LeaseGate, TrustedClock;
import 'package:data_sync/data_sync.dart'
    show
        MigrationAwareLeaseGate,
        SqliteLeaseGate,
        SqliteMigrationJournal,
        recoveryBackupGapDaysOf,
        x1StartupOf;
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:sqlite3/sqlite3.dart' show Database;

/// 주문 봉인 — 새 폰 복원 뒤 갭 재구성 전(주문 잡 앞에서 던진다 → 잡 FAILED · 브로커 0).
class X1OrderSealed implements Exception {
  /// 만든다.
  const X1OrderSealed(this.code);

  /// 봉인 코드(`X1_RECOVERY_IN_PROGRESS`).
  final String code;

  @override
  String toString() => 'X1OrderSealed: $code';
}

/// X1 끼울 자리 한 벌(원장 하나).
class X1Wiring {
  X1Wiring._(this._db, this.journal);

  /// 만든다 — 기기 id 없음 · live 아님 = 꺼짐.
  factory X1Wiring.of(
    Database db, {
    required RunMode runMode,
    required String? deviceId,
    required TrustedClock trusted,
    required SqliteLeaseGate lease,
  }) => X1Wiring._(
    db,
    deviceId == null || runMode != RunMode.live
        ? null
        : SqliteMigrationJournal(
            db,
            deviceId: deviceId,
            trusted: trusted,
            lease: lease,
          ),
  );

  final Database _db;

  /// 이 기기 이전 저널(꺼짐 = null).
  final SqliteMigrationJournal? journal;

  /// 켜졌나.
  bool get on => journal != null;

  /// 🔴 기동 거부 코드(꺼짐 = 빈 목록).
  List<String> bootRefusals() {
    final SqliteMigrationJournal? j = journal;
    return j == null ? const <String>[] : x1StartupOf(_db, j).refusals;
  }

  /// 🔴 주문용 리스(꺼짐 = [base] 그대로 · 켜짐 = 동결 중 INVALID).
  LeaseGate orderLease(LeaseGate base) {
    final SqliteMigrationJournal? j = journal;
    return j == null ? base : MigrationAwareLeaseGate(base, j);
  }

  /// 🔴 재개 백업 갭(꺼짐 · 복구 없음 = null).
  int? backupGapDays() {
    final SqliteMigrationJournal? j = journal;
    return j == null ? null : recoveryBackupGapDaysOf(_db, j.deviceId);
  }

  /// 🔴 주문 봉인 — 있으면 [X1OrderSealed] 를 던진다(꺼짐 = 그냥 지나간다).
  void checkOrderSeal() {
    final SqliteMigrationJournal? j = journal;
    if (j == null) return;
    final String? seal = x1StartupOf(_db, j).orderSeal;
    if (seal != null) throw X1OrderSealed(seal);
  }
}
