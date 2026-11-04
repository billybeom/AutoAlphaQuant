#!/usr/bin/env bash
# ============================================================================
# check_boundaries_selftest.sh — 경계 검사 [8][9] 자가 시험(🆕 설계 13 §8 R53 I6 · E11i)
#
# 무엇을 하나: 저장소 사본(추적 + 추적 안 된 새 파일 · .gitignore 제외)을 임시 폴더에 만들고,
#   경우를 하나씩 꾸며 tool/check_boundaries.sh 를 돌린다 — 통과해야 할 것은 통과하고, 실패해야 할 것은
#   그 항목 번호로 실패하는지 본다. 성공 = exit 0.
# 언제 부르나: check_boundaries.sh 의 [8][9] 를 고칠 때 손으로(CI 잡에는 아직 없다).
#   bash tool/check_boundaries_selftest.sh
# 🔴 저장소 파일은 건드리지 않는다(사본만 고친다).
# ============================================================================
set -u
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
( cd "$SRC" && git ls-files --cached --others --exclude-standard -z | tar --null -cf - -T - ) | ( cd "$WORK" && tar -xf - )
BAD=0
VP="$WORK/apps/app_viewer_ios/pubspec.yaml"
RP="$WORK/packages/read_model_client/pubspec.yaml"
RL="$WORK/packages/read_model_client/lib/src/version_gate.dart"

run() { ( cd "$WORK" && bash tool/check_boundaries.sh </dev/null 2>&1 ); }
expect_pass() { local out; out=$(run); if [ $? -ne 0 ]; then echo "✗ $1: 통과해야 하는데 실패"; echo "$out" | grep '🔴' | head -5; BAD=1; else echo "✓ $1"; fi; }
expect_fail() { local out rc; out=$(run); rc=$?; if [ $rc -eq 0 ] || ! printf '%s' "$out" | grep -qF -- "$2"; then echo "✗ $1: «$2» 실패가 나와야 한다(rc=$rc)"; BAD=1; else echo "✓ $1"; fi; }
backup() { cp "$1" "$1.selftest"; }
restore() { mv "$1.selftest" "$1"; }

expect_pass 'A 지금 저장소 = 통과'

backup "$VP"
sed -i 's#^  read_model_client:#  data_sync:\n    path: ../../packages/data_sync\n  read_model_client:#' "$VP"
expect_fail 'B viewer 직접 data_sync' 'data_sync ← app_viewer_ios'
expect_fail 'B2 전이 core_engine 도 보인다' 'core_engine ← data_sync'
restore "$VP"

backup "$VP"
sed -i 's#^  read_model_client:#  sqlite3: ^2.4.0\n  read_model_client:#' "$VP"
expect_fail 'C viewer 호스티드 sqlite3' 'sqlite3 ← app_viewer_ios'
restore "$VP"

backup "$RP"
sed -i 's#^dev_dependencies:#  trading_runtime:\n    path: ../trading_runtime\n\ndev_dependencies:#' "$RP"
expect_fail 'D read_model_client → trading_runtime ([9] pubspec)' '[9] read_model_client: pubspec'
expect_fail 'D2 같은 것을 [8] 이 전이로' 'broker_gateway ← trading_runtime'
restore "$RP"

backup "$RL"
printf "\nimport 'package:decimal/decimal.dart';\n" >> "$RL"
expect_fail 'E lib 가 decimal import' '[9] read_model_client: lib/'
restore "$RL"

backup "$VP"
printf "  data_sync:\n    path: ../../packages/data_sync\n" >> "$VP"   # 파일 끝 = dev_dependencies 블록 안
expect_pass 'F dev_dependencies 의 data_sync 는 실패 아님'
restore "$VP"

backup "$RL"
printf "\n// package:core_engine/ 는 여기서 쓰지 않는다\n/// 'package:data_sync/x.dart' 설명\n" >> "$RL"
expect_pass 'G 주석 줄의 금지 import 는 실패 아님'
restore "$RL"

mv "$WORK/packages/read_model_client" "$WORK/rmc.selftest"
expect_fail 'H read_model_client 없음' '[9] packages/read_model_client 가 없다'
mv "$WORK/rmc.selftest" "$WORK/packages/read_model_client"

backup "$RP"
sed -i 's#^dev_dependencies:#  data_sync:\n    path: ../data_sync\n\ndev_dependencies:#' "$RP"
expect_fail 'I 두 단계 전이(viewer → read_model_client → data_sync)' 'data_sync ← read_model_client'
restore "$RP"

backup "$RP"
sed -i 's#^dev_dependencies:#  decimal: ^3.0.0\n\ndev_dependencies:#' "$RP"
expect_fail 'J read_model_client 호스티드 decimal ([9] pubspec)' '[9] read_model_client: pubspec'
restore "$RP"

if [ $BAD -ne 0 ]; then echo "== 자가 시험 실패"; exit 1; fi
echo "== 자가 시험 통과"
exit 0
