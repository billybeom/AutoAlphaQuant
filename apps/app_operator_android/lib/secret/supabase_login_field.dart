// o_07 ③ Supabase 로그인 칸 — 이메일 + 비밀번호 붙여넣기(E11k-d2 · 설계 13 §8 R216 · 계약 v1.31 01 §40 · 슬롯
// `SECRET_SUPABASE_LOGIN` · 05 §4 6원칙 — 연결 칸 `supabase_connect_field.dart` 와 같은 꼴).
//
// 🔴 원칙 1 붙여넣기만(비밀번호 관리자에서 · 글자 입력 칸 0) · 클립보드 60초 정리.
// 🔴 원칙 2 표시 = 이메일 «앞 1자 + *** + @도메인» · 🔴 비밀번호는 글자 수도 보이지 않는다(«붙여 넣음»만).
// 🔴 원칙 3 값 = 이 위젯 상태에만([SecretHandoff] 는 가리킬 뿐) · 원칙 4 저장 0 — 비밀번호는 `supabaseSignIn` 이 한 번 쓰고
//    칸을 비운다(통과 · 실패 모두) · 남는 것 = 새로고침 토큰(금고).
// 🔴 원칙 6 — 이메일 꼴이 아니면 쥐지 않는다(엔진 글자로 알림) · 비밀번호 = 붙여 넣은 그대로(끝 줄바꿈만 뗀다).
// 🔴 이 칸이 서 있는 동안 캡처 막기(FLAG_SECURE · `SecureScope`).

import 'package:data_sync/data_sync.dart'
    show SupabaseAuthFailure, supabaseEmailLooksValid, supabaseSignInOutcome;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;

import '../app/secure_screen.dart' show SecureScope, SecureScreen;
import 'secret_handoff.dart';

/// 🔴 이 위젯의 글자(조립 앱 몫 — 계약 VM 밖의 플랫폼 칸).
abstract final class SupabaseLoginLabels {
  /// 이메일.
  static const String email = '이메일';

  /// 비밀번호.
  static const String password = '비밀번호';

  /// 빈 칸.
  static const String empty = '비어 있음';

  /// 비밀번호 받음(글자 수 0).
  static const String passwordSet = '붙여 넣음';

  /// 붙여넣기 버튼.
  static const String paste = '붙여넣기';

  /// 클립보드 비었음.
  static const String clipboardEmpty = '클립보드가 비어 있습니다 — 값을 복사한 뒤 다시 누르세요.';

  /// 안내(늘).
  static const String guide =
      '값은 붙여넣기로만 받습니다 · 클립보드는 60초 뒤 비웁니다 · 비밀번호는 저장하지 않습니다(로그인 상태만 이 기기에).';
}

/// 칸 둘.
enum SupabaseLoginField {
  /// 이메일.
  email,

  /// 비밀번호.
  password,
}

/// 이메일 가림 — «앞 1자 + *** + @도메인»(꼴이 아니면 전부 가림).
String maskEmail(String email) {
  final int at = email.indexOf('@');
  if (at < 1) return '***';
  return '${email.substring(0, 1)}***${email.substring(at)}';
}

/// o_07 ③ Supabase 로그인 칸.
class SupabaseLoginPanel extends StatefulWidget {
  /// 만든다.
  const SupabaseLoginPanel({
    super.key,
    required this.handoff,
    required this.janitor,
    required this.secure,
    this.readClipboard = _readClipboard,
  });

  /// 로그인 동작으로의 넘김.
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
  State<SupabaseLoginPanel> createState() => _SupabaseLoginPanelState();
}

class _SupabaseLoginPanelState extends State<SupabaseLoginPanel>
    implements SupabaseLoginDraftSource {
  String? _email;
  String? _password;
  final Map<SupabaseLoginField, String> _notes = <SupabaseLoginField, String>{};

  @override
  void initState() {
    super.initState();
    widget.handoff.attachSupabaseLogin(this);
  }

  @override
  void didUpdateWidget(SupabaseLoginPanel old) {
    super.didUpdateWidget(old);
    if (!identical(old.handoff, widget.handoff)) {
      old.handoff.detachSupabaseLogin(this);
      _wipe();
      widget.handoff.attachSupabaseLogin(this);
    }
  }

  @override
  void dispose() {
    widget.handoff.detachSupabaseLogin(this);
    _wipe();
    super.dispose();
  }

  void _wipe() {
    _email = null;
    _password = null;
    _notes.clear();
  }

  @override
  ({String? email, String? password}) current() =>
      (email: _email, password: _password);

  @override
  void clear() {
    if (!mounted) return;
    setState(_wipe);
  }

  Future<void> _paste(SupabaseLoginField field) async {
    String? raw;
    try {
      raw = await widget.readClipboard();
    } on Object {
      raw = null;
    }
    if (!mounted) return;
    if (raw == null || raw.isEmpty) {
      setState(() => _notes[field] = SupabaseLoginLabels.clipboardEmpty);
      return;
    }
    widget.janitor.pasted(raw);
    final String v = raw;
    setState(() {
      switch (field) {
        case SupabaseLoginField.email:
          if (!supabaseEmailLooksValid(v)) {
            // 🔴 꼴이 아니면 쥐지 않는다(앞에 쥔 값은 그대로) — 엔진 글자.
            _notes[field] = supabaseSignInOutcome(SupabaseAuthFailure.badInput)
                .headline;
            return;
          }
          _notes.remove(field);
          _email = v.trim();
        case SupabaseLoginField.password:
          final String p = v.replaceAll(RegExp(r'[\r\n]+$'), '');
          if (p.isEmpty) {
            _notes[field] = SupabaseLoginLabels.clipboardEmpty;
            return;
          }
          _notes.remove(field);
          _password = p;
      }
    });
  }

  String _shown(SupabaseLoginField f) => switch (f) {
    SupabaseLoginField.email => switch (_email) {
      final String e => maskEmail(e),
      null => SupabaseLoginLabels.empty,
    },
    SupabaseLoginField.password =>
      _password == null
          ? SupabaseLoginLabels.empty
          : SupabaseLoginLabels.passwordSet,
  };

  static String _label(SupabaseLoginField f) => switch (f) {
    SupabaseLoginField.email => SupabaseLoginLabels.email,
    SupabaseLoginField.password => SupabaseLoginLabels.password,
  };

  Widget _row(BuildContext context, SupabaseLoginField f) {
    final String? note = _notes[f];
    return Padding(
      key: Key('m4-supabase-login-${f.name}'),
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
                      key: Key('m4-supabase-login-${f.name}-shown'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TextButton(
                key: Key('m4-supabase-login-${f.name}-paste'),
                onPressed: () => _paste(f),
                child: const Text(SupabaseLoginLabels.paste),
              ),
            ],
          ),
          if (note != null)
            Text(
              note,
              key: Key('m4-supabase-login-${f.name}-note'),
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
      key: const Key('m4-supabase-login'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final SupabaseLoginField f in SupabaseLoginField.values)
          _row(context, f),
        const Text(SupabaseLoginLabels.guide),
      ],
    ),
  );
}
