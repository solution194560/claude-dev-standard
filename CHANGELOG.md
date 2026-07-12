# 변경 이력 (CHANGELOG)

<!-- 완료된 작업만 기록합니다. 진행 중은 SESSION.md. 최신이 맨 위. -->

---

## 2026-07-12 — 문서 정리 + 안전 정책 문서 정합화

**무엇을**
- 개발 과정 문서 정리 — 게이트 진행 문서(PLAN·REVIEW·JUDGE·VERIFY·FINAL) 10개, 검증 결과 2개,
  초기 설계 1개, 테스트 로그 1개 삭제(기록은 git 히스토리 보존). README·CHANGELOG의 삭제 문서
  링크 정리. 배포·운영 핵심(`.ruler/`·생성물·`ruler-test/`·CLAUDE.md·README)만 유지.
- 안전 정책 문서 정합화 — 4개 정책 소스 대조에서 발견한 갭 반영. `CLAUDE.md §0` 위험 작업 목록
  주석을 수정해, 실쓰기 플래그(`--apply`·`--yes`·`--no-dry-run`)와 `.env` 접근 차단의 정본이
  deny(`.claude/settings.json`)와 `.ruler/10-safety.md`임을 명시하고 §0 목록은 대표 항목임을
  분명히 함(정책 자체 불변, 문서 정합화만).

**정책 대조 결과** 게이트·증거 정책은 CLAUDE.md(포인터)·`.ruler/`(정본)·서브에이전트(자체 명시)로
정합. 안전 정책만 §0 목록이 deny·`.ruler/`보다 항목이 적어 문서상 어긋났고(실질 차단은 deny가
강제하므로 안전 유지), 위 주석 수정으로 정합화.

---

## 2026-07-12 — Ruler 정본 이관 Phase 2·3 완료 (CLAUDE.md 슬림화 + 임포트)

**무엇을** 정본 이관 Phase 2(사람 apply·생성물 커밋)·Phase 3(CLAUDE.md 슬림화) 완료.
- **Phase 2** 사람이 본 저장소에서 `ruler apply`(§3.5) 실행 → 생성물 `RULER_CLAUDE.md`·`AGENTS.md`
  생성·커밋(git 추적). `.codex/config.toml` 미생성·`.gitignore` 무변경·check-sync 일치 확인.
- **Phase 3** `CLAUDE.md` 슬림화 — §4 의 공통 규칙 중복 3건(gate-judge 확정 문단·외부 도구 판정
  기준 문장·"모든 에이전트 실쓰기 금지" 불릿)을 삭제(정본 `.ruler/` 20-process·30-evidence·
  10-safety 로 이관). §0 위험 작업 목록 서두·§4 표 아래에 공통 규칙 참조 한 줄씩 추가, §0 테스트
  명령에 `check-sync.sh` 추가, §5 에 정본·생성물 운영 정책 추가, 맨 아래 `@RULER_CLAUDE.md`
  임포트 블록 추가(본 저장소 개발 전용·templates 배포 금지 주석).

**검증(오프라인)** O1~O8 전부 통과 — 삭제 키 문구 4건 `grep -F` 부재, 잔류 대상 보존, 임포트·주석
존재, check-sync exit 0, 생성물 git 추적, JSON·`bash -n` OK, `agents/`·`skills/`·`templates/`·
`.gitignore` 무변경. 삭제 3건의 대응 의미가 생성물(정본 `.ruler/`)에 보존됨을 확인(의미 대조).

**실데이터 검증 완결(2026-07-12)** R1(사람 apply)·R2(반복성)·R3(새 세션 임포트 실로드 —
출처까지 식별)·R4(Codex 안전룰 인식) 전부 통과. 증거는
RULER_MIGRATION_RESULT.md. **정본 이관 완결** — `.ruler/` 가 공통
규칙 단일 정본, CLAUDE.md 중복 3건 제거·임포트 실로드 확정, 기존 플러그인 무손상.

---

## 2026-07-12 — Ruler 정본 이관 Phase 1 (정본·도구 준비, 경량 경로)

**무엇을** PLAN_RULER_MIGRATION.md 계획 점검 APPROVE 확정
(PLAN_RULER_MIGRATION_REVIEW_JUDGE.md 3차) 후 Phase 1 구현.
- `.ruler/ruler.toml` — `[gitignore] enabled=false`·`[backup] enabled=false` 로 전환(생성물 커밋
  A안과의 충돌 제거, `.bak` 노이즈 제거). `apply --help` 로 `--no-gitignore`·`--no-backup`
  플래그 실재 확정(yargs boolean 부정).
- `.ruler/00-overview.md` — "생성물 운영(정본 이관 후)" 절 추가(사람 재생성 절차·`.codex/config.toml`
  미생성 실측 문서화 — VERIFY DONE 후속 ②).
- `ruler-test/check-sync.sh` — 신규. 정본(`.ruler/*.md`)과 생성물(RULER_CLAUDE.md·AGENTS.md)의
  내용 일치를 대조하는 읽기 전용 스크립트(Ruler 미실행, 에이전트·CI 실행 가능). 주석·빈 줄
  정규화로 대조. 생성물 부재 시 exit 2.
- `ruler-test/run-ruler-test.sh` — apply 명령 4곳 + dry-run 을 `--no-backup --no-gitignore` 로
  교체([A-1]), revert 직후 `git diff -- .gitignore` 캡처 스텝 추가(후속 ①), 시나리오 2·11
  기대값을 새 정책 기준으로 갱신.

**검증(오프라인)** `bash -n` 두 스크립트 OK, toml 파싱 OK(gitignore=false·backup=false),
§0 JSON 검증 OK, apply 명령에 비부정 `--backup`/`--gitignore` 잔존 없음, check-sync 생성물
부재 시 exit 2. `CLAUDE.md`·`agents/`·`skills/`·`templates/` 무변경 확인.

**다음** Phase 2 — 사람이 본 저장소에서 `ruler apply` 실행(§3.5) → 생성물 2개 커밋 → check-sync
일치 확인. 이후 Phase 3 에서 CLAUDE.md 슬림화 + 임포트 추가.

---

## 2026-07-12 — [계획 단계] Ruler 정본 이관 계획 작성·개정(3차)

**무엇을** 1차 테스트 FINAL DONE 후속 — CLAUDE.md 공통 규칙을 `.ruler/` 정본으로 일원화
(슬림화 + `@RULER_CLAUDE.md` 임포트)하고 생성물을 커밋 전환(A안, 사람 apply)하는 계획 문서
PLAN_RULER_MIGRATION.md 작성 (5단계 게이트 1단계 산출물).
1차 점검 REVISE → 수정 요구 6건 반영 2차 개정, 2차 재점검도 REVISE 확정
(PLAN_RULER_MIGRATION_REVIEW_JUDGE.md, 1차 요구 5건
해소·1건 부분해소)되어 잔존 2건을 반영해 **3차 개정** — §3.1 O3 키 문구를 CLAUDE.md raw
원문(`**권고**만 하며`, 볼드 마커 포함)과 일치하도록 정정하고 O3(i) 를 `grep -F` 로 명시(A),
§3.5 사람 apply 명령에 `--no-backup` 추가해 스크립트와 플래그 통일(B).

**상태** 계획 단계 — 구현 금지. 3차 개정본으로 plan-reviewer 재점검 + gate-judge 재판정 대기.

**관련 문서** PLAN_RULER.md·RULER_TEST_RESULT.md·
PLAN_RULER_FINAL_2bc_JUDGE.md(선행 DONE 판정)·
PLAN_RULER_MIGRATION_REVIEW.md(2차 점검 보고서)

---

## 2026-07-12 — [구현 3단계] Ruler 규칙 배포 변환 계층 Phase 1·2a 구현 (implementer)

**최종 테스트 통과(2026-07-12)** — gate-judge DONE 확정(PLAN_RULER_FINAL_2bc_JUDGE.md, 시나리오 15/15 PASS·수용 기준 8/8 충족).

**수정 회차(같은 날)** 구현 검증 게이트 FAIL 확정(PLAN_RULER_VERIFY_P1-2a_JUDGE.md)
반려 → 확인 결함 2건을 `ruler-test/run-ruler-test.sh` 에서만 수정. ① P0 — 시나리오 0 판정
diff 종료코드를 캡처해 재흡수 확인 시 "도입 보류" 기록(diff 원문·head -30 실측 보존, 가변
메타데이터 가능성 명기 — Phase 2c 정규화 재판정용) 후 이후 시나리오 미진행 exit 1, 통과
시에만 진행. ② P2 — 시나리오 9 deny grep 을 4패턴(`--apply`·`--yes`·`--no-dry-run`·
`git push`)으로 완성. `bash -n`·§0 테스트 명령 PASS 재확인, 타 파일 무수정.

**무엇을** PLAN_RULER.md(4차 개정본, gate-judge 4차 APPROVE 통과 조건부 —
PLAN_RULER_REVIEW_JUDGE.md) 의 Phase 1 전체 + Phase 2a(스크립트
작성) 구현. Phase 2b(사람 실행)·2c(로그 분석)·Phase 3(본 저장소 반영)은 이번 범위 밖 —
**Phase 2b 사람 실행 대기** 상태로 종료.

**어떻게**
- `.ruler/00-overview.md`·`10-safety.md`·`20-process.md`·`30-evidence.md`·`ruler.toml`
  (PLAN §3.2 초안을 그대로 작성 — Ruler 알파벳순 이어붙이기로 개요→안전→프로세스→증거 순서 고정)
- `ruler-test/run-ruler-test.sh` (PLAN §5.1~§5.3 설계대로 작성, 실행은 사람 몫 — 이 세션은
  실행하지 않음): REPO_ROOT 절대경로 로그 고정(P0-A) → 스크래치 clone → node/npx 버전·
  `--help` 실물 검증 → dry-run(시나리오 1) → 시나리오 0(2회 apply + 정규화용 원시 증거) →
  fresh clone 재초기화(P1-3') → 본 apply → 스크립트 담당 시나리오 점검(2·3·4·5 부분·9 부분·13)
  → revert(11) → 재적용(12) → 시나리오 10 교차 확인 인용

**계획 대비 편차**
- JUDGE 4차 판정 후속 처리 조건 1(단계별 종료코드 캡처)을 반영해, PLAN §5.1 코드블록의
  전역 `set -e` + `diff …; echo "exit=$?"` 형태(이 조합은 `diff`가 실패로 처리되는 즉시
  `set -e`가 스크립트를 중단시켜 `echo`가 실행되지 않는 문제가 있음)를 그대로 쓰지 않고,
  전역 `set -e` 없이 `run_fatal`(설정 단계 — 실패 시 로그 남기고 즉시 중단)·`run_step`
  (판정 대상 명령 — 0이 아닌 종료코드를 판정 정보로 로그에 남기고 스크립트는 계속)
  두 헬퍼로 모든 단계를 명시적으로 감쌌다. PLAN이 "`set -e`(또는 단계별 종료코드 검사)"로
  대안을 명시적으로 허용한 범위 내의 구현 선택이다.
- PLAN §5.1 REPO_ROOT 예시의 두 안(하드코딩 절대경로 / `$(cd "$(dirname "$0")/.." && pwd)`)
  중 후자를 채택 — 특정 사용자 경로를 스크립트에 고정하지 않기 위함(PLAN이 "또는"으로 명시한
  대안).
- 시나리오 0 diff 정규화(P1-5')의 실제 필터 패턴은 스크립트가 추측해 하드코딩하지 않고,
  `head -30` 원시 증거만 로그에 남겨 Phase 2c 로그 분석 단계에서 실측 후 결정하도록 함(PLAN이
  "실측된 가변 행 패턴만 제외"라고 명시 — 사전 추측 금지 취지로 해석).
- PLAN §4 Phase 2a의 "(필요 시) 점검 보조 스크립트"는 작성하지 않음 — 정규화·판정 로직을
  전부 주 스크립트의 원시 증거 로깅으로 대체해 불필요.
- 그 외 편차 없음. `.ruler/*.md` 4개·`ruler.toml`은 PLAN §3.2 원문 그대로.

**검증**
- `bash -n ruler-test/run-ruler-test.sh` 문법 통과
- `.ruler/ruler.toml` 파싱 검증 — 이 환경의 `python3`가 3.9.6이라 표준 라이브러리
  `tomllib`(3.11+ 필요)이 없어 `python3 -c "import tomllib..."` 는 `ModuleNotFoundError`.
  대체로 설치돼 있던 `toml` 패키지(0.10.2)로 파싱해 `OK` 확인(동등한 TOML 문법 검증) —
  환경 제약이며 파일 결함 아님. impl-verifier 재확인 시 이 환경차 참고.
- CLAUDE.md §0 테스트 명령(`plugin.json`·`marketplace.json` JSON 검증) PASS
- `git status --porcelain` — 신규 파일은 `.ruler/`·`ruler-test/`뿐, `agents/`·`skills/`·
  `templates/`·`CLAUDE.md`는 `git diff --stat`으로 무수정 확인
- Ruler·npx 명령은 이 세션에서 실행하지 않음(`--help` 포함 — PLAN §4 Phase 2a 지시 준수)

**impl-verifier 확인 포인트**
1. `.ruler/ruler.toml`의 `[agents.claude] output_path = "RULER_CLAUDE.md"` 존재(§0 보존의 핵심).
2. `run-ruler-test.sh`가 본 저장소 경로에서 Ruler 실쓰기(apply/revert)를 실행하지 않고
   전부 `$SCRATCH`(스크래치 복제본)에서만 실행하는 구조인지(주석·pwd 로깅 확인).
3. JUDGE 후속 처리 조건 1(단계별 종료코드 캡처)이 `run_fatal`/`run_step` 두 헬퍼로 실제
   반영됐는지, 위 "계획 대비 편차" 문단의 논리가 타당한지.
4. `git push`·원격 반영·`[y/N]` 자동 응답이 스크립트에 없는지.

**관련 문서** PLAN_RULER.md, PLAN_RULER_REVIEW_JUDGE.md

---

## 2026-07-12 — [계획 단계] Ruler 규칙 배포 변환 계층 1차 테스트 계획 작성·개정(4차)

**무엇을** Ruler(`@intellectronica/ruler`)를 규칙 배포 변환 계층으로 제한 적용하는
1차 테스트 계획 문서 PLAN_RULER.md 작성 (5단계 게이트 1단계 산출물).
1~3차 계획 점검이 모두 REVISE 확정(PLAN_RULER_REVIEW_JUDGE.md)
— 2차 개정(수정 요구 7건), 3차 개정(사람 수동 실행 전환 등 6건)에 이어, 3차 점검(2차 요구
5건 해소·1건 부분해소로 계획 골격 성립)의 신규 결함 4건을 반영해 **4차 개정** — 스크립트
로그 경로 본 저장소 절대경로 고정(P0-A), 시나리오 8·14 절차 본문 확정(P1-B), 시나리오 5
Codex 확인 명령 수준 구체화(P1-C), 실패·재실행 규칙 신설(P2-D), 시나리오 6·7 등가성 한계
명시(상세는 계획 문서 개정 이력).

**왜** 공통 안전·프로세스 규칙을 `.ruler/` 단일 원본에서 Claude·Codex 두 대상으로
반복·복원 가능하게 배포하되 기존 게이트·§0 프로필을 훼손하지 않는지 검증하기 위해.

**상태** 계획 단계 — 구현 금지. 4차 개정본으로 plan-reviewer 재점검 + gate-judge 재판정 대기.

**관련 문서** Ruler-적용-테스트-설계.md(상위 설계),
PLAN_RULER_REVIEW.md(3차 점검 보고서)

---

## 2026-07-12 — quickstart에 워크스페이스 신뢰 승인 안내 추가

**무엇을** 5단계 파이프라인 e2e 검증 중 발견한 헤드리스 실행 블로커를 신뢰 안내로 문서화.

**왜** 새 프로젝트를 처음 `claude -p`로 실행하면 워크스페이스가 "신뢰됨"으로 등록되지 않아
`.claude/settings.json`의 allow 규칙이 무시됩니다. 결과적으로 4·5단계 게이트의 테스트
실행이 막혀 "증거 불충분"으로 반려되는 현상을 e2e에서 실증했습니다.

**어떻게**
- `skills/gated-dev/references/quickstart.md` ① 설치 절에 경고 박스 추가
- "새 프로젝트에서 처음 한 번은 대화형으로 실행해 신뢰 대화상자 승인" 안내
- 미신뢰 상태에서 비대화형 실행의 한계(allow 무시 → 게이트 반려) 설명

**검증**
- e2e 검증 2회: 첫 실행(미신뢰 → 블로커), 신뢰 등록 후(정상 통과)
- 5단계 + 판정 3회 전부 완료, 산출물 7종 명명 규칙 검증, Codex 폴백 확인

**관련 문서** 불명 (이번에 발견된 현상)

---

## 2026-07-11 — 게이트 우회 차단: implementer·final-tester 착수 조건을 JUDGE 확정으로 변경

**무엇을** 재검증 보고서의 P0 2건 적용 — 두 에이전트의 착수 조건을 게이트
에이전트의 **권고 보고서**가 아니라 gate-judge의 **판정 기록(`_JUDGE.md`)** 확인으로 변경.

**왜** 기존 착수 조건은 `*_REVIEW.md`(APPROVE 권고)·`*_VERIFY_*.md`(PASS 권고)만
확인해서, gate-judge 판정 없이도 다음 단계에 진입할 수 있었다. "증거 수집자와
판정자 분리"가 지시문 수준에서 우회 가능했던 구멍을 막는다.

**어떻게**
- `agents/implementer.md` 착수 조건 — `*_REVIEW_JUDGE.md` 필수 확인. JUDGE 파일이
  없거나 APPROVE가 아니면 구현하지 않고 보고 후 종료. REVIEW 권고만으로 착수 금지.
- `agents/final-tester.md` 착수 조건 — `*_VERIFY_<phase>_JUDGE.md` 필수 확인. 동일 원칙.
- `skills/gated-dev/references/process.md` 3·5단계 착수 조건 설명을 동기화(사본 규칙).

**검증**
- plugin.json·marketplace.json·settings.json.example JSON 유효성 통과
- 파일명 패턴이 gate-judge의 명명 규칙(`<입력보고서명>_JUDGE.md`)과 일치 확인

**관련 문서** `claude-dev-standard-업데이트-재검증-수정필요사항.md`(저장소 외부 보고서)

---

## 2026-07-11 — Windows PowerShell 정식 지원 (B안)

**무엇을** 재검증 보고서(`claude-dev-standard-업데이트-재검증-수정필요사항.md`)의
P1 항목 적용 — 셸 실행이 필요한 에이전트에 PowerShell 도구 추가, deny 규칙 미러링.

**왜** Quickstart는 Windows에서 "Git Bash 또는 PowerShell"을 안내하지만 에이전트
도구 목록에는 `Bash`만 있어 문서와 실제 설정이 불일치했다. Claude Code는 Git Bash
없는 네이티브 Windows에서 PowerShell 도구를 자동 사용하므로, 그 환경에서는 실행형
에이전트가 셸을 아예 못 쓰는 상태였다.

**어떻게**
- `agents/` 5종(plan-reviewer·implementer·impl-verifier·final-tester·error-analyst)
  frontmatter `tools:`에 `PowerShell` 추가 (plan-writer·gate-judge는 셸 불필요 — 제외)
- `templates/.claude/settings.json.example` deny에 `PowerShell(*--apply*)`,
  `PowerShell(*--no-dry-run*)`, `PowerShell(*--yes*)`, `PowerShell(git push*)` 추가
- `skills/gated-dev/references/rules.md` deny 설명에 PowerShell 미러 규칙과
  "셸 명령은 Bash·PowerShell 양쪽에 적는다" 안내 추가

**검증**
- plugin.json·marketplace.json·settings.json.example JSON 유효성 통과
- `grep -n "^tools:" agents/*.md` → 실행형 5종에 PowerShell, 비실행형 2종 변경 없음
- PowerShell 도구 실존·권한 규칙 문법은 공식 문서(tools-reference)로 확인

**미적용(보류)** 같은 보고서의 P0 2건 — implementer·final-tester가 gate-judge의
`_JUDGE.md` 판정 파일을 필수 확인하도록 하는 수정. 사용자 결정으로 보류.

**관련 문서** `claude-dev-standard-업데이트-재검증-수정필요사항.md`(저장소 외부 보고서)

---

## 2026-07-11 — OS 호환성 잔여 작업 적용

**무엇을** `OS호환성_잔여작업_지시서.md`의 잔여 3건 적용.

**왜** 모델 세대교체 시 낡은 전체 ID가 남는 이식성 문제와 `python3`만 있는
macOS/Linux 환경 대응.

**어떻게**
- `agents/*.md` 7종 frontmatter `model:`을 전체 ID → 별칭(`opus`/`sonnet`)으로 변경
- `skills/gated-dev/references/agents.md`의 frontmatter 예시도 별칭으로 동기화(사본 규칙)
- `templates/.claude/settings.json.example` allow에 `Bash(python3 -m pytest*)` 추가
- `skills/gated-dev/references/quickstart.md` 사전 준비 절에 OS별 셸·venv 경로 표 추가

**검증**
- `grep -rn "model:" agents/` → 7줄 모두 `opus`/`sonnet` 확인
- plugin.json·marketplace.json·settings.json.example JSON 유효성 통과

**관련 문서** `OS호환성_잔여작업_지시서.md`

---

## 2026-07-11 — Claude Code 플러그인 구조로 전면 재편

**무엇을** 킷을 문서·템플릿 저장소에서 **Claude Code 플러그인**으로 재구성.

**왜** 실행 스크립트(슬래시 커맨드) 대신 스킬로 트리거되고, `/plugin install` 로
설치·배포되는 형태(karpathy-skills·harness 참조)로 바꾸기 위해.

**어떻게**
- `.claude-plugin/plugin.json`·`marketplace.json` 신설 (플러그인·마켓플레이스 매니페스트)
- `skills/gated-dev/SKILL.md` 신설 — 5단계 게이트 프로세스의 트리거·워크플로우 진입점
- `docs/*.md` → `skills/gated-dev/references/*.md` 이관(이름 단순화, 상호 링크 갱신)
- `.claude/agents/` 7종 → `agents/` 로 이동(플러그인 배포 정본, 중복 templates 제거)
- `/dev-pipeline` 슬래시 커맨드 제거 — 오케스트레이션을 SKILL.md 로 이관
- README·CLAUDE.md·quickstart·files 를 플러그인 설치 방식으로 재작성

**검증**
- plugin.json·marketplace.json JSON 유효성 통과
- 에이전트 7종 frontmatter 정상, SKILL references 링크 7개 연결
- references 상호 링크·상위 템플릿 링크 실존 확인

**관련 문서** 없음(대화 기반 재구성)
