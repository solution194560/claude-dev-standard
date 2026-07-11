# 변경 이력 (CHANGELOG)

<!-- 완료된 작업만 기록합니다. 진행 중은 SESSION.md. 최신이 맨 위. -->

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
