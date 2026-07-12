# 5단계 게이트 프로세스 요약

1. 계획(plan-writer) → 2. 점검(plan-reviewer) → 3. 구현(implementer) →
4. 검증(impl-verifier) → 5. 최종 테스트(final-tester). 각 게이트 판정은 gate-judge 가 확정한다.

## 착수 차단 규칙 (약화 금지)
- 계획 점검 REVIEW 의 APPROVE 판정(`*_REVIEW_JUDGE.md`) 없이는 구현하지 않는다.
- 구현 검증 VERIFY 의 PASS 판정(`*_VERIFY_<phase>_JUDGE.md`) 없이는 최종 테스트하지 않는다.
- 증거 수집자(점검/검증/최종테스트)와 판정자(gate-judge)는 분리한다.
- 상세 실행·트리거는 skills/gated-dev 가 정본이다. 이 요약은 그 의미를 낮추지 않는다.
