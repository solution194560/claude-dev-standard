# 변경 이력 (CHANGELOG)

<!-- 완료된 작업만 기록합니다. 진행 중은 SESSION.md. 최신이 맨 위. -->

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
