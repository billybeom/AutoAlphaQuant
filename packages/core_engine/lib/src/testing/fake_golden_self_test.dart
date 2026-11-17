// 시험용 골든 자가검사(설계 13 §8 R138 Q3).

import '../migration/golden_self_test.dart' show GoldenSelfTest;

/// 각본대로 답하는 골든 자가검사 — bool = 그 답 · Exception = 그것을 던진다 · 그 밖 = StateError · 각본이 끝나면 마지막을 되풀이.
class FakeGoldenSelfTest implements GoldenSelfTest {
  /// 만든다.
  FakeGoldenSelfTest(this.script);

  /// 각본.
  final List<Object> script;

  /// 돈 횟수.
  int runs = 0;

  @override
  Future<bool> run() async {
    final Object step = script[runs < script.length ? runs : script.length - 1];
    runs++;
    if (step is bool) return step;
    if (step is Exception) throw step;
    throw StateError('골든 자가검사 실패(시험): $step');
  }
}
