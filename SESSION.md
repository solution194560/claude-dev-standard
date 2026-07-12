<!-- 세션 체크포인트 — 진행/미완 상태. 완료되면 비우고 CHANGELOG 로 (CLAUDE.md §2). -->
# 세션 요약 — 2026-07-12

## 이 세션에서 한 일 (시간순)
1. **Ruler 도입·정본 이관** — 5단계 게이트로 도입(시나리오 15/15 통과), 정본 이관까지 완료.
2. **문서 정리** — 게이트 산출물 등 개발 과정 문서 14개 삭제(git 히스토리 보존).
3. **안전 정책 정합화** — §0 위험 작업 목록과 deny·정본의 관계 명확화.
4. **모델 최적화** — 계획=Fable, 점검·구현·검증·최종=Sonnet, 판정·에러=Opus.
   Codex 교차검증(2·4단계)은 gpt-5.6-sol. 표기 5곳(frontmatter·CLAUDE.md·README·SKILL·references) 일관.
5. **Ruler 제거 (원점 복귀)** — 단일 저장소·단일 도구 환경에서 실익 대비 유지비 과다 판단.
   규칙 정본을 CLAUDE.md 하나로 복원(공통 규칙 3건 §4 복귀, §0 목록 보강),
   AGENTS.md 는 Codex 참조용 **수동 유지 요약본**으로 전환. 도입·검증 기록은 git 히스토리 보존.
6. **프로세스 확인 문답** — 5단계 vs 경량 분기(process.md 결정 트리 존재),
   에러 대응 경로(error-analyst → implementer → 검증 → gate-judge) 정리.

## 현재 상태
- **git — GitHub 완전 동기화** (Ruler 제거 4d9c7bf 까지 push 완료, ahead 0).
- 규칙 구조 — CLAUDE.md(정본, 자기완결) + AGENTS.md(Codex용 수동 요약) + settings deny(강제).
- 대화용 Artifact 3종(초보자 안내서·종합 리포트·정책 맵)은 claude.ai 호스팅 — git 무관.
  단, 정책 맵·리포트에 Ruler 구조 설명이 남아 있음(제거 반영 안 됨 — 필요 시 갱신).

## 미결 (다음 세션에서)
- [ ] **에러 A/B 분기 명문화 여부** — "경량 진단 vs error-analyst 경로"를 나누는 결정 트리를
  process.md 에러 대응 절에 추가할지 사용자 미답. 현재는 문서상 기본값 "에러면 error-analyst
  경로"이고, 경량 진단은 세션 재량(제안 → 사용자 확인) 운용.
- 관찰(선택) — Fable 계획·Sonnet 점검 품질을 실전에서 확인. 결함 놓침 체감 시 재조정.
- AGENTS.md 는 수동 파일 — CLAUDE.md 공통 규칙 변경 시 의미 일치하게 함께 갱신할 것.

## 참고
- 작업별 상세는 CHANGELOG.md 2026-07-12 항목들(최상단 "Ruler 계층 제거"부터 역순).
- 이번 세션 총 AI 사용량 — Claude 서브에이전트 약 574만 + Codex 약 72만 토큰(게이트 반복 포함).
