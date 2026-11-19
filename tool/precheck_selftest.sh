#!/usr/bin/env bash
# ============================================================================
# precheck_selftest.sh — 사전검사(tool/precheck.dart) 새 검사 자가 시험
#   (T1 null 흐름 칸 · T3 어디나 있는 위젯 · T6 · T7 · R6 · R7 · R8 · R9)
#
# 무엇을 하나: 임시 폴더에 작은 git 저장소를 만들고(밑동 커밋 + 경우마다 커밋 하나), 합성 테스트
#   파일·보고 글로 precheck.dart 를 돌린다 — 잡아야 할 꼴은 그 코드·색으로 잡고, 정상 꼴에서는
#   새 코드가 0 인지 본다. 성공 = exit 0.
# 언제 부르나: precheck.dart 를 고칠 때 손으로(CI 잡에는 아직 없다) — 저장소 루트에서
#   bash tool/precheck_selftest.sh
#   (dart 가 PATH 에 없으면 DART=<dart 경로> · R7 은 bash 로 check_labels.sh 를 돌린다)
# 🔴 저장소 파일은 건드리지 않는다(임시 저장소만 고친다). 입력은 모두 이 파일 안의 합성 글이다.
# ============================================================================
set -u
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DART="${DART:-dart}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
REPO="$WORK/repo"
BAD=0

g() { git -C "$REPO" -c user.name=selftest -c user.email=selftest@example.invalid -c core.autocrlf=false "$@"; }

mkdir -p "$REPO/packages/ui_demo/test" "$REPO/packages/domain_contracts/tool" "$REPO/apps/app_demo/lib"
g init -q
cp "$SRC/packages/domain_contracts/tool/check_labels.sh" "$REPO/packages/domain_contracts/tool/"
printf '%s\n' "// demo" "const String a = '가';" "const String b = '나';" "const String c = 'ok';" \
  > "$REPO/apps/app_demo/lib/demo.dart"
printf 'name: ui_demo\n' > "$REPO/packages/ui_demo/pubspec.yaml"
g add -A && g commit -q -m base
BASE=$(g rev-parse HEAD)

# ── 합성 테스트 파일 ─────────────────────────────────────────────────────────
GOOD_TEST=$(cat <<'DART'
void main() {
  testWidgets('good', (WidgetTester tester) async {
    int seen = 0;
    final FakeRepo repo = FakeRepo(
      load: (int call) => call == 0 ? bad() : one(),
    );
    seen = seen + 1;
    expect(seen, 1);
    int tick = 0;
    final String at = 'T${(tick++).toString()}';
    final List<int> xs = List<int>.generate(3, (int i) {
      if (i == 0) {
        return 1;
      }
      return i;
    });
    if (repo.steps != null) {
      await tester.tap(find.byKey(const Key('go')));
    }
    expect(find.byKey(const Key('x')), findsOneWidget);
    expect(find.byType(DemoCard), findsWidgets);
    expect(find.descendant(of: find.byKey(const Key('y')), matching: find.byType(Text)), findsWidgets);
    expect(at, isNotEmpty);
    expect(xs, isNotEmpty);
  });
}
DART
)

BAD_TEST=$(cat <<'DART'
void main() {
  testWidgets('bad', (WidgetTester tester) async {
    int callCount = 0;
    final FakeRepo repo = FakeRepo(
      load: (int call) {
        callCount = callCount + 1;
        if (call == 0) {
          return bad();
        }
        return one();
      },
    );
    final Future<void> Function(WidgetTester t)? steps = repo.steps;
    if (steps != null) {
      await steps(tester);
    }
    if (repo.after != null) repo.after!.call(tester);
    expect(find.byType(Text), findsWidgets);
    expect(find.byType(Padding), findsAtLeast(2));
  });
}
DART
)

# ── 합성 보고 글(① 블록은 git 출력으로 채운다) ───────────────────────────────
# 인자: <출력 파일> <ⓡ 줄> <상자 뒤 빈 줄 수> <apps 수> <① 이어 붙이기 0|1> <깨진 글자 0|1>
make_report() {
  local out="$1" rline="$2" blanks="$3" apps="$4" joined="$5" broken="$6"
  local ns log
  ns=$(g diff --name-status "$BASE" HEAD)
  log=$(g log --oneline "$BASE..HEAD")
  if [ "$joined" = 1 ]; then ns=$(printf '%s' "$ns" | tr '\n' ' '); fi
  if [ "$broken" = 1 ]; then log="$log 쨌 吏덈Ц"; fi
  {
    echo '## ① 구현한 화면 ID · 바뀐 파일 · 커밋'
    echo '화면 ID: 자가 시험'
    echo '바뀐 파일:'
    echo '```'
    echo "$ns"
    echo '```'
    echo '커밋 목록:'
    echo '```'
    echo "$log"
    echo '```'
    echo '## ② 자체 점검 12항 · 정적 묶음 · 명령 출력'
    for i in 1 2 3 4 5 6 7 8 9 10; do printf '%2d. 점검 %d [x] (근거)\n' "$i" "$i"; done
    for _ in $(seq 1 "$blanks"); do echo; done
    echo '10항 줄 수:'
    echo '```'
    echo '10'
    echo '```'
    echo '정적 묶음 출력:'
    echo '```'
    echo '## T20 R lines (retry findsNothing)'
    echo 'test/demo_test.dart:12'
    echo 'EXIT:0'
    echo '## T21 H lines (hasLength - this card 0)'
    echo 'EXIT:1'
    echo '```'
    echo 'ⓡ = T20 출력:'
    echo "$rline"
    echo 'ⓗ = T21 출력:'
    echo '(출력 없음 — EXIT:1 · 이 카드 ⓗ 0)'
    echo "check:labels = main 원래 🔴(apps/** ${apps}줄 · ui_demo 0줄) — 자가 시험"
    echo '## ③ 스크린샷 서술 · 골든 표'
    echo '## ④ 질문 목록'
    echo '없음'
    echo '## ⑤ 추측한 것 목록'
    echo '없음'
    if [ "$broken" = 1 ]; then echo '추측 吏덈Ц'; fi
  } > "$out"
}

run() { "$DART" "$SRC/tool/precheck.dart" --repo "$REPO" --base "$BASE" --head HEAD "$@" </dev/null 2>&1; }
# 결과 줄에 «<색> [<코드>]» 가 있어야 / 없어야 한다.
has() { if printf '%s' "$OUT" | grep -qF -- "$2"; then echo "✓ $1"; else echo "✗ $1: «$2» 가 나와야 한다"; BAD=1; fi; }
hasnt() { if printf '%s' "$OUT" | grep -qF -- "$2"; then echo "✗ $1: «$2» 가 나오면 안 된다"; printf '%s\n' "$OUT" | grep -F -- "$2" | head -3; BAD=1; else echo "✓ $1"; fi; }

# ── 경우 A: 정상 테스트 + 정상 보고 ─────────────────────────────────────────
printf '%s\n' "$GOOD_TEST" > "$REPO/packages/ui_demo/test/demo_test.dart"
g add -A && g commit -q -m 'A good'
make_report "$WORK/a.md" 'test/demo_test.dart:12' 1 2 0 0
OUT=$(run --collection-if 0 --report "$WORK/a.md")
for c in T1 T3 T6 T7 R6 R7 R8 R9; do
  hasnt "A 정상 꼴 🔴 [$c] 0" "🔴 [$c]"
  hasnt "A 정상 꼴 🟡 [$c] 0" "🟡 [$c]"
done
has 'A check:labels 다시 잰 수 2' 'apps/** 2(보고 2)'

# ── 경우 B: 반려 꼴 테스트(기본 = T6 🟡) ─────────────────────────────────────
printf '%s\n' "$BAD_TEST" > "$REPO/packages/ui_demo/test/demo_test.dart"
mkdir -p "$REPO/packages/ui_demo/lib" && printf '%s\n' '// demo' > "$REPO/packages/ui_demo/lib/demo.dart"
g add -A && g commit -q -m 'B bad'
OUT=$(run --collection-if 0 --no-labels)
has 'B 가짜 공장 안 if = 🟡 T6' '🟡 [T6]'
has 'B 쓰기만 하는 callCount = 🟡 T7' '🟡 [T7]'
has 'B null 흐름 칸 if = 🔴 T1' '🔴 [T1]'
has 'B find.byType(Text) findsWidgets = 🔴 T3' 'find.byType(Text)'
has 'B find.byType(Padding) findsAtLeast = 🔴 T3' 'find.byType(Padding)'
N1=$(printf '%s\n' "$OUT" | grep -cF '🔴 [T1]')
if [ "$N1" = 2 ]; then echo '✓ B T1 = 2(블록 · 한 문장 X!.call)'; else echo "✗ B T1 $N1 ≠ 2"; BAD=1; fi

OUT=$(run --collection-if 0 --no-labels --factory-if 0)
has 'B --factory-if 0 = 🔴 T6' '🔴 [T6]'

# ── 경우 C: 반려 꼴 보고(ⓡ 다른 줄 · 빈 줄 2 · apps 수 다름 · ① 이어 붙임 · 깨진 글자) ──
make_report "$WORK/c.md" 'test/demo_test.dart:13' 2 63 1 1
OUT=$(run --collection-if any --report "$WORK/c.md")
has 'C ⓡ :13 ↔ T20 :12 = 🔴 R6' '🔴 [R6]'
has 'C apps/** 63 ↔ 다시 잰 2 = 🟡 R7' '🟡 [R7]'
has 'C ② 상자 뒤 빈 줄 2 = 🟡 R8' '🟡 [R8]'
has 'C ① 바뀐 파일 한 줄 이음 = 🔴 R9' '«바뀐 파일:» 블록'
has 'C 깨진 글자 «쨌» = 🔴 R9' '깨진 글자'
has 'C 한자 = 🟡 R9' '🟡 [R9]'

# ── 경우 D: ⓗ 정적 출력 없음인데 상자에 줄 · 빈 줄 0 ──────────────────────
make_report "$WORK/d.md" 'test/demo_test.dart:12' 0 2 0 0
sed -i 's#^(출력 없음 — EXIT:1 · 이 카드 ⓗ 0)$#test/demo_test.dart:1#' "$WORK/d.md"
OUT=$(run --collection-if any --report "$WORK/d.md" --no-labels)
has 'D ⓗ 줄 ↔ T21 출력 없음 = 🔴 R6' 'ⓗ = T21 출력:'
has 'D ② 상자 뒤 빈 줄 0 = 🟡 R8' '빈 줄 0개'
hasnt 'D --no-labels 면 R7 안 돈다' '[R7]'

printf "%s
" "$OUT" > /dev/null
if [ $BAD -ne 0 ]; then echo "== 자가 시험 실패"; exit 1; fi
echo "== 자가 시험 통과"
exit 0
