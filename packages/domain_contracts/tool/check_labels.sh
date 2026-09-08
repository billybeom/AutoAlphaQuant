#!/usr/bin/env bash
# check_labels.sh — C-5 보조 스캐너 (초안)
#
# 정본: 11_앱설계/01_M2_도메인계약_초안.md §1-5 · §7 C-5
#   C-5 = `ui_*` 전 파일(🔴 `lib/l10n/labels.dart` 제외)에서
#         ① **한글 문자열 리터럴 0건** ② `'TIER '`·`'SAF-'` 리터럴 금지.
#
# 🔴 이 스크립트는 **보조**다. C-5 의 정본 구현은 `test/` 의 계약 테스트이며(영역 F),
#    여기서 통과했다고 C-5 를 대신하지 않는다. 반대로 여기서 걸린 것은 거의 언제나 진짜다.
# 🔴 **주석은 대상이 아니다** — 한국어 주석은 규약상 허용이고(문서 절 번호를 인용한다),
#    금지되는 것은 «상태를 설명하는 문장을 화면이 만드는 것», 즉 **문자열 리터럴**이다.
#    그래서 단순 grep 이 아니라 아래 awk 가 주석·문자열을 갈라 읽는다.
#
# 사용:
#   tool/check_labels.sh                 # packages/ui_*/lib 전부 검사
#   tool/check_labels.sh <경로> [<경로>…] # 지정한 경로만
#   tool/check_labels.sh --ramp          # ⚠️ M2-3 소유 «램프» 접두 검사(기본 꺼짐)
#
# 종료 코드: 0 = 위반 없음 · 1 = 위반 있음 · 2 = 사용법·환경 오류.
#
# 🔴 알려진 한계(초안이라 그대로 둔다 — 숨기면 «통과했다»가 거짓이 된다)
#   · 여러 줄에 걸친 문자열(`'''`·`"""`)은 첫 줄만 본다.
#   · 문자열 보간 `${...}` 안의 코드도 문자열로 읽는다(과탐 방향 = 안전한 쪽).
#   · 생성 파일(`*.g.dart`·`*.freezed.dart`·`*.mocks.dart`)은 제외한다.

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME="${0##*/}"
RAMP_CHECK=0
declare -a TARGETS=()

for arg in "$@"; do
  case "${arg}" in
    --ramp) RAMP_CHECK=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    -*)
      printf '%s: unknown option: %s\n' "${SCRIPT_NAME}" "${arg}" >&2
      exit 2
      ;;
    *) TARGETS+=("${arg}") ;;
  esac
done

# 저장소 루트 = 이 스크립트의 ../../.. (packages/domain_contracts/tool → repo root)
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
readonly REPO_ROOT

if [ "${#TARGETS[@]}" -eq 0 ]; then
  # C-5 의 대상은 `ui_*` 다. `apps/*` 도 화면 코드를 담으면 같은 규약을 진다.
  for d in "${REPO_ROOT}"/packages/ui_*/lib "${REPO_ROOT}"/apps/*/lib; do
    [ -d "${d}" ] && TARGETS+=("${d}")
  done
fi

if [ "${#TARGETS[@]}" -eq 0 ]; then
  printf '%s: 검사할 경로가 없습니다 (ui_* 패키지가 아직 없는 상태일 수 있습니다)\n' \
    "${SCRIPT_NAME}" >&2
  exit 0
fi

# ── 1. 대상 파일 목록 ────────────────────────────────────────────────────────
# 🔴 `lib/l10n/labels.dart` 는 **정적 UI 라벨의 유일한 자리**라 C-5 의 예외다(§1-5).
collect_files() {
  find "$@" -type f -name '*.dart' \
    ! -name '*.g.dart' \
    ! -name '*.freezed.dart' \
    ! -name '*.mocks.dart' \
    ! -path '*/l10n/labels.dart' \
    ! -path '*/.dart_tool/*' \
    ! -path '*/build/*' \
    | sort
}

# ── 2. 문자열 리터럴만 뽑아낸다 (주석 제외) ──────────────────────────────────
# 출력 형식: <파일>\t<줄번호>\t<리터럴 본문>
extract_literals() {
  awk '
    BEGIN { inblock = 0 }
    {
      line = $0
      n = length(line)
      i = 1
      buf = ""
      instr = 0        # 0=코드, 1=작은따옴표, 2=큰따옴표
      quote = ""
      while (i <= n) {
        c = substr(line, i, 1)
        if (inblock) {
          if (c == "*" && substr(line, i + 1, 1) == "/") { inblock = 0; i += 2 } else { i += 1 }
          continue
        }
        if (instr == 0) {
          if (c == "/" && substr(line, i + 1, 1) == "/") { break }            # 줄 주석
          if (c == "/" && substr(line, i + 1, 1) == "*") { inblock = 1; i += 2; continue }
          if (c == "\047" || c == "\042") { instr = (c == "\047") ? 1 : 2; quote = c; buf = ""; i += 1; continue }
          i += 1
          continue
        }
        # 문자열 안
        if (c == "\\") { buf = buf substr(line, i, 2); i += 2; continue }
        if (c == quote) {
          if (buf != "") { printf "%s\t%d\t%s\n", FILENAME, FNR, buf }
          instr = 0; buf = ""; i += 1; continue
        }
        buf = buf c
        i += 1
      }
      # 🔴 여러 줄 문자열은 줄 끝에서 상태를 버린다(알려진 한계).
      if (instr != 0 && buf != "") { printf "%s\t%d\t%s\n", FILENAME, FNR, buf }
    }
  ' "$@"
}

# ── 3. 한글 탐지 — grep -P 가 있으면 코드포인트로, 없으면 UTF-8 선행바이트로 ──
readonly HANGUL_PCRE='(*UTF)[\x{AC00}-\x{D7A3}\x{3130}-\x{318F}]'
# 🔴 환경 차이가 큰 자리다 — «실제 한글»로 탐침해 되는 방식을 고른다.
#    되는 방식이 하나도 없으면 조용히 통과시키지 않고 **환경 오류로 죽는다**(exit 2):
#    「검사가 없었는데 통과로 보이는 것」이 이 스크립트가 가장 하면 안 되는 일이다.
HANGUL_MODE=''
if printf '\355\225\234\n' | grep -qP "${HANGUL_PCRE}" 2>/dev/null; then
  HANGUL_MODE='pcre'
elif printf '\355\225\234\n' | LC_ALL=C grep -q "$(printf '[\352-\355]')" 2>/dev/null; then
  HANGUL_MODE='bytes'
fi
readonly HANGUL_MODE

hangul_filter() {
  case "${HANGUL_MODE}" in
    pcre) grep -P "${HANGUL_PCRE}" ;;
    # Hangul Syllables(U+AC00–U+D7A3)의 UTF-8 선행바이트는 0xEA–0xED 다.
    # 🔴 과탐 방향(같은 선행바이트의 다른 3바이트 문자도 걸린다)이며 그것이 안전한 쪽이다.
    bytes) LC_ALL=C grep "$(printf '[\352-\355]')" ;;
    *)
      printf '%s: 한글 탐지 수단이 없습니다(grep -P·바이트 범위 모두 실패)\n' \
        "${SCRIPT_NAME}" >&2
      exit 2
      ;;
  esac
}

violations=0
report() { # <제목> <내용(빈 줄이면 통과)>
  local title="$1" body="$2"
  if [ -n "${body}" ]; then
    printf '\n[FAIL] %s\n%s\n' "${title}" "${body}"
    violations=$((violations + 1))
  else
    printf '[ok]   %s\n' "${title}"
  fi
}

mapfile -t FILES < <(collect_files "${TARGETS[@]}")
if [ "${#FILES[@]}" -eq 0 ]; then
  printf '%s: 대상 .dart 파일 0건 — 검사할 것이 없습니다\n' "${SCRIPT_NAME}"
  exit 0
fi
printf '%s: 대상 %d 파일\n' "${SCRIPT_NAME}" "${#FILES[@]}"

LITERALS="$(extract_literals "${FILES[@]}" || true)"

# C-5 ① 한글 문자열 리터럴
report "C-5 ① 한글 문자열 리터럴 0건" \
  "$(printf '%s\n' "${LITERALS}" | hangul_filter || true)"

# C-5 ② 'TIER ' · 'SAF-' 리터럴
report "C-5 ② 'TIER '·'SAF-' 리터럴 금지" \
  "$(printf '%s\n' "${LITERALS}" | grep -E 'TIER |SAF-' || true)"

# C-32 보조 — 월 납입 금액으로 읽힐 리터럴(01 §2-6 G-89 · m2-8_naming H-10)
# 🔴 정본은 계약 테스트 C-32 다. 여기서는 «리터럴» 판정만 거들고, 픽스처·명세 산문은 대상이 아니다.
report "C-32 보조 — 월 납입 금액 리터럴 금지" \
  "$(grep -nHE '(^|[^0-9_])(100000|90000|97000|124000|100_000)([^0-9_]|$)' "${FILES[@]}" 2>/dev/null || true;
     printf '%s\n' "${LITERALS}" | grep -E '10만|9\.7만' || true)"

# ⚠️ M2-3 소유 추가 검사(번호 없음) — 기본 꺼짐.
# 🔴 «램프»가 접두(«운영 램프»/«초기 진입») 없이 단독으로 쓰인 항목 0건.
#    OpsRamp(L0~L5)와 EntryRamp(초기 진입 6개월 분할)는 **다른 것**이고 하나의 위젯으로 합치지 않는다.
# 🔴 C-5 전역 경고로 만들지 않는다(개발 쪽 경보 피로) — 그래서 `--ramp` 로만 돈다.
if [ "${RAMP_CHECK}" -eq 1 ]; then
  declare -a RAMP_TARGETS=()
  for d in "${REPO_ROOT}"/packages/ui_*/lib/l10n/labels.dart "${REPO_ROOT}"/apps/*/lib/l10n/labels.dart; do
    [ -f "${d}" ] && RAMP_TARGETS+=("${d}")
  done
  if [ "${#RAMP_TARGETS[@]}" -eq 0 ]; then
    printf '[skip] M2-3 «램프» 접두 검사 — labels.dart 0건\n'
  else
    report "M2-3 «램프» 접두 검사(labels.dart 전수)" \
      "$(grep -n '램프' "${RAMP_TARGETS[@]}" | grep -v -e '운영 램프' -e '초기 진입' || true)"
  fi
fi

printf '\n'
if [ "${violations}" -gt 0 ]; then
  printf '%s: 위반 %d 종\n' "${SCRIPT_NAME}" "${violations}" >&2
  printf '🔴 C-5 위반은 «잘못된 화면»이 아니라 «빌드 실패»다. 문구는 DTO 의 label 필드로 받는다.\n' >&2
  exit 1
fi
printf '%s: 위반 없음\n' "${SCRIPT_NAME}"
exit 0
