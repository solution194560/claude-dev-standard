# claude-dev-standard 운영 가이드

최종 업데이트: 2026-07-12

## 0) 프로젝트 프로필 (에이전트 참조용 — 필수 기재)

| 항목 | 값 |
|---|---|
| 개요 | 5단계 게이트 개발 프로세스를 Claude Code **플러그인**으로 배포하는 저장소. 스킬(`skills/gated-dev`)·에이전트 7종(`agents/`)·프로젝트 초기화 템플릿(`templates/`)을 제공하며 애플리케이션 코드는 없다. |
| 실행 명령 | 없음 — 플러그인·문서 저장소 |
| 테스트 명령 | `python3 -c "import json;json.load(open('.claude-plugin/plugin.json'));json.load(open('.claude-plugin/marketplace.json'));print('OK')"` · `bash ruler-test/check-sync.sh` (정본↔생성물 일치) |
| 주요 산출물 경로 | `.claude-plugin/*.json`, `skills/**`, `agents/**`, `templates/**`, `README.md` |
| 외부 점검 도구 | `codex exec -m gpt-5.5 --skip-git-repo-check -C . --sandbox read-only -` (지시문은 stdin 으로 전달) |

### 위험 작업 목록 (에이전트 실행 금지 — 드라이런까지만)
<!-- 공통 안전 규칙의 정본은 .ruler/10-safety.md(→ @RULER_CLAUDE.md 임포트)와
     .claude/settings.json 의 deny(강제)다. deny 에는 실쓰기 플래그(--apply·--yes·--no-dry-run)와
     .env 접근 차단이 더 있으며, 강제되는 전체 목록은 그쪽이 정본이다. 아래는 대표 항목만 남긴
     지시문이므로, 새 위험 명령은 deny(강제)에 먼저 넣을 것. -->
> 공통 안전 규칙은 임포트(`@RULER_CLAUDE.md`, 정본 `.ruler/10-safety.md`)와 deny 를 따른다.
> 아래는 대표 항목이며, 실쓰기 플래그·`.env` 차단 등 강제되는 전체 목록은 deny(`.claude/settings.json`)가 정본이다.
- `git push` — 원격 저장소 반영
- 대화형 확인 프롬프트(`[y/N]`)에 `y` 응답하는 행위 일체

## 1) 작업 원칙 (무조건 준수)
- **소스 작성 전 구성/설계 먼저 제시(2~3안 비교) → 확인 → 구현**: 새 소스(스크립트/
  모듈/함수)를 만들 때는 반드시 먼저 **최선의 방안 2~3가지**를 구성(파일 배치·함수
  구조·동작 흐름)과 함께 제시하고, **각 안의 장단점을 정리**해 보여준 뒤, 사용자
  확인(방안 선택)을 받고 나서 실제 코드를 작성한다. 확인 없이 바로 구현하지 않는다.
  - 기존 코드 조회·분석(Read/Grep 등)은 확인 없이 진행 가능.
  - 새 파일 생성, 로직 추가/변경은 확인 후 진행.
  - 방안이 사실상 1개뿐이거나 사용자가 이미 방식을 구체적으로 지정한 경우는 예외 —
    그 경우 단일안 설계만 제시하고 확인받는다.

## 2) 변경 이력·세션 기록
작업 기록은 [CHANGELOG.md](CHANGELOG.md)에 분리 관리한다(CLAUDE.md는 매 턴 자동
로드되므로 얇게 유지 — 토큰 비용 절감). **새 작업을 완료하면 CLAUDE.md가 아니라
CHANGELOG.md 맨 위에 기록할 것.**

**진행 중** 작업의 체크포인트는 `SESSION.md`에 남긴다(중단 시 갱신: 하던 일·다음 할
일·확정된 결정·재개 명령 — 완료되면 비우고 CHANGELOG로). 세션 재개 시 SESSION.md 를
먼저 읽는다.

## 3) 실행
실행 가능한 앱이 없다. 검증은 아래 테스트 명령으로 한다.

```bash
cd /Users/hyundeok/cluade/claude-dev-standard
python3 -c "import json;json.load(open('templates/.claude/settings.json.example'));print('OK')"
```

## 4) 개발 프로세스 (서브에이전트 — .claude/agents/)
새 기능/개편은 5단계 게이트로 진행한다. **각 단계 산출물의 판정이 통과일 때만
다음 단계로 진행한다.**

| 단계 | 에이전트 | 모델 (외부 검증) | 산출물(게이트) |
|---|---|---|---|
| 1 계획 수립 | plan-writer | Fable 5 | PLAN_<주제>.md |
| 2 계획 점검 | plan-reviewer | Sonnet 5 (+GPT-5.5) | *_REVIEW.md — APPROVE/REVISE **권고** |
| 3 구현 | implementer | Sonnet 5 | 코드 + CHANGELOG (Phase 단위) |
| 4 구현 검증 | impl-verifier | Opus 4.8 (+GPT-5.5) | *_VERIFY_*.md — PASS/FAIL **권고** |
| 5 최종 테스트 | final-tester | Sonnet 5 | *_FINAL_*.md — DONE/BLOCKED **권고** |
| 판정 | gate-judge | Opus 4.8 | *_JUDGE.md — 위 게이트(2·4·5)의 판정 **확정** |
| 에러 대응 | error-analyst | Opus 4.8 | FIX_<주제>.md |

> 모델 열은 각 에이전트 frontmatter 의 `model:` 이 정본이다(바꾸면 여기도 갱신).
> `(+GPT-5.5)` 는 §0 "외부 점검 도구"(Codex)로 하는 교차 검증 모델이다.
> 게이트 판정·증거·공통 안전 규칙은 공통 규칙(`@RULER_CLAUDE.md`, 정본 `.ruler/`)을 따른다.

- **단계별 모델·토큰 표기(세션이 담당)**: 세션(오케스트레이터)은 각 단계의 서브에이전트를
  호출하기 **직전에** 그 단계 모델을 한 줄로 코멘트한다 — 예: `▶ [4단계 구현 검증]
  impl-verifier · Opus 4.8, 외부 검증 GPT-5.5(Codex)`. 호출이 **끝나면** 하네스가
  반환한 서브에이전트 토큰을 `⏱ 4단계 토큰: N` 으로 보고하고, 외부 점검 도구를 쓴
  단계(2·4)는 codex 응답의 `tokens used` 값도 함께 적는다. **서브에이전트는 자기 토큰을
  스스로 세지 못하므로** 이 코멘트·집계는 반드시 세션이 한다(에이전트에게 위임 금지).
  이 표기는 5단계 게이트에 한정하지 않는다 — **경량 경로·임의 서브에이전트 호출을
  포함한 모든 서브에이전트 호출과 구현 착수**에 적용한다. 세션이 직접 구현하는
  경우에도 착수 전 `▶ [구현] 세션 직접 · <모델>` 코멘트를 달되, 세션 인라인 작업은
  토큰 측정 수단이 없으므로 토큰 표기는 생략하고 그 사실을 언급한다.

- 게이트 판정은 gate-judge 가 확정한다(권고/확정·착수 차단 상세는 공통 규칙 참조).
  호출 예: "gate-judge 로 구현 검증 판정해줘"
- 테스트 실행은 외부 점검 도구와 무관하게 에이전트가 항상 직접 수행한다.
- 단건 수정(버그픽스 등)은 경량 경로 가능: 설계 확인 → 구현 → 테스트 →
  실데이터 확인 → CHANGELOG 기록.
- **에러 대응 경로**(테스트 실패·운영 에러): error-analyst 로 근본 원인 분석
  (`FIX_<주제>.md`) → implementer 수정 → 검증 → gate-judge 판정. error-analyst 는
  코드를 고치지 않고 분석만 한다.
- 호출 예: "plan-reviewer 서브에이전트로 PLAN_<주제>.md 점검해줘"
- **오케스트레이션은 스킬이 담당**: 슬래시 커맨드 대신 스킬 `skills/gated-dev/SKILL.md`
  가 트리거되어 1~5단계와 각 게이트 판정을 순차 진행한다. 단건 수정은 경량 경로 권장.

## 5) 정책 요약 (이 저장소 = 플러그인 배포)
- `agents/` 는 배포되는 에이전트 정본이다. 에이전트 도구 목록의 정본은 각 파일의
  `tools:` frontmatter 이며, `skills/gated-dev/references/` 문서의 표는 사본이다(어긋나면 파일을 따른다).
- `skills/gated-dev/SKILL.md` 는 프로세스 진입점(트리거·워크플로우), `references/` 는 상세 문서다.
- `templates/` 는 사용자 프로젝트 초기화용(CLAUDE.md 프로필 뼈대 등)이다.
- `.claude-plugin/plugin.json`·`marketplace.json` 이 플러그인·마켓플레이스 매니페스트다.
- `templates/.gitignore.example` 을 `templates/.gitignore` 로 이름을 바꾸지 않는다.
  저장소 자신의 git 이 그 규칙을 적용해 버린다.
- `.ruler/` 는 공통 안전·프로세스·증거 규칙의 **정본**이다. 루트 `RULER_CLAUDE.md`·`AGENTS.md` 는
  Ruler **생성물**(직접 수정 금지, 커밋 대상)이며, 내용 변경은 반드시 `.ruler/` → 사람 apply
  경로로만 한다(dry-run → apply → `git diff` 확인 → `check-sync` → 생성물 포함 커밋). 에이전트는
  `ruler apply`/`revert` 를 실행하지 않는다(`check-sync.sh` 는 읽기 전용이라 실행 가능).

<!-- Ruler 생성물 임포트 — 본 저장소(claude-dev-standard) 개발 전용.
     templates/ 로 배포 금지: 사용자 프로젝트에는 RULER_CLAUDE.md·.ruler/ 가 없어 깨진다.
     공통 규칙 정본은 .ruler/ 이며 RULER_CLAUDE.md 는 생성물(직접 수정 금지). -->
@RULER_CLAUDE.md
