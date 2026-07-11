# 변경 이력 (CHANGELOG)

<!-- 완료된 작업만 기록합니다. 진행 중은 SESSION.md. 최신이 맨 위. -->

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
