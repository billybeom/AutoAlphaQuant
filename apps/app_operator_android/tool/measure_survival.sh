#!/usr/bin/env bash
# E11p2 · P13 ③ — Android 생존 실측(06 M1-11 게이트 · 13 D11 · D22): FGS 5분 생존 · 정확 알람 1회 · Doze 지연.
#
#   bash tool/measure_survival.sh <adb 기기 id> [<결과 파일>]
#
# 에뮬레이터는 Doze 를 `dumpsys deviceidle force-idle` 로 «흉내»만 낸다 — 🔴 제조사 절전(삼성 등)은 폰 실측(D22)에서만 보인다.
# 앱은 미리 설치 · 한 번 실행(알림 허용)돼 있어야 한다. 🔴 키 · 실값 0(앱 설정 없이 돈다).
set -u
DEV="${1:?adb 기기 id}"
OUT="${2:-survival_$(date +%Y%m%d_%H%M%S).txt}"
ADB="${ADB:-adb}"
PKG=com.billybeom.autoalphaquant.operator
say() { echo "$*" | tee -a "$OUT"; }
fgs() { "$ADB" -s "$DEV" shell dumpsys activity services "$PKG" | tr -d '\r' | grep -c "isForeground=true"; }

say "# E11p 생존 실측 · $(date -Iseconds) · 기기 $DEV · $("$ADB" -s "$DEV" shell getprop ro.product.model | tr -d '\r') · Android $("$ADB" -s "$DEV" shell getprop ro.build.version.release | tr -d '\r')"
"$ADB" -s "$DEV" shell pm grant "$PKG" android.permission.POST_NOTIFICATIONS 2>/dev/null
"$ADB" -s "$DEV" shell am start -W -n "$PKG/.MainActivity" >/dev/null
sleep 5
say "① 시작 직후 FGS = $(fgs)"

# ② FGS 5분 생존 — 화면을 끄고 홈으로 보낸 뒤 5분.
"$ADB" -s "$DEV" shell input keyevent KEYCODE_HOME
"$ADB" -s "$DEV" shell input keyevent KEYCODE_SLEEP
sleep 300
say "② 화면 끈 뒤 5분 FGS = $(fgs) (1 = 살아 있음)"

# ③ 정확 알람 + Doze — 시험 알람(70초 뒤)을 걸고 Doze 를 강제한다.
"$ADB" -s "$DEV" shell am broadcast -n "$PKG/.ops.ProbeReceiver" --el delayMs 70000 >/dev/null
"$ADB" -s "$DEV" shell dumpsys battery unplug
"$ADB" -s "$DEV" shell dumpsys deviceidle force-idle | tr -d '\r' | tee -a "$OUT"
sleep 150
"$ADB" -s "$DEV" shell dumpsys deviceidle unforce >/dev/null
"$ADB" -s "$DEV" shell dumpsys battery reset
say "③ 깨어남 기록(마지막 5줄 · scheduledAtMs → firedAtMs · deviceIdle):"
"$ADB" -s "$DEV" shell run-as "$PKG" cat files/aaq_wake_log.jsonl 2>/dev/null | tr -d '\r' | tail -5 | tee -a "$OUT"
say "④ 시작 막힘 · 자가진단은 앱 로그(flutter) 참조 · 끝"
