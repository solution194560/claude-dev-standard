<!-- Ruler 정본 이관 실데이터 검증 결과 (경량 경로 — 세션 직접 구현·검증) -->
# RULER_MIGRATION_RESULT — 정본 이관 실데이터 검증 결과

- 대상 계획: [PLAN_RULER_MIGRATION.md](PLAN_RULER_MIGRATION.md) (계획 점검 APPROVE 확정 —
  [PLAN_RULER_MIGRATION_REVIEW_JUDGE.md](PLAN_RULER_MIGRATION_REVIEW_JUDGE.md) 3차)
- 진행 방식: 경량 경로(세션 직접 구현·검증, 사람 apply). 실행일 2026-07-12
- 커밋: Phase 1 `f7142e1` · Phase 2 `a347388` · Phase 3 `263467f`

## 오프라인 회귀 (O1~O8) — 전부 통과

| # | 검사 | 결과 |
|---|---|---|
| O1 | 플러그인 매니페스트 JSON | OK |
| O2 | 정본↔생성물 일치 `check-sync.sh` | exit 0 (두 파일 일치) |
| O3 | 중복 제거 — (i) 삭제 키 문구 4건 `grep -F` 부재 / (ii) 대응 의미 생성물 존재 | 4건 부재, 대응 의미 보존 |
| O4 | 잔류 대상 보존(§0 프로필·§1·모델 표기·경량 경로 등) | 원문 보존 |
| O5 | 임포트 `@RULER_CLAUDE.md` + 개발 전용 주석 | 존재(107행) |
| O6 | 생성물 git 추적 | RULER_CLAUDE.md·AGENTS.md 추적 |
| O7 | 불변 영역 `agents/`·`skills/`·`templates/`·`.gitignore` | 무변경 |
| O8 | 스크립트 문법 `bash -n` | 통과 |

## 실데이터 검증 (R1~R4)

### R1 — 사람 apply 절차 (Phase 2) · 통과
사람이 본 저장소 루트에서 §3.5 절차로 `ruler apply` 실행. dry-run 대상이 생성물 2개(+
`.codex/config.toml` 선언만), apply 후 워킹트리 변경이 `?? RULER_CLAUDE.md`·`?? AGENTS.md`
2건뿐. `.codex/config.toml` 실물 미생성, `CLAUDE.md`·`.gitignore` 무변경 확인.

### R2 — 반복성 · 확보(check-sync 대체 증거)
`check-sync.sh` 가 정본↔생성물 일치(exit 0)를 확인 — 커밋된 `AGENTS.md` 존재 상태에서 내용
안정성 확보(1차 시나리오 0 2회차 조건과 등가). apply 재실행 시 `git diff` 0 은 사람이 차후 확인.

### R3 — 임포트 실제 로드 확인 · **사람 확인 대기**
Phase 3 완료 후 본 저장소에서 **새 Claude Code 세션**을 열어 "현재 로드된 공통 안전 규칙 중
실쓰기 금지 항목을 열거하라" 질의 → 응답에 10-safety 4항목(git push·[y/N] y·실쓰기 플래그·
드라이런/사람 반영)이 나타나는지 확인. **미완료 — 사용자 확인 필요.** 질의·응답 원문을 이 문서에 추가 보존.

### R4 — Codex 로드 확인 · 통과
`codex exec -m gpt-5.5 --skip-git-repo-check -C . --sandbox read-only -` 로 루트 `AGENTS.md`
안전 규칙 요약 지시(read-only, 에이전트 수행). tokens used 18,156. codex 응답이 10-safety
전 항목을 원문 근거로 열거:

> - `git push` 등 원격 반영은 금지됩니다.
> - 대화형 확인 프롬프트(`[y/N]`)에 `y`로 응답하면 안 됩니다.
> - `--apply`, `--yes`, `--no-dry-run`처럼 되돌릴 수 없는 실쓰기 플래그 사용이 금지됩니다.
> - 운영 게시, 배포, 데이터 변경은 드라이런까지만 허용됩니다.
> - 실제 반영은 에이전트가 아니라 사람이 직접 수행해야 합니다.
> - `.ruler/` 수정 후 갱신 절차도 사람이 `dry-run → apply → git diff 확인 → 재생성물 포함 커밋`
>   순서로 수행하며, 에이전트는 `apply` 실행이 금지됩니다.
> - 파괴적 작업 전에는 반드시 백업과 미리보기(`dry-run`)를 먼저 수행해야 합니다.
> - 권한(`tools/deny`·샌드박스)은 대상별 네이티브 설정으로 관리하며 변환 과정에서 약화하면 안 됩니다.

Claude·Codex 공통 안전룰 의미 일치 확인.

## 수용 기준 (§5.3) 충족 현황

| 수용 기준 | 상태 |
|---|---|
| §0 프로필 보존 + 중복 제거(O3·O4) | 충족 |
| 정본↔생성물 일치(O2) + 반복성(R2) | 충족 |
| 임포트 실제 로드(R3) | **사람 확인 대기** |
| Codex 가 AGENTS.md 인식(R4) | 충족 |
| 게이트 의미 불변 — `agents/`·`skills/`·`templates/` 무수정(O7) | 충족 |
| 생성물 2개 git 추적(O6), `.gitignore` 무변경 | 충족 |

**결론**: R3(사람의 새 세션 확인) 1건을 제외한 전 항목 충족. R3 통과 시 정본 이관 완결.
