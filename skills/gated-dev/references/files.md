# 00. 파일별 상세 설명서 (File Guide)

이 플러그인에 들어 있는 **모든 파일**의 용도·읽는 시점을 정리한 지도입니다.
"이 파일이 뭐지?" 싶을 때 여기로 오세요.

```
claude-dev-standard/
├── .claude-plugin/               📦 플러그인 매니페스트
│   ├── plugin.json               플러그인 정의 (이름·버전·skills 경로)
│   └── marketplace.json          마켓플레이스 등록 정보
├── skills/gated-dev/
│   ├── SKILL.md                  🎯 진입점 — 트리거·5단계 워크플로우
│   └── references/               📖 상세 문서 (지금 이 폴더)
│       ├── files.md              지금 이 문서
│       ├── quickstart.md         설치·초기 세팅
│       ├── process.md            5단계 게이트 상세
│       ├── agents.md             에이전트 7종 + Codex 연동
│       ├── rules.md              개발 규칙과 그 이유
│       ├── session.md            세션 이어가기
│       └── cost.md               비용 통제
├── agents/                       🤖 배포되는 에이전트 7종 (설치 시 등록)
│   ├── plan-writer.md            1 계획 수립
│   ├── plan-reviewer.md          2 계획 점검
│   ├── implementer.md            3 구현 (유일하게 소스 수정)
│   ├── impl-verifier.md          4 구현 검증
│   ├── final-tester.md           5 최종 테스트
│   ├── gate-judge.md             게이트 판정 확정
│   └── error-analyst.md          에러 근본 원인 분석
├── templates/                    🧩 사용자 프로젝트 초기화용
│   ├── CLAUDE.md.template         → 내 프로젝트의 CLAUDE.md (프로필 뼈대)
│   ├── CHANGELOG.md.template       → 내 프로젝트의 CHANGELOG.md
│   ├── .gitignore.example          → 내 프로젝트의 .gitignore
│   └── .claude/settings.json.example → .claude/settings.json (권한)
├── README.md                     소개 + 설치 + 지도
├── CHANGELOG.md · LICENSE(MIT)
```

---

## 📦 .claude-plugin/ — 플러그인 매니페스트

### plugin.json
플러그인 정의. `name`·`version`·`description`·`author`·`license`·`keywords`와
`skills`(스킬 폴더 경로) 를 담는다. `/plugin install` 이 이 파일을 읽는다.

### marketplace.json
`/plugin marketplace add <repo>` 로 등록될 때 쓰는 마켓플레이스 정보. `owner` 와
`plugins` 배열(이 저장소가 배포하는 플러그인 목록)을 담는다.

## 🎯 skills/gated-dev/SKILL.md — 진입점

플러그인의 핵심. frontmatter 의 `description` 이 **트리거 조건**("계획 세워줘",
"구현 검증", "에러 원인 분석" 등)이고, 본문은 5단계 게이트 **워크플로우**다. 사용자가
관련 요청을 하면 이 스킬이 트리거되어 세션이 단계를 오케스트레이션한다. 상세는
`references/` 로 링크한다.

## 📖 skills/gated-dev/references/ — 상세 문서

| 문서 | 한 줄 | 언제 읽나 |
|---|---|---|
| [quickstart.md](quickstart.md) | 설치 → 프로필 → 첫 실행 | 처음 쓸 때 (필독) |
| [process.md](process.md) | 5단계 게이트 규칙·산출물 명명·경량 경로 기준 | 첫 개발 전 + 판정이 헷갈릴 때 |
| [agents.md](agents.md) | 에이전트 7종 역할·모델 교체·Codex 연동/폴백 | 에이전트를 부를 때, 모델·Codex를 바꿀 때 |
| [rules.md](rules.md) | 개발 규칙의 정본 — 각 규칙이 왜 있는지 | 초기 (필독) |
| [session.md](session.md) | 세션 이어가기 — SESSION.md 체크포인트 | 며칠에 걸쳐 작업할 때 |
| [cost.md](cost.md) | 토큰 비용 통제 4축 | 요금이 걱정될 때 |
| files.md | 지금 이 문서 | "이 파일 뭐지?" 싶을 때 |

## 🤖 agents/ — 서브에이전트 7종 (수정 없이 사용)

공통 구조는 frontmatter(`name`·`description`·`model`·`tools`) + 지시문이다.
**프로젝트 고유 정보는 전부 CLAUDE.md §0 에서 읽으므로 파일 수정은 불필요** —
`model:`(모델 교체) 외에는 손대지 않는 것을 권장한다. 각 에이전트의 역할·도구·산출물
상세는 [agents.md](agents.md) 의 "한눈에 보기" 표가 정본이다. 게이트 5종(1~5) 외에
**gate-judge**(판정 확정)와 **error-analyst**(에러 분석)가 있다.

핵심 설계는 **심판과 선수의 분리**다 — 소스를 고치는 것은 implementer 하나뿐, 나머지는
결함을 보고만 하고, 최종 판정은 gate-judge 가 확정한다.

## 🧩 templates/ — 사용자 프로젝트 초기화용

플러그인은 스킬·에이전트를 배포하지만, **사용자 프로젝트의 `CLAUDE.md` 프로필은 각자
채워야** 한다. 그 뼈대가 templates 다.

| 파일 | 용도 |
|---|---|
| CLAUDE.md.template | 내 프로젝트 `CLAUDE.md` — §0 프로필(에이전트가 읽음)이 핵심 |
| CHANGELOG.md.template | 내 프로젝트 `CHANGELOG.md` — 완료 작업 기록(최신이 맨 위) |
| .gitignore.example | 시크릿(`.env`)·개인 설정 제외 |
| .claude/settings.json.example | 도구 권한 — `deny` 가 안전 금지선을 강제 |

> `templates/.gitignore.example` 을 `templates/.gitignore` 로 이름을 바꾸지 않는다 —
> 저장소 자신의 git 이 그 규칙을 적용해 버린다.

---

## 읽기 순서 추천

| 상황 | 순서 |
|---|---|
| 처음 설치 | README → quickstart (따라하기) → rules |
| 첫 개발 시작 전 | process → agents |
| Codex 연결/해제 | agents 의 Codex 절만 |
| 장기 작업·비용 관리 | session → cost |
| 특정 파일이 궁금함 | 이 문서 (files) |
