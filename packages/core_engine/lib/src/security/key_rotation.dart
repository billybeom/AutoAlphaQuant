// 키 회전(설계 13 §8 R44 E5 · 06 M4-4 «키 회전 마법사 — 검증 통과 전 구키 폐기 불가»).
//
// 🔴 구키는 새 키의 검증이 통과한 뒤에만 버린다 — 새 키가 틀렸는데 구키가 없으면 매매가 멈춘다.
// 🔴 새 값은 본 칸을 덮기 **전에** 임시 칸에 먼저 둔다 — 검증 도중 끊겨도 구키 · 새 키 둘 다 남는다.
// 🔵 화면 마법사(M9 S02)는 [KeyRotation] 의 상태를 그린다 — 단계 문장 · 버튼은 화면 몫.

import 'secret_vault.dart';

/// 회전 단계.
enum KeyRotationStage {
  /// 구키만 쓴다.
  idle,

  /// 새 키를 받아 두었다(검증 전).
  staged,

  /// 새 키 검증 실패 — 구키 그대로 · 다시 받거나 그만둔다.
  failed,

  /// 새 키 검증 통과 — 확정할 수 있다.
  verified,

  /// 확정 — 이제 구키를 버려도 된다.
  committed,
}

/// 회전 상태기계(순수 · 지문만 지닌다 — 값 0).
class KeyRotation {
  /// [currentFingerprint] = 지금 쓰는 키의 지문.
  KeyRotation(this.currentFingerprint);

  /// 지금 쓰는 키의 지문.
  String currentFingerprint;

  /// 받아 둔 새 키의 지문.
  String? stagedFingerprint;

  /// 단계.
  KeyRotationStage stage = KeyRotationStage.idle;

  /// 새 키를 받는다 — idle · failed 에서만 · 구키와 같으면 ArgumentError.
  void stageNew(String newFingerprint) {
    if (stage != KeyRotationStage.idle && stage != KeyRotationStage.failed) {
      throw StateError('새 키는 idle · failed 에서만 받는다(지금 ${stage.name})');
    }
    if (newFingerprint == currentFingerprint) {
      throw ArgumentError('새 키가 구키와 같다');
    }
    stagedFingerprint = newFingerprint;
    stage = KeyRotationStage.staged;
  }

  /// 검증 결과 — staged 에서만.
  void recordVerification({required bool passed}) {
    if (stage != KeyRotationStage.staged) {
      throw StateError('검증은 staged 에서만 기록한다(지금 ${stage.name})');
    }
    stage = passed ? KeyRotationStage.verified : KeyRotationStage.failed;
  }

  /// 확정 — 🔴 verified 에서만(검증 통과 전 구키 폐기 불가).
  void commit() {
    if (stage != KeyRotationStage.verified) {
      throw StateError('검증 통과 전에는 확정할 수 없다(지금 ${stage.name})');
    }
    currentFingerprint = stagedFingerprint!;
    stagedFingerprint = null;
    stage = KeyRotationStage.committed;
  }

  /// 그만둔다 — 새 키를 버리고 구키로(committed 뒤에는 못 한다).
  void abort() {
    if (stage == KeyRotationStage.committed) {
      throw StateError('확정 뒤에는 그만둘 수 없다');
    }
    stagedFingerprint = null;
    stage = KeyRotationStage.idle;
  }

  /// 구키를 버려도 되나 — committed 뿐.
  bool get canDiscardOld => stage == KeyRotationStage.committed;
}

/// 금고 회전 결과.
enum RotationOutcome {
  /// 새 키로 바꿨다.
  committed,

  /// 검증이 거절했다 — 구키 그대로.
  verifyRejected,

  /// 검증이 예외를 냈다 — 구키 그대로.
  verifyError,
}

/// 임시 칸 이름 — `{id}.staged`.
SecretId stagedSecretId(SecretId id) => SecretId('${id.value}.staged');

/// [id] 의 값을 [newValue] 로 회전한다(R44 E5).
///
/// 순서: ① 새 값을 임시 칸에 쓴다 ② [verify] ③ 통과 = 본 칸 덮기 → 임시 칸 삭제 · 거절 · 예외 = 임시 칸만 삭제.
/// 🔴 본 칸은 ③ 통과 전에 건드리지 않는다. 같은 값 = ArgumentError · 본 칸이 비었으면 StateError(회전이 아니다).
/// 🔴 [verify] 예외의 내용은 결과에 싣지 않는다(값이 섞였을 수 있다).
Future<RotationOutcome> rotateSecret(
  SecretVault vault,
  SecretId id,
  String newValue, {
  required Future<bool> Function(String candidate) verify,
}) async {
  final String? old = await vault.read(id);
  if (old == null) throw StateError('${id.value}: 회전할 구키가 없다');
  if (old == newValue) throw ArgumentError('새 값이 구키와 같다');
  final SecretId staged = stagedSecretId(id);
  await vault.write(staged, newValue);
  bool passed;
  try {
    passed = await verify(newValue);
  } on Object {
    await vault.delete(staged);
    return RotationOutcome.verifyError;
  }
  if (!passed) {
    await vault.delete(staged);
    return RotationOutcome.verifyRejected;
  }
  await vault.write(id, newValue);
  await vault.delete(staged);
  return RotationOutcome.committed;
}
