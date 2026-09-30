#!/usr/bin/env bash
# ============================================================================
# check_boundaries.sh — 경계 규칙 기계 검사
#
# 무엇을 하나:
#   [1] 🔴 실패: ui_* 패키지의 pubspec.yaml 에 금지 패키지가 의존으로 있는가
#   [2] 🔴 실패: ui_* 패키지의 lib/ 코드가 금지 패키지를 import 하는가
#   [3] 🔴 실패: domain_contracts 가 Flutter·엔진·DB를 의존하는가(순수 Dart 원칙)
#   [4] 🟡 경고: ui_* 의 lib/l10n/labels.dart 밖에서 한국어 «문자열 리터럴»이
#              발견되는가 (사유 문구 생성 후보 — 사람이 봐야 판정 가능)
#   [5] 🔴 실패: ui_* 의 lib/ 코드 줄에 링크 리터럴(`aaq://`·`handbook://`)이 있는가 (01 §4-4 · 계약 v1.1)
#   [6] (예약) viewer(iOS) 의 `package:ui_journal/journal_draft.dart` import 0건 — docs/TARGETS.md T-3
#              (조립 앱 배선 때 더한다 · 번호만 잡아 둔다)
#   [7] 🔴 실패: viewer 조립 앱(apps/app_viewer_*/lib)이 `package:ui_analytics/planner.dart` 를
#              import 하는가 (🆕 계약 v1.4 · 01 §14-1 · docs/TARGETS.md T-4)
#
# 왜 있나: 위반이 「잘못된 화면」이 아니라 「빌드 실패」로 나타나야 리뷰가
#   병목이 되지 않는다(청사진 §9-2 · 00_README §5 · 01 §7 C-3/C-5).
#
# 어떻게 부르나:  melos run check:boundaries     (또는)  bash tool/check_boundaries.sh
# 어디서 도나:    저장소 루트. Git Bash(Windows)·Ubuntu(CI) 둘 다.
#
# 🔴 이 스크립트를 통과시키려고 금지 목록을 줄이지 말 것. 목록이 틀렸다고
#    생각되면 01 §1-1(의존성 규칙 표)을 먼저 고치고, 그 커밋에서 여기를 고친다.
# ============================================================================

set -u   # 미정의 변수는 오류. (set -e 는 쓰지 않는다 — grep의 «없음»=1 이 정상이라)

# 저장소 루트로 이동 — 어디서 불러도 같게 돌게.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR" || exit 1

FAIL=0
WARN=0

# ── 금지 목록 (01 §1-1 · 07 §9 기계 검사 1과 같은 집합) ──────────────────────
# ui_* 는 domain_contracts · flutter · riverpod 만 의존한다.
# 🆕 계약 v1.2(01 §12-1) — 저장 패키지 7종(shared_preferences … sqlite3). 입력 초안은 포트(DraftStore)로만.
FORBIDDEN_UI='core_engine|decimal|broker_gateway|trading_runtime|data_sync|sqflite|supabase|http|dio|shared_preferences|flutter_secure_storage|path_provider|hive|isar|drift|sqlite3'
# domain_contracts 는 순수 Dart. decimal 은 허용(금액 타입의 근거),
# flutter_lints 도 허용(규칙 YAML만 담은 순수 Dart 패키지 — analysis_options 주석 참조).
# 그래서 flutter 계열은 접두 일치로 뭉뚱그리지 않고 아래 [3]에서 따로 본다.
FORBIDDEN_CONTRACTS='core_engine|broker_gateway|trading_runtime|data_sync|sqflite|supabase'
FLUTTER_DEP_RE='^[[:space:]]+flutter(_test|_localizations)?[[:space:]]*:'

say()  { printf '%s\n' "$*"; }
fail() { printf '🔴 %s\n' "$*"; FAIL=1; }
warn() { printf '🟡 %s\n' "$*"; WARN=1; }

say "── 경계 규칙 검사 (root: $ROOT_DIR)"

# ── [1][2] ui_* 패키지 ──────────────────────────────────────────────────────
UI_PKGS=$(ls -d packages/ui_* 2>/dev/null || true)

if [ -z "$UI_PKGS" ]; then
  say "ℹ️  packages/ui_* 가 아직 없다 — [1][2][4] 건너뜀 (스캐폴드 단계에서는 정상)"
else
  for pkg in $UI_PKGS; do
    name="$(basename "$pkg")"

    # [1] pubspec 의존 — dependencies/dev_dependencies 블록 전체를 본다.
    #     "금지 이름이 pubspec 어디에도 없을 것"이 규칙이므로 블록 파싱은 하지
    #     않는다(주석에 적힌 금지어도 잡히지만, 그건 지우면 되는 소음이다).
    if [ -f "$pkg/pubspec.yaml" ]; then
      # 접두 일치로 본다 — supabase_flutter·sqflite_common 처럼 이름이 늘어난
      # 변종이 규칙을 빠져나가지 못하게.
      hits=$(grep -nE "^[[:space:]]+($FORBIDDEN_UI)[A-Za-z0-9_]*[[:space:]]*:" "$pkg/pubspec.yaml" || true)
      if [ -n "$hits" ]; then
        fail "[C-3] $name/pubspec.yaml 에 금지 의존이 있다 — ui_* 는 domain_contracts·flutter·riverpod 만:"
        printf '     %s\n' "$hits"
      fi
    else
      warn "$pkg 에 pubspec.yaml 이 없다"
    fi

    # [2] import 그래프
    if [ -d "$pkg/lib" ]; then
      hits=$(grep -rnE "package:($FORBIDDEN_UI)[A-Za-z0-9_]*/" "$pkg/lib" || true)
      if [ -n "$hits" ]; then
        fail "[C-3] $name/lib 이 금지 패키지를 import 한다:"
        printf '     %s\n' "$hits"
      fi
    fi
  done
fi

# ── [3] domain_contracts 순수성 ─────────────────────────────────────────────
DC="packages/domain_contracts"
if [ -f "$DC/pubspec.yaml" ]; then
  hits=$(grep -nE "^[[:space:]]+($FORBIDDEN_CONTRACTS)[A-Za-z0-9_]*[[:space:]]*:" "$DC/pubspec.yaml" || true)
  hits="$hits$(grep -nE "$FLUTTER_DEP_RE" "$DC/pubspec.yaml" || true)"
  if [ -n "$hits" ]; then
    fail "[01 §1-1] domain_contracts 는 순수 Dart 여야 한다(Flutter·엔진·DB 미의존 — flutter_lints·decimal 은 예외):"
    printf '     %s\n' "$hits"
  fi
  if [ -d "$DC/lib" ]; then
    hits=$(grep -rnE "package:(($FORBIDDEN_CONTRACTS)[A-Za-z0-9_]*|flutter|flutter_test)/" "$DC/lib" || true)
    if [ -n "$hits" ]; then
      fail "[01 §1-1] domain_contracts/lib 이 금지 패키지를 import 한다:"
      printf '     %s\n' "$hits"
    fi
  fi
fi

# ── [4] 한국어 문자열 리터럴 (경고만) ───────────────────────────────────────
# 🔴 왜 경고인가: 이 검사는 «정적 UI 라벨»과 «사유 문구»를 구별하지 못한다
#    (01 §1-5 · 07 §10-4). 기계가 할 수 있는 것은 «labels.dart 밖에 한국어
#    문자열이 있다»까지고, 그것이 위반인지는 사람이 본다(검수 4항 ②).
#    주석·문서 주석의 한국어는 정상이므로 «따옴표 안»만 본다 — 그래도 한국어
#    주석 안에 따옴표가 있으면 오탐이 난다. 그래서 실패가 아니라 경고다.
KOREAN_RE="['\"][^'\"]*[가-힣][^'\"]*['\"]"

# 자기 점검: 로케일이 UTF-8이 아니면 위 문자 범위가 조용히 아무것도 못 잡는다.
# 「검사를 돌렸는데 0건」과 「검사가 죽어서 0건」은 다르므로 여기서 구별한다.
KOREAN_SCAN="$UI_PKGS"
if ! printf "%s\n" "'테스트'" | grep -qE "$KOREAN_RE" 2>/dev/null; then
  warn "[C-5] 한국어 리터럴 검사를 건너뛴다 — 이 셸의 로케일(LANG=${LANG:-미설정})에서 한글 범위 매칭이 동작하지 않는다. CI에서는 LANG=C.UTF-8 로 돈다."
  KOREAN_SCAN=""
fi

if [ -n "$KOREAN_SCAN" ]; then
  for pkg in $KOREAN_SCAN; do
    [ -d "$pkg/lib" ] || continue
    hits=$(grep -rnE "$KOREAN_RE" "$pkg/lib" 2>/dev/null \
           | grep -v '/lib/l10n/labels\.dart:' \
           | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|///|\*)' \
           || true)
    if [ -n "$hits" ]; then
      warn "[C-5] $(basename "$pkg"): lib/l10n/labels.dart 밖에 한국어 문자열이 있다 — 정적 라벨인지 사유 문구인지 사람이 판정할 것:"
      printf '     %s\n' "$hits" | head -40
      cnt=$(printf '%s\n' "$hits" | wc -l | tr -d ' ')
      [ "$cnt" -gt 40 ] && printf '     … 외 %s건\n' "$((cnt - 40))"
    fi
  done
fi

# ── [5] 링크 리터럴 (01 §4-4 내비게이션 계약 · 계약 v1.1) ────────────────────
# 🔴 「링크는 데이터로 온다」 — 화면(ui_*)은 링크를 만들지 않으므로 `aaq://`·`handbook://`
#    문자열이 화면 코드에 있을 이유가 없다. 있으면 그것이 곧 «화면이 목적지를 지어냈다»다.
#    고정 목적지가 필요하면 `AppRoutes.*` 상수를 쓴다(화면 명세가 그 버튼을 명시한 경우만).
#    주석 줄은 건너뛴다(설명은 정상) — 코드 줄의 따옴표 안 리터럴만 잡는다.
LINK_RE="['\"](aaq|handbook)://"
for pkg in $UI_PKGS; do
  [ -d "$pkg/lib" ] || continue
  hits=$(grep -rnE "$LINK_RE" "$pkg/lib" 2>/dev/null \
         | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|///|\*)' \
         || true)
  if [ -n "$hits" ]; then
    fail "[§4-4] $(basename "$pkg"): 화면 코드에 링크 리터럴이 있다 — 링크는 DTO 가 준 값을 AppLinkOpener 에 그대로 넘긴다:"
    printf '     %s\n' "$hits" | head -20
  fi
done

# ── [6] (예약) — docs/TARGETS.md T-3 · 조립 앱 배선 때 더한다 ─────────────────

# ── [7] 플래너는 operator 전용 (🆕 계약 v1.4 · 01 §14-1 · docs/TARGETS.md T-4) ──
# 🔴 S7-4 입금 플래너는 배럴 밖 라이브러리 `package:ui_analytics/planner.dart` 에 있고
#    **operator 앱만** import 한다(`DEPOSIT_REGISTER` = operator 전용 · 뷰어 미리보기는 v1 제외).
#    viewer 가 가져오면 throw 기본값 프로바이더가 들어와 플래너가 에러로만 뜬다 — 셸은 `planDeposit` 라우트를
#    «폰에서만 쓸 수 있습니다» 부재 안내로 등록한다(01 §14 · 미결 62).
#    같은 규칙을 `ui_analytics/lib` 안쪽 방향(planner 밖 파일이 planner 를 import 0)까지 C-35 ⑥ 이 본다.
#    주석 줄은 건너뛴다(설명은 정상).
PLANNER_RE="['\"]package:ui_analytics/planner\.dart['\"]"
for app in apps/app_viewer_*; do
  [ -d "$app/lib" ] || continue
  hits=$(grep -rnE "$PLANNER_RE" "$app/lib" 2>/dev/null \
         | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|///|\*)' \
         || true)
  if [ -n "$hits" ]; then
    fail "[7] $(basename "$app"): viewer 앱이 플래너(package:ui_analytics/planner.dart)를 import 한다 — 플래너는 operator 전용이다(01 §14-1 · TARGETS T-4):"
    printf '     %s\n' "$hits" | head -20
  fi
done

# ── 결과 ────────────────────────────────────────────────────────────────────
say "──"
if [ "$FAIL" -ne 0 ]; then
  say "❌ 경계 규칙 위반이 있다. 위 🔴 항목을 고치기 전에는 병합할 수 없다."
  say "   근거: 11_앱설계/01_M2_도메인계약 §1-1·§7(C-3) · 00_README §5"
  exit 1
fi
if [ "$WARN" -ne 0 ]; then
  say "✅ 실패 항목 없음. 🟡 경고는 사람이 판정한다(검수 4항 ② 사유 문구)."
else
  say "✅ 경계 규칙 통과."
fi
exit 0
