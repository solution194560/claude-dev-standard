# claude-dev-standard 운영 가이드

최종 업데이트: 2026-07-11

## 0) 프로젝트 프로필 (에이전트 참조용 — 필수 기재)

| 항목 | 값 |
|---|---|
| 개요 | Claude Code 로 5단계 게이트 개발 프로세스를 적용하기 위한 표준 킷. 설명 문서(`docs/`)와 복사용 템플릿(`templates/`)만 제공하며 애플리케이션 코드는 없다. |
| 실행 명령 | 없음 — 실행 가능한 앱 코드가 없는 문서·템플릿 저장소 |
| 테스트 명령 | `python3 -c "import json;json.load(open('templates/.claude/settings.json.example'));print('OK')"` |
| 주요 산출물 경로 | `docs/*.md`, `templates/**`, `README.md` |
| 외부 점검 도구 | `codex exec --skip-git-repo-check -C . --sandbox read-only -` (지시문은 stdin 으로 전달) |

### 위험 작업 목록 (에이전트 실행 금지 — 드라이런까지만)
<!-- 여기에 명령을 추가할 때마다 .claude/settings.json 의 "deny" 에도 같은 명령을 추가할 것.
     이 목록은 지시문이고 deny 는 강제다. 둘이 어긋나면 지시문만 남는다. -->
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

| 단계 | 에이전트 | 산출물(게이트) |
|---|---|---|
| 1 계획 수립 | plan-writer | PLAN_<주제>.md |
| 2 계획 점검 | plan-reviewer | *_REVIEW.md — APPROVE/REVISE **권고** |
| 3 구현 | implementer | 코드 + CHANGELOG (Phase 단위) |
| 4 구현 검증 | impl-verifier | *_VERIFY_*.md — PASS/FAIL **권고** |
| 5 최종 테스트 | final-tester | *_FINAL_*.md — DONE/BLOCKED **권고** |
| 판정 | gate-judge | *_JUDGE.md — 위 게이트(2·4·5)의 판정 **확정** |

- **게이트 판정은 gate-judge 가 확정한다.** 점검·검증·최종 테스트 에이전트는 증거를
  모으고 **권고**만 하며, 그 직후 반드시 gate-judge 를 호출해 판정(APPROVE/REVISE,
  PASS/FAIL, DONE/BLOCKED)을 확정한다. 게이트 에이전트의 권고만으로 다음 단계에
  진행하지 않는다(증거 수집자와 판정자 분리). 호출 예: "gate-judge 로 구현 검증 판정해줘"
- 점검(2)·검증(4)은 §0 프로필의 "외부 점검 도구"가 설정된 경우 그 도구의 결과를
  판정 기준으로 삼는다(도구 실패 시 에이전트 직접 점검 폴백, 사유 명기).
  테스트 실행은 도구와 무관하게 에이전트가 항상 직접 수행.
- 모든 에이전트: §0 "위험 작업 목록"의 실쓰기 금지(드라이런까지).
- 단건 수정(버그픽스 등)은 경량 경로 가능: 설계 확인 → 구현 → 테스트 →
  실데이터 확인 → CHANGELOG 기록.
- **에러 대응 경로**(테스트 실패·운영 에러): error-analyst 로 근본 원인 분석
  (`FIX_<주제>.md`) → implementer 수정 → 검증 → gate-judge 판정. error-analyst 는
  코드를 고치지 않고 분석만 한다.
- 호출 예: "plan-reviewer 서브에이전트로 PLAN_<주제>.md 점검해줘"

## 5) 정책 요약
- `docs/` 는 읽는 문서, `templates/` 는 사용자 프로젝트로 복사되는 부품이다.
  같은 내용이 양쪽에 있으면 `templates/` 의 파일이 정본이고 `docs/` 는 설명이다.
- 에이전트의 도구 목록 정본은 각 에이전트 파일의 `tools:` frontmatter 다.
  `docs/00_files.md` 의 표는 사본이므로 어긋나면 에이전트 파일을 따른다.
- `templates/.gitignore.example` 을 `templates/.gitignore` 로 이름을 바꾸지 않는다.
  킷 저장소 자신의 git 이 그 규칙을 적용해 버린다.
