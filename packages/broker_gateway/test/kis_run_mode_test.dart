// 🆕 E15a — 실행 모드 → 브로커 · KIS 환경 대응(02 §4 v2.44 `brokerKindFor` · 01 §9-3 키 봉인 · 설계 13 §8 R81 V6).

import 'package:broker_gateway/broker_gateway.dart';
import 'package:domain_contracts/domain_contracts.dart' show RunMode;
import 'package:test/test.dart';

// 🔴 가짜 값 — 실제 키 · 계좌가 아니다.
KisCredentials _creds(KisEnvironment env) => KisCredentials(
  environment: env,
  appKey: 'test-app-key',
  appSecret: 'test-app-secret',
  accountNo: '00000000',
);

void main() {
  test('주문 상대 = 내부 시뮬레이터 · KIS 모의 · KIS 실전(망라)', () {
    expect(brokerKindFor(RunMode.simInternal), BrokerKind.internalSimulator);
    expect(brokerKindFor(RunMode.simBroker), BrokerKind.kisMock);
    expect(brokerKindFor(RunMode.live), BrokerKind.kisLive);
  });

  test('기대 환경 = SIM 두 갈래 모의(내부 시뮬레이터도 시세 = 모의 앱키) · live = 실전', () {
    expect(kisEnvironmentFor(RunMode.simInternal), KisEnvironment.mock);
    expect(kisEnvironmentFor(RunMode.simBroker), KisEnvironment.mock);
    expect(kisEnvironmentFor(RunMode.live), KisEnvironment.live);
  });

  test('🔴 SIM 기동에 실전 자격증명 = 맞지 않음 · live 에 모의 자격증명 = 맞지 않음', () {
    final KisCredentials mock = _creds(KisEnvironment.mock);
    final KisCredentials live = _creds(KisEnvironment.live);
    expect(kisCredentialsFit(mock, RunMode.simInternal), isTrue);
    expect(kisCredentialsFit(mock, RunMode.simBroker), isTrue);
    expect(kisCredentialsFit(mock, RunMode.live), isFalse);
    expect(kisCredentialsFit(live, RunMode.simInternal), isFalse);
    expect(kisCredentialsFit(live, RunMode.simBroker), isFalse);
    expect(kisCredentialsFit(live, RunMode.live), isTrue);
  });
}
