# claude-dev-standard 공통 규칙 (Ruler 배포 원본)

이 파일은 Ruler 가 Claude(RULER_CLAUDE.md)·Codex(AGENTS.md) 대상으로 배포하는 공통 규칙의
일부다. 이 `.ruler/` 디렉터리가 공통 안전·프로세스 규칙의 **정본**이며, 루트의
RULER_CLAUDE.md·AGENTS.md 는 **생성물(직접 수정 금지)** 이다.

## 프로젝트 개요
5단계 게이트 개발 프로세스를 Claude Code 플러그인으로 배포하는 저장소.
애플리케이션 코드는 없다. 상세 프로젝트 프로필·실행/테스트 명령은 CLAUDE.md §0 이 정본이며,
이 파일은 그 프로필을 대체하지 않는다.

## 정본 우선순위
- 프로젝트 프로필(§0): CLAUDE.md 가 정본.
- 5단계 상세 실행: skills/gated-dev 가 정본.
- 게이트 판정 로직: agents/gate-judge.md 가 정본.
- 공통 안전·프로세스·증거 규칙: 이 `.ruler/` 가 정본이며 대상별 파일로 배포된다.
