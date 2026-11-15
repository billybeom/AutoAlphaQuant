// KIS 키 세트 시크릿 칸 — M4-4 `SecretField` 의 KIS 판(E11p3d-5b · 설계 13 §8 R115 · 05 §4 6원칙 · 04 §9 O-02).
//
// 🔴 온보딩 `O-02`(슬롯 `SECRET_KIS_MOCK`)과 M9 `S02` 가 **같은 위젯**을 쓴다(두 벌 금지 · 05 §4-1).
// 🔴 원칙 1 붙여넣기만(글자 입력 칸 0 — 키보드 학습 · 자동 완성 경로가 없다) · 클립보드 60초 정리.
// 🔴 원칙 2 표시 = 엔진 마스킹(앱키 · 시크릿 «앞4…뒤4» · 계좌 «****뒤4») · 전체 열람 = 생체 게이트(M5)가 서기 전까지 **부재**.
// 🔴 원칙 3 값 = 이 위젯 상태에만 · [SecretHandoff] 는 위젯을 가리킬 뿐 · 원칙 4 저장 = 검증 동작 뒤(이 위젯은 저장하지 않는다).
// 🔴 원칙 5 «한 번 더 입력» 칸 0 · 원칙 6 형식 감지 거부(`kisPasteProblem`).
// 🔴 이 칸이 서 있는 동안 캡처 막기(FLAG_SECURE · `SecureScope`) — 어느 라우트에 끼워도.

import 'package:broker_gateway/broker_gateway.dart'
    show KisCredentials, KisKeySet;
import 'package:core_engine/core_engine.dart' show maskAccount, maskSecret;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;

import '../app/secure_screen.dart' show SecureScope, SecureScreen;
import 'secret_handoff.dart';

/// 🔴 이 위젯의 글자(조립 앱 몫 — 계약 VM 밖의 플랫폼 칸).
abstract final class SecretLabels {
  /// 앱키.
  static const String appKey = 'APP Key';

  /// 앱 시크릿.
  static const String appSecret = 'APP Secret';

  /// 계좌.
  static const String account = '계좌번호';

  /// 빈 칸.
  static const String empty = '비어 있음';

  /// 붙여넣기 버튼.
  static const String paste = '붙여넣기';

  /// 클립보드 비었음.
  static const String clipboardEmpty = '클립보드가 비어 있습니다 — 값을 복사한 뒤 다시 누르세요.';

  /// 안내(늘).
  static const String guide =
      '값은 붙여넣기로만 받습니다 · 클립보드는 60초 뒤 비웁니다 · 저장은 «검증» 이 통과한 뒤에만 합니다.';

  /// 상품코드 접두.
  static const String productPrefix = '상품 ';

  /// 거부 사유.
  static String problem(KisPasteProblem p) => switch (p) {
    KisPasteProblem.empty => '비어 있습니다 — 값을 복사한 뒤 다시 누르세요.',
    KisPasteProblem.whitespace => '빈칸 · 줄바꿈 · 따옴표가 섞였습니다 — 그 값만 다시 복사하세요.',
    KisPasteProblem.foreignKey =>
      '다른 서비스의 키 꼴입니다 — KIS Developers 의 값을 붙여넣으세요.',
    KisPasteProblem.notAppKey => '앱키 꼴이 아닙니다(영숫자 16자 이상) — 붙여넣기를 확인하세요.',
    KisPasteProblem.notAccount => '계좌번호는 숫자 8자리입니다(예 12345678 또는 12345678-01).',
  };
}

/// KIS 키 세트 시크릿 칸.
class KisKeySetField extends StatefulWidget {
  /// 만든다.
  const KisKeySetField({
    super.key,
    required this.set,
    required this.handoff,
    required this.janitor,
    required this.secure,
    this.readClipboard = _readClipboard,
  });

  /// 키 세트.
  final KisKeySet set;

  /// 검증 동작으로의 넘김.
  final SecretHandoff handoff;

  /// 클립보드 정리.
  final ClipboardJanitor janitor;

  /// 캡처 막기.
  final SecureScreen secure;

  /// 클립보드 읽기(시험 = 가짜).
  final Future<String?> Function() readClipboard;

  static Future<String?> _readClipboard() async =>
      (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  @override
  State<KisKeySetField> createState() => _KisKeySetFieldState();
}

class _KisKeySetFieldState extends State<KisKeySetField>
    implements KisDraftSource {
  String? _appKey;
  String? _appSecret;
  String? _account;
  String? _product;
  final Map<KisPasteField, String> _notes = <KisPasteField, String>{};

  @override
  void initState() {
    super.initState();
    widget.handoff.attach(widget.set, this);
  }

  @override
  void didUpdateWidget(KisKeySetField old) {
    super.didUpdateWidget(old);
    if (old.set != widget.set || !identical(old.handoff, widget.handoff)) {
      old.handoff.detach(old.set, this);
      _wipe();
      widget.handoff.attach(widget.set, this);
    }
  }

  @override
  void dispose() {
    widget.handoff.detach(widget.set, this);
    _wipe();
    super.dispose();
  }

  void _wipe() {
    _appKey = null;
    _appSecret = null;
    _account = null;
    _product = null;
    _notes.clear();
  }

  @override
  KisCredentials? current() {
    final String? k = _appKey, s = _appSecret, a = _account;
    if (k == null || s == null || a == null) return null;
    try {
      return KisCredentials(
        environment: widget.set.environment,
        appKey: k,
        appSecret: s,
        accountNo: a,
        productCode: _product ?? '01',
      );
    } on ArgumentError {
      return null;
    }
  }

  @override
  void clear() {
    if (!mounted) return;
    setState(_wipe);
  }

  Future<void> _paste(KisPasteField field) async {
    String? raw;
    try {
      raw = await widget.readClipboard();
    } on Object {
      raw = null;
    }
    if (!mounted) return;
    if (raw == null || raw.isEmpty) {
      setState(() => _notes[field] = SecretLabels.clipboardEmpty);
      return;
    }
    widget.janitor.pasted(raw);
    final KisPasteProblem? p = kisPasteProblem(field, raw);
    setState(() {
      if (p != null) {
        _notes[field] = SecretLabels.problem(p);
        return;
      }
      _notes.remove(field);
      final String v = raw!.trim();
      switch (field) {
        case KisPasteField.appKey:
          _appKey = v;
        case KisPasteField.appSecret:
          _appSecret = v;
        case KisPasteField.account:
          final (String acct, String? product) = splitKisAccount(v);
          _account = acct;
          _product = product;
      }
    });
  }

  String _shown(KisPasteField f) {
    switch (f) {
      case KisPasteField.appKey:
        final String? v = _appKey;
        return v == null ? SecretLabels.empty : maskSecret(v);
      case KisPasteField.appSecret:
        final String? v = _appSecret;
        return v == null ? SecretLabels.empty : maskSecret(v);
      case KisPasteField.account:
        final String? v = _account;
        return v == null
            ? SecretLabels.empty
            : '${maskAccount(v)} · ${SecretLabels.productPrefix}${_product ?? '01'}';
    }
  }

  static String _label(KisPasteField f) => switch (f) {
    KisPasteField.appKey => SecretLabels.appKey,
    KisPasteField.appSecret => SecretLabels.appSecret,
    KisPasteField.account => SecretLabels.account,
  };

  Widget _row(BuildContext context, KisPasteField f) {
    final String? note = _notes[f];
    return Padding(
      key: Key('m4-secret-${f.name}'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_label(f)),
                    Text(
                      _shown(f),
                      key: Key('m4-secret-${f.name}-shown'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                key: Key('m4-secret-${f.name}-paste'),
                onPressed: () => _paste(f),
                child: const Text(SecretLabels.paste),
              ),
            ],
          ),
          if (note != null)
            Text(
              note,
              key: Key('m4-secret-${f.name}-note'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SecureScope(
    screen: widget.secure,
    child: Column(
      key: Key('m4-secret-${widget.set.wire}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final KisPasteField f in KisPasteField.values) _row(context, f),
        const Text(SecretLabels.guide),
      ],
    ),
  );
}
