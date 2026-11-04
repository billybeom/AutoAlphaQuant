// E11i — 스키마 버전 게이트(설계 13 §8 R53 I4 · 지도 D17 · 04 M8 §2-4).
import 'package:domain_contracts/domain_contracts.dart'
    show contractVersion, hashFormatVersion, schemaVersion;
import 'package:read_model_client/read_model_client.dart';
import 'package:test/test.dart';

ReadModelVersionStamp _s(int schema, int hash, String contract) =>
    ReadModelVersionStamp(
      schemaVersion: schema,
      hashFormatVersion: hash,
      contractVersion: ContractVersion.tryParse(contract)!,
    );

void main() {
  final ReadModelVersionStamp local = _s(3, 2, '1.16.4');

  group('readModelGate(D17)', () {
    test('같음 · patch 차이 · 원격 minor 가 작음 = ok', () {
      expect(readModelGate(_s(3, 2, '1.16.4'), local: local), ReadModelGate.ok);
      expect(readModelGate(_s(3, 2, '1.16.0'), local: local), ReadModelGate.ok);
      expect(readModelGate(_s(3, 2, '1.16.9'), local: local), ReadModelGate.ok);
      expect(
        readModelGate(_s(3, 2, '1.15.99'), local: local),
        ReadModelGate.ok,
      );
      expect(readModelGate(_s(3, 2, '1.0.0'), local: local), ReadModelGate.ok);
    });

    test('원격 minor 가 더 큼 = degraded', () {
      expect(
        readModelGate(_s(3, 2, '1.17.0'), local: local),
        ReadModelGate.degraded,
      );
      expect(
        readModelGate(_s(3, 2, '1.40.2'), local: local),
        ReadModelGate.degraded,
      );
    });

    test('🔴 schema · hash 판 다름 · major 다름 · 못 읽음 = incompatible', () {
      for (final ReadModelVersionStamp r in <ReadModelVersionStamp>[
        _s(2, 2, '1.16.4'),
        _s(4, 2, '1.16.4'),
        _s(3, 1, '1.16.4'),
        _s(3, 3, '1.16.4'),
        _s(3, 2, '2.16.4'),
        _s(3, 2, '0.16.4'),
        _s(3, 2, '2.0.0'),
      ]) {
        expect(
          readModelGate(r, local: local),
          ReadModelGate.incompatible,
          reason:
              '${r.schemaVersion}/${r.hashFormatVersion}/${r.contractVersion}',
        );
      }
      expect(readModelGate(null, local: local), ReadModelGate.incompatible);
    });

    test('🔴 판 다름이 minor 보다 먼저 — 원격 minor 가 커도 schema 가 다르면 incompatible', () {
      expect(
        readModelGate(_s(2, 2, '1.17.0'), local: local),
        ReadModelGate.incompatible,
      );
      expect(
        readModelGate(_s(3, 3, '1.17.0'), local: local),
        ReadModelGate.incompatible,
      );
      expect(
        readModelGate(_s(3, 2, '2.17.0'), local: local),
        ReadModelGate.incompatible,
      );
    });

    test('기본 비교 기준 = 이 빌드에 컴파일된 계약 상수', () {
      final ReadModelVersionStamp me = compiledVersionStamp();
      expect(
        (me.schemaVersion, me.hashFormatVersion, me.contractVersion.toString()),
        (schemaVersion, hashFormatVersion, contractVersion),
      );
      expect(readModelGate(me), ReadModelGate.ok);
      expect(
        readModelGate(
          _s(
            schemaVersion,
            hashFormatVersion,
            '${me.contractVersion.major}.${me.contractVersion.minor + 1}.0',
          ),
        ),
        ReadModelGate.degraded,
      );
    });
  });

  group('행 읽기', () {
    Map<String, Object?> row({
      Object? schema = 3,
      Object? hash = 2,
      Object? contract = '1.16.4',
    }) => <String, Object?>{
      'schema_version': schema,
      'hash_format_version': hash,
      'contract_version': contract,
      'other': 'x',
    };

    test('3필드를 읽는다', () {
      final ReadModelVersionStamp s = ReadModelVersionStamp.fromRow(row())!;
      expect(
        (s.schemaVersion, s.hashFormatVersion, s.contractVersion.toString()),
        (3, 2, '1.16.4'),
      );
      expect(
        (
          s.contractVersion.major,
          s.contractVersion.minor,
          s.contractVersion.patch,
        ),
        (1, 16, 4),
      );
    });

    test('🔴 행 없음 · 칸 빠짐 · 형식 틀림 = 못 읽음(= incompatible)', () {
      final List<Map<String, Object?>?> bad = <Map<String, Object?>?>[
        null,
        <String, Object?>{},
        row(schema: null),
        row(hash: null),
        row(contract: null),
        row(schema: '3'),
        row(hash: 2.0),
        row(contract: 116),
        row(contract: '1.16'),
        row(contract: '1.16.4.1'),
        row(contract: 'v1.16.4'),
        row(contract: '01.16.4'),
        row(contract: '1.016.4'),
        row(contract: '1.16.04'),
        row(contract: '1.16.4 '),
        row(contract: '1.-1.4'),
      ];
      for (final Map<String, Object?>? r in bad) {
        expect(ReadModelVersionStamp.fromRow(r), isNull, reason: '$r');
        expect(readModelGateOfRow(r), ReadModelGate.incompatible, reason: '$r');
      }
    });

    test('0 은 앞 0 이 아니다', () {
      expect(ContractVersion.tryParse('0.0.0').toString(), '0.0.0');
      expect(ContractVersion.tryParse('10.20.30').toString(), '10.20.30');
    });

    test('행에서 곧장 판정', () {
      expect(
        readModelGateOfRow(<String, Object?>{
          'schema_version': schemaVersion,
          'hash_format_version': hashFormatVersion,
          'contract_version': contractVersion,
        }),
        ReadModelGate.ok,
      );
    });
  });
}
