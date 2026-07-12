---
name: gated-dev
description: "5단계 게이트 개발 프로세스로 기능·변경을 진행한다. (1) '계획 세워줘', 'OO 기능 개발', '5단계로 진행' 요청 시, (2) '계획 점검', '구현 검증', '최종 테스트', '게이트 판정' 요청 시, (3) 코드 변경을 계획→점검→구현→검증→최종 게이트로 체계적으로 관리할 때, (4) '이 에러 원인 분석해줘' 등 근본 원인 분석 요청 시 사용. 계획·점검·구현·검증·최종을 전담 서브에이전트로 나누고, 증거 수집자와 판정자(gate-judge)를 분리해 자가 채점을 막는다."
license: MIT
---

# Gated Dev — 5단계 게이트 개발 프로세스

AI 코딩의 전형적 실패 네 가지 — 계획 없이 바로 구현, 자기가 짠 것을 자기가 검증,
실수로 운영 시스템에 반영, 무엇을 왜 바꿨는지 기록 없음 — 를 회사 개발팀의
기획→검토→개발→QA→검수 절차로 막는다. 각 단계에 전담 에이전트가 있고,
**판정을 통과해야만 다음 단계로 간다.**

**핵심 원칙**
1. **설계 먼저** — 새 소스 작성 전 방안 2~3개를 비교 제시하고 사용자 확인을 받는다.
2. **심판과 선수의 분리** — 소스를 고치는 것은 implementer 하나뿐. 점검·검증·최종
   에이전트는 결함을 보고만 하고, 최종 판정은 gate-judge가 확정한다(증거를 만든 자가
   스스로 채점하지 못하게 한다).
3. **실쓰기 금지선** — 운영 반영(게시·배포·데이터 변경)은 드라이런까지만. 실제 반영은 사람이.
4. **기록** — 완료는 CHANGELOG, 진행 중은 SESSION.md, 게이트 판정은 보고서 파일로 보존.

## 전제 — 프로젝트 프로필

에이전트들은 프로젝트 고유 정보를 프로젝트 루트 `CLAUDE.md`의 **§0 프로젝트 프로필**에서
읽는다(실행 명령·테스트 명령·주요 산출물·외부 점검 도구·위험 작업 목록). 프로필이 없으면
`templates/CLAUDE.md.template`을 복사해 채운다. 이 스킬은 그 프로필을 참조해 동작한다.

## 워크플로우

### 0단계: 경로 판단
요구사항이 5단계 대상인지 먼저 가린다([references/process.md](references/process.md) 기준).
- 새 모듈/기능이거나 설계 변경 → **5단계 전체**
- 기존 로직의 단건 수정(버그픽스 등) → **경량 경로**(설계 확인 → 구현 → 테스트 →
  실데이터 확인 → CHANGELOG)
- 애매하면 → 5단계 전체(보수적)

테스트 실패·운영 에러는 5단계가 아니라 **에러 대응 경로**를 쓴다: `error-analyst`로
근본 원인 분석(`FIX_<주제>.md`) → implementer 수정 → 검증 → gate-judge 판정.

### 단계별 실행 (5단계 전체)
각 서브에이전트는 이 대화를 못 본다 — 호출 지시문에 **대상 파일 절대경로와 요구사항
전문**을 포함해 넘긴다. **단계 시작 직전에 모델을 코멘트하고, 종료 후 토큰을 보고한다**
(아래 "모델·토큰 표기").

| 단계 | 에이전트 | 모델(외부 검증) | 산출물 |
|---|---|---|---|
| 1 계획 수립 | plan-writer | Fable | `PLAN_<주제>.md` |
| 2 계획 점검 | plan-reviewer | Sonnet (+Codex) | `_REVIEW.md` (APPROVE/REVISE **권고**) |
| — 판정 | gate-judge | Opus | `_REVIEW_JUDGE.md` (**확정**) — REVISE면 1로 |
| 3 구현 | implementer | Sonnet | 코드 + CHANGELOG |
| 4 구현 검증 | impl-verifier | Opus (+Codex) | `_VERIFY_<phase>.md` (PASS/FAIL **권고**) |
| — 판정 | gate-judge | Opus | `_VERIFY_<phase>_JUDGE.md` (**확정**) — FAIL이면 3으로 |
| 5 최종 테스트 | final-tester | Sonnet | `_FINAL_<phase>.md` (DONE/BLOCKED **권고**) |
| — 판정 | gate-judge | Opus | `_FINAL_<phase>_JUDGE.md` (**확정**) — DONE이면 CHANGELOG 기록 |

- **1 계획**: 자기완결적 문서(이 문서만으로 점검·구현 가능). 코드 작성 금지.
- **1 직후 사용자 확인 게이트**(설계 먼저 규칙): 계획 요약과 "확인 요청 사항"을 보여주고
  진행 여부를 묻는다.
- **2·4 점검/검증**: 프로필의 "외부 점검 도구"(Codex)가 설정됐으면 그 결과가 판정 기준.
  **테스트는 도구와 무관하게 에이전트가 항상 직접 실행**하고, 출력 원문을 보고서에 첨부한다.
- **모든 게이트 판정은 gate-judge가 확정한다.** 게이트 에이전트는 권고만 하며, 그 직후
  반드시 gate-judge를 호출한다. gate-judge는 ① 원시 증거(테스트·외부 도구 응답 원문)가
  없으면 반려, ② 테스트 실패·외부 도구 반려·안전 위반이면 즉시 반려, ③ 그 뒤에야 뉘앙스
  판단을 한다.
- **5 최종**: 실데이터 e2e, 쓰기는 드라이런까지만. DONE 확정 시 CHANGELOG 기록은
  gate-judge가 한다.

### 모델·토큰 표기 (세션이 담당)
세션(오케스트레이터)은 각 단계 서브에이전트를 호출하기 **직전에** 모델을 한 줄로
코멘트하고(`▶ [4단계 구현 검증] impl-verifier · Opus, 외부 검증 GPT-5.5(Codex)`),
호출이 **끝나면** 하네스가 반환한 서브에이전트 토큰을 `⏱ 4단계 토큰: N`으로 보고한다.
2·4단계는 codex 응답의 `tokens used`도 함께 적는다. **서브에이전트는 자기 토큰을
스스로 세지 못하므로** 이 집계는 반드시 세션이 한다.

## 안전 금지선 (전 단계 공통)
- 프로필 "위험 작업 목록"의 실쓰기는 **드라이런까지만** — 실제 게시·배포·데이터 변경,
  대화형 `[y/N]`에 `y` 응답을 하지 않는다.
- 게이트 판정이 통과(gate-judge 확정)가 아니면 다음 단계로 넘어가지 않는다.
- 판정은 세션이 직접 내리지 않고 항상 gate-judge에 맡긴다.

## 참조 문서
- [references/process.md](references/process.md) — 5단계 게이트 상세·산출물 명명·경량 경로
- [references/agents.md](references/agents.md) — 에이전트 7종 역할·모델 교체·Codex 연동
- [references/rules.md](references/rules.md) — 개발 규칙과 그 이유
- [references/session.md](references/session.md) — 세션 이어가기(SESSION.md)
- [references/cost.md](references/cost.md) — 토큰 비용 통제
- [references/quickstart.md](references/quickstart.md) — 프로젝트 초기 세팅
- [references/files.md](references/files.md) — 파일별 상세 설명
