// o_07 ② Supabase 연결 칸 — 프로젝트 주소 + 공개 키 붙여넣기(E11k-c · 설계 13 §8 R206 · 계약 v1.29 01 §39 · 슬롯
// `SECRET_SUPABASE_CONNECT` · 05 §4 6원칙 — KIS 칸 `kis_key_set_field.dart` 와 같은 꼴).
//
// 🔴 원칙 1 붙여넣기만(글자 입력 칸 0) · 클립보드 60초 정리 · 원칙 2 표시 = 엔진 마스킹(주소 = ref 만 가림 · 키 «앞4…뒤4»).
// 🔴 원칙 3 값 = 이 위젯 상태에만([SecretHandoff] 는 가리킬 뿐) · 원칙 4 저장 = «연결 확인» 통과 뒤(이 위젯은 저장하지 않는다).
// 🔴 원칙 6 형식 감지 거부 — 꼴이 틀린 값 · 🔴 비밀 키 · service_role 키는 **쥐지도 않는다**(붙여넣는 순간 버리고 엔진 글자로 알림).
// 🔴 이 칸이 서 있는 동안 캡처 막기(FLAG_SECURE · `SecureScope`).

import 'package:core_engine/core_engine.dart' show maskSecret;
import 'package:data_sync/data_sync.dart'
    show
        SupabaseConnectText,
        SupabaseInputProblem,
        supabaseProjectUri,
        supabaseProjectUrlProblem,
        supabasePublishableKeyProblem;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;

import '../app/secure_screen.dart' show SecureScope, SecureScreen;
import 'secret_handoff.dart';

/// 🔴 이 위젯의 글자(조립 앱 몫 — 계약 VM 밖의 플랫폼 칸).
abstract final class SupabaseFieldLabels {
  /// 주소.
  static const String url = '프로젝트 주소';

  /// 키.
  static const String key = '공개 키(publishable)';

  /// 빈 칸.
  static const String empty = '비어 있음';

  /// 붙여넣기 버튼.
  static const String paste = '붙여넣기';

  /// 클립보드 비었음.
  static const String clipboardEmpty = '클립보드가 비어 있습니다 — 값을 복사한 뒤 다시 누르세요.';

  /// 안내(늘).
  static const String guide =
      '값은 붙여넣기로만 받습니다 · 클립보드는 60초 뒤 비웁니다 · 저장은 «연결 확인» 이 통과한 뒤에만 합니다.';
}

/// 칸 둘.
enum SupabasePasteField {
  /// 프로젝트 주소.
  url,

  /// 공개 키.
  key,
}

/// o_07 ② Supabase 연결 칸.
class SupabaseConnectField extends StatefulWidget {
  /// 만든다.
  const SupabaseConnectField({
    super.key,
    required this.handoff,
    required this.janitor,
    required this.secure,
    this.readClipboard = _readClipboard,
  });

  /// 연결 확인 동작으로의 넘김.
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
  State<SupabaseConnectField> createState() => _SupabaseConnectFieldState();
}

class _SupabaseConnectFieldState extends State<SupabaseConnectField>
    implements SupabaseDraftSource {
  String? _url;
  String? _key;
  final Map<SupabasePasteField, String> _notes = <SupabasePasteField, String>{};

  @override
  void initState() {
    super.initState();
    widget.handoff.attachSupabase(this);
  }

  @override
  void didUpdateWidget(SupabaseConnectField old) {
    super.didUpdateWidget(old);
    if (!identical(old.handoff, widget.handoff)) {
      old.handoff.detachSupabase(this);
      _wipe();
      widget.handoff.attachSupabase(this);
    }
  }

  @override
  void dispose() {
    widget.handoff.detachSupabase(this);
    _wipe();
    super.dispose();
  }

  void _wipe() {
    _url = null;
    _key = null;
    _notes.clear();
  }

  @override
  ({String? url, String? key}) current() => (url: _url, key: _key);

  @override
  void clear() {
    if (!mounted) return;
    setState(_wipe);
  }

  static SupabaseInputProblem? _problem(SupabasePasteField f, String raw) =>
      switch (f) {
        SupabasePasteField.url => supabaseProjectUrlProblem(raw),
        SupabasePasteField.key => supabasePublishableKeyProblem(raw),
      };

  Future<void> _paste(SupabasePasteField field) async {
    String? raw;
    try {
      raw = await widget.readClipboard();
    } on Object {
      raw = null;
    }
    if (!mounted) return;
    if (raw == null || raw.isEmpty) {
      setState(() => _notes[field] = SupabaseFieldLabels.clipboardEmpty);
      return;
    }
    widget.janitor.pasted(raw);
    final SupabaseInputProblem? p = _problem(field, raw);
    setState(() {
      if (p != null) {
        // 🔴 틀린 값 · 비밀 키는 쥐지 않는다(앞에 쥔 값도 그대로 둔다 — 그 칸만 알림).
        _notes[field] = SupabaseConnectText.input(p);
        return;
      }
      _notes.remove(field);
      final String v = raw!.trim();
      switch (field) {
        case SupabasePasteField.url:
          _url = supabaseProjectUri(v).toString();
        case SupabasePasteField.key:
          _key = v;
      }
    });
  }

  String _shown(SupabasePasteField f) {
    switch (f) {
      case SupabasePasteField.url:
        final String? v = _url;
        if (v == null) return SupabaseFieldLabels.empty;
        final String host = Uri.parse(v).host;
        final String ref = host.split('.').first;
        return 'https://${maskSecret(ref)}${host.substring(ref.length)}';
      case SupabasePasteField.key:
        final String? v = _key;
        return v == null ? SupabaseFieldLabels.empty : maskSecret(v);
    }
  }

  static String _label(SupabasePasteField f) => switch (f) {
    SupabasePasteField.url => SupabaseFieldLabels.url,
    SupabasePasteField.key => SupabaseFieldLabels.key,
  };

  Widget _row(BuildContext context, SupabasePasteField f) {
    final String? note = _notes[f];
    return Padding(
      key: Key('m4-supabase-${f.name}'),
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
                      key: Key('m4-supabase-${f.name}-shown'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                key: Key('m4-supabase-${f.name}-paste'),
                onPressed: () => _paste(f),
                child: const Text(SupabaseFieldLabels.paste),
              ),
            ],
          ),
          if (note != null)
            Text(
              note,
              key: Key('m4-supabase-${f.name}-note'),
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
      key: const Key('m4-supabase-connect'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final SupabasePasteField f in SupabasePasteField.values)
          _row(context, f),
        const Text(SupabaseFieldLabels.guide),
      ],
    ),
  );
}
