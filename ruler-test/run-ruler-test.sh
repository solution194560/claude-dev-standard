#!/usr/bin/env bash
# Ruler 규칙 배포 변환 계층 1차 테스트 — 사람(사용자) 수동 실행용 스크립트.
#
# 실행 주체: 사람. 이 스크립트는 에이전트가 실행하지 않는다(작성만 — PLAN_RULER.md §4 Phase 2a).
# 실쓰기 범위: 본 저장소가 아닌 스크래치 영역의 임시 git 복제본($SCRATCH)에서만 실쓰기를
# 수행한다. 본 저장소(REPO_ROOT) 경로에서는 어떤 Ruler 실쓰기(apply/revert)도 실행하지 않는다.
# git push·원격 반영·대화형 [y/N] 프롬프트에 대한 자동 y 응답은 포함하지 않는다(CLAUDE.md §0).
#
# 사용법: bash ruler-test/run-ruler-test.sh   (본 저장소 루트 또는 ruler-test/ 안에서 실행 가능)

set -u

# ── 경로 고정 (P0-A) ────────────────────────────────────────────────────
# REPO_ROOT·LOG_DIR·LOG 는 절대경로로 고정한다. 이후 `cd "$SCRATCH"` 로 작업
# 디렉터리가 바뀌어도 로그는 항상 본 저장소 안에 기록되며, 시나리오 0 종료 후의
# fresh clone 재생성(`rm -rf "$SCRATCH"`)이 로그를 건드릴 수 없다(로그가 복제본 밖에 있으므로).
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/ruler-test/logs"
RUN_ID="run-01-$(date +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/$RUN_ID.log"
mkdir -p "$LOG_DIR"

RULER_VERSION="0.3.44"
RULER="npx @intellectronica/ruler@$RULER_VERSION"   # 버전 고정, 전역 설치 금지

# ── 로그·실행 헬퍼 ──────────────────────────────────────────────────────
# log_line: 로그 파일에 한 줄 기록(화면에도 출력).
log_line() {
  echo "$*" | tee -a "$LOG"
}

# run_fatal: 실패하면 이 실행 회차를 계속할 의미가 없는 선행 단계(clone·버전 확인·
# apply/revert 본 실행 등)에 쓴다. 실패 시 종료코드를 로그에 남기고 즉시 중단한다
# (P2-D "실패 시 즉시 중단"). 실패한 회차의 로그 파일은 삭제하지 않고 그대로 보존한다.
run_fatal() {
  local desc="$1"; shift
  log_line "=== [필수 단계] $desc ==="
  log_line "+ pwd: $(pwd)"
  log_line "+ cmd: $*"
  if "$@" >>"$LOG" 2>&1; then
    log_line "exit=0"
  else
    local ec=$?
    log_line "exit=$ec"
    log_line "FATAL: '$desc' 실패(exit=$ec) — 회차 $RUN_ID 중단. 로그 보존: $LOG"
    exit 1
  fi
}

# run_step: 시나리오 판정 대상 명령(diff·grep·git status·git diff 등)에 쓴다. 이런
# 명령의 0이 아닌 종료코드는 스크립트 오류가 아니라 판정에 필요한 정보이므로, 스크립트를
# 중단시키지 않고 종료코드를 로그에 그대로 남긴다(JUDGE 후속 처리 조건 1 — 단계별 종료코드
# 캡처. PLAN §5.1 의 `set -e` + 판정용 diff 조합은 diff 가 실패로 취급돼 스크립트가 조기
# 중단될 수 있어, 이 스크립트는 전역 `set -e` 대신 이 헬퍼로 판정 단계를 명시적으로 감싼다).
# 최종 통과/실패 판정은 이 로그를 근거로 Phase 2c(로그 분석)에서 내린다 — 이 스크립트는
# 원시 증거(명령·pwd·출력·종료코드)만 남긴다.
run_step() {
  local desc="$1"; shift
  log_line "=== [판정 대상] $desc ==="
  log_line "+ pwd: $(pwd)"
  log_line "+ cmd: $*"
  local ec
  if "$@" >>"$LOG" 2>&1; then
    ec=0
  else
    ec=$?
  fi
  log_line "exit=$ec"
  return "$ec"
}

log_line "# Ruler 테스트 실행 로그 — $RUN_ID"
log_line "# REPO_ROOT=$REPO_ROOT"
log_line "# 시작 시각(UTC)=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# ── 사전 준비: 임시 복제본 생성 (본 저장소 밖 스크래치 영역, 커밋 후 clone) ──────
SCRATCH="${TMPDIR:-/tmp}/ruler-test-$(date +%s)"
run_fatal "본 저장소를 스크래치 영역으로 clone" git clone "$REPO_ROOT" "$SCRATCH"

cd "$SCRATCH"
log_line "+ pwd (cd 이후 실행 경로 증명): $(pwd)"

run_fatal "node 버전 확인 (>=23 기대)" node --version
run_fatal "Phase 1 커밋 포함 확인 (.ruler/ 존재 전제)" git log --oneline -1
run_fatal ".ruler/ 소스 5개 파일 목록 확인" ls .ruler/
run_fatal "고정 버전 실물 검증 (P1-6)" npx "@intellectronica/ruler@$RULER_VERSION" --help

# ── 시나리오 1 — dry-run (파일 미쓰기 기대) ─────────────────────────────
log_line ""
log_line "########## 시나리오 1: dry-run ##########"
run_step "dry-run 전 워킹트리 상태" git status --porcelain
run_fatal "dry-run 적용" $RULER apply --agents claude,codex --no-mcp --no-skills --dry-run --verbose
run_step "시나리오 1 판정 — dry-run 후 워킹트리 변경 (빈 출력 기대)" git status --porcelain

# ── 시나리오 0 — 자기 출력 재흡수 선행 검증 (최우선, P0-3 승격) ────────────
log_line ""
log_line "########## 시나리오 0: 자기 출력 재흡수 선행 검증 ##########"
SNAP="${TMPDIR:-/tmp}/ruler-test-snap-$(date +%s)"
mkdir -p "$SNAP"

run_fatal "1회차 apply" $RULER apply --agents claude,codex --no-mcp --no-skills --backup --gitignore --verbose
run_fatal "1회차 산출물 스냅샷 저장 (AGENTS.md)" cp AGENTS.md "$SNAP/AGENTS.1.md"
run_fatal "1회차 산출물 스냅샷 저장 (RULER_CLAUDE.md)" cp RULER_CLAUDE.md "$SNAP/RULER_CLAUDE.1.md"

# 가변 메타데이터 확인·목록화 (P1-5' — diff 정규화 기준의 실측 근거. 여기서는 원시 증거만
# 남기고, 실제 정규화 필터링 여부·패턴 확정은 이 로그를 보는 Phase 2c 분석 단계에서 한다)
run_step "1회차 산출물 헤더 30줄 확인 (가변 메타데이터 실측용)" head -30 AGENTS.md RULER_CLAUDE.md

run_fatal "2회차 apply (자기 재흡수 실측)" $RULER apply --agents claude,codex --no-mcp --no-skills --backup --gitignore --verbose

run_step "시나리오 0 판정 — AGENTS.md 1회차 vs 2회차 diff (차이 없음 기대)" diff "$SNAP/AGENTS.1.md" AGENTS.md
S0_AGENTS_EC=$?
run_step "시나리오 0 판정 — RULER_CLAUDE.md 1회차 vs 2회차 diff (차이 없음 기대)" diff "$SNAP/RULER_CLAUDE.1.md" RULER_CLAUDE.md
S0_CLAUDE_EC=$?

# 시나리오 0 중단 분기 (PLAN §5.3 "실패 시 이후 시나리오를 진행하지 않고 결과를 기록 후
# 종료"·§5.5 중단 조건·§5.1 실패 규칙 — VERIFY JUDGE P0 반영). 1차 판정은 위 원시(raw)
# diff 종료코드로 한다. diff 가 발견돼도 즉시 "재흡수 확정" 은 아니다 — 차이가 가변
# 메타데이터(타임스탬프 등)일 가능성이 있으므로, diff 원문(위 run_step 이 로그에 캡처)과
# head -30 실측 기록을 보존한 채 종료하고, 사람이 이 로그로 Phase 2c 에서 정규화 재판정한다.
if [ "$S0_AGENTS_EC" -ne 0 ] || [ "$S0_CLAUDE_EC" -ne 0 ]; then
  log_line ""
  log_line "시나리오 0 실패: 자기 출력 재흡수 확인 — 도입 보류 (AGENTS.md diff exit=$S0_AGENTS_EC, RULER_CLAUDE.md diff exit=$S0_CLAUDE_EC)"
  log_line "# diff 원문은 위 '[판정 대상] 시나리오 0 판정' 블록에 캡처돼 있다(원문 보존)."
  log_line "# 단, 이 1차 판정은 원시 diff 기준이다 — 차이가 가변 메타데이터(타임스탬프 등)일"
  log_line "# 가능성이 있으므로, Phase 2c 에서 위 head -30 실측 기록과 diff 원문으로 정규화"
  log_line "# 재판정할 수 있다(PLAN §5.3 diff 정규화 기준). 재흡수 확정 시 §5.5 중단 조건 처리."
  log_line "PLAN §5.3/§5.5 에 따라 이후 시나리오(fresh clone·본 apply 등)를 진행하지 않고 종료한다."
  log_line "스크래치 복제본(수동 정리 필요): $SCRATCH"
  log_line "로그 경로: $LOG"
  exit 1
fi
log_line "시나리오 0 통과(원시 diff 차이 없음) — 다음 단계 진행."

# ── 시나리오 0 종료 후 상태 초기화 (P1-3' — fresh clone 재생성) ───────────
log_line ""
log_line "########## 상태 초기화: fresh clone 재생성 (revert 비의존, P1-3') ##########"
cd "$REPO_ROOT"
run_fatal "연속 2회 apply 로 오염된 이전 스크래치 복제본 삭제 (본 저장소 아님)" rm -rf "$SCRATCH"
run_fatal "본 시험용 fresh clone 재생성" git clone "$REPO_ROOT" "$SCRATCH"
cd "$SCRATCH"
log_line "+ pwd (fresh clone 이후): $(pwd)"

# ── 본 시험: apply → 시나리오 점검(스크립트 담당분 2·3·4·5(부분)·9(부분)·13) ────
log_line ""
log_line "########## 본 시험: 본 apply ##########"
run_step "본 apply 전 워킹트리 상태" git status --porcelain
run_fatal "본 apply 실행 (백업·gitignore 자동, MCP·스킬 비활성)" $RULER apply --agents claude,codex --no-mcp --no-skills --backup --gitignore --verbose

log_line ""
log_line "--- 시나리오 2: 대상 제한 (기대 diff = RULER_CLAUDE.md·AGENTS.md 생성 + .gitignore 블록 변경만, P1-4') ---"
run_step "apply 후 생성 파일 확인" ls -la RULER_CLAUDE.md AGENTS.md
run_step "시나리오 2 판정 — apply 후 워킹트리 변경 목록" git status --porcelain

log_line ""
log_line "--- 시나리오 3: CLAUDE.md §0 보존 ---"
run_step "시나리오 3 판정 — CLAUDE.md diff (변경 0 기대)" git diff -- CLAUDE.md

log_line ""
log_line "--- 시나리오 4: 플러그인·에이전트 정본 무변경 ---"
run_step "plugin.json·marketplace.json JSON 유효성" python3 -c "import json;json.load(open('.claude-plugin/plugin.json'));json.load(open('.claude-plugin/marketplace.json'));print('OK')"
run_step "시나리오 4 판정 — agents/ 디렉터리 diff (변경 0 기대)" git diff -- agents/

log_line ""
log_line "--- 시나리오 5(부분 — 스크립트 grep 몫): AGENTS.md 에 10-safety 내용 포함 확인 ---"
run_step "AGENTS.md 내 git push 금지 문구 확인" grep -n "git push" AGENTS.md
run_step "AGENTS.md 내 [y/N] 응답 금지 문구 확인" grep -n "y/N" AGENTS.md
run_step "AGENTS.md 내 드라이런 원칙 문구 확인" grep -n "드라이런" AGENTS.md
log_line "# 나머지(codex read-only 실행 확인)는 Phase 2c 에서 에이전트가 수행한다(§5.3 시나리오 5 절차)."

log_line ""
log_line "--- 시나리오 9(부분): 위험 명령 차단 — deny 규칙 실존·서브커맨드 미차단 사실 ---"
run_step "settings.json.example 내 --apply deny 규칙 확인" grep -n -- "--apply" templates/.claude/settings.json.example
run_step "settings.json.example 내 --yes deny 규칙 확인" grep -n -- "--yes" templates/.claude/settings.json.example
run_step "settings.json.example 내 --no-dry-run deny 규칙 확인" grep -n -- "--no-dry-run" templates/.claude/settings.json.example
run_step "settings.json.example 내 git push deny 규칙 확인" grep -n "git push" templates/.claude/settings.json.example
log_line "# 사실 명기: 위 deny 는 --apply 플래그 패턴이며 'ruler apply' 서브커맨드 자체는 차단하지"
log_line "# 않는다(§5.3 시나리오 9 상세). 1차 방어는 실행 주체 분리 — 이 스크립트의 실쓰기 명령은"
log_line "# 전부 사람이 이 복제본 경로($SCRATCH)에서만 실행하며, 본 저장소(REPO_ROOT)에서는 실행하지"
log_line "# 않는다. 위 pwd 기록이 그 증거다."

log_line ""
log_line "--- 시나리오 13: 한글 경로 파일 존재 상태에서 apply (본 apply 에 이미 포함) ---"
run_step "한글 파일명 존재·인코딩 오류 없음 확인" ls -la "Ruler-적용-테스트-설계.md"

# ── 시나리오 11 — revert ────────────────────────────────────────────────
log_line ""
log_line "########## 시나리오 11: revert ##########"
run_fatal "revert 실행" $RULER revert --verbose
run_step "시나리오 11 판정 — revert 후 워킹트리 상태 (apply 이전 상태로 복원 기대, .gitignore 블록 원복 포함, P1-4')" git status --porcelain
run_step "시나리오 11 판정 — 생성물 제거 확인 (두 파일 모두 없어야 함)" ls -la RULER_CLAUDE.md AGENTS.md

# ── 시나리오 12 — revert 후 재적용 ──────────────────────────────────────
log_line ""
log_line "########## 시나리오 12: revert 후 재적용 ##########"
run_fatal "재적용 (revert 후 재 apply)" $RULER apply --agents claude,codex --no-mcp --no-skills --backup --gitignore --verbose
run_step "시나리오 12 판정 — 시나리오 0 1회차 스냅샷과 재적용 결과 diff (AGENTS.md, 동일 결과 기대)" diff "$SNAP/AGENTS.1.md" AGENTS.md
run_step "시나리오 12 판정 — 시나리오 0 1회차 스냅샷과 재적용 결과 diff (RULER_CLAUDE.md, 동일 결과 기대)" diff "$SNAP/RULER_CLAUDE.1.md" RULER_CLAUDE.md

# ── 시나리오 10 — 반복성 (위 시나리오 0·12 diff 결과를 인용해 교차 확인) ──────
log_line ""
log_line "########## 시나리오 10: 반복성 ##########"
log_line "# 판정은 위 '시나리오 0 판정' diff 결과(1회차 vs 2회차)와 '시나리오 12 판정' diff 결과"
log_line "# (1회차 스냅샷 vs revert-후-재적용)를 함께 참고해 로그 분석 단계(Phase 2c)에서 종합한다."

log_line ""
log_line "########## 회차 $RUN_ID 완료 ##########"
log_line "종료 시각(UTC)=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
log_line "로그 경로: $LOG"
log_line "스크래치 복제본(수동 정리 필요 — 이 스크립트는 자동 삭제하지 않음): $SCRATCH"
